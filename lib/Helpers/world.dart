import 'dart:convert';

import 'package:flutter/material.dart';
//import 'package:mpickflutter/Helpers/standard_socket_handler.dart';
import 'package:mpickflutter/Helpers/super_mc_share.dart';
import 'dart:async';

class World {
  String name;
  String uuid; // From server

  String? version;
  RunStatus runStatus = RunStatus.stopped;
  int? remotePort;
  Timer? waitForRun;
  int _waitForRunTimeout = 25;

  //SocketHandler? stdoutHndlr;

  bool safetyLock = false; // Lock to prevent conflicts.

  SuperMCShare share;

  World(this.name, this.uuid, {required this.share});
/*
  Future<bool> tryConnect() async {
    stdoutHndlr = SocketHandler(this);
    return await stdoutHndlr!.tryConnect();
  }

  void sockDone() {
    stdoutHndlr?.done();
    stdoutHndlr = null;
  }
*/
  Future<RunStatus> getStatus() async {
    final getRunStatus = await share.getStatusOfUUID(uuid);

    if (getRunStatus == "Running") {
      runStatus = RunStatus.running;
    } else if (getRunStatus == "Stopped") {
      runStatus = RunStatus.stopped;
      remotePort = null;
    } else if (getRunStatus == "Starting") {
      runStatus = RunStatus.starting;
    } else if (getRunStatus.startsWith("Unknown state")) {
      runStatus = RunStatus.stopped;
    }
    return runStatus;
  }

  Future<int?> portNumber() async {
    final getter = await share.client.get(
        Uri.parse(
            "http://${share.serverIP}:${share.serverPort}/instance/$uuid/game/port"),
        headers: {"x-username": share.username, "x-password": share.password});

    if (getter.statusCode != 200) {
      return null;
    }
    return int.tryParse(getter.body);
  }

  Future<bool> deleteSelf() async {
    final deleter = await share.client.delete(Uri.parse(
        "http://${share.serverIP}:${share.serverPort}/instance/$uuid/trash"));

    if (deleter.statusCode != 200) {
      return false;
    }
    return true;
  }

  Future<List<String>> configs() async {
    List<String> cfg = [];

    final getter = await share.client.get(
        Uri.parse(
            "http://${share.serverIP}:${share.serverPort}/instance/$uuid/info"),
        headers: {"x-username": share.username, "x-password": share.password});

    if (getter.statusCode != 200) {
      return ["Failed to get config values."];
    }

    if (getter.headers["content-type"] != "application/json") {
      return ["Response content-type was not JSON encoded."];
    }

    Map<String, dynamic> kv = JsonDecoder().convert(getter.body);

    if (kv.containsKey("version")) {
      cfg.add("Server Version: ${kv['version']}");
    }
    if (kv.containsKey("uuid")) {
      cfg.add("UUID: ${kv['uuid']}");
    }
    if (kv.containsKey("memory-max-mb")) {
      if (kv["memory-max-mb"] != null) {
        cfg.add("Maximum Memory: ${kv['memory-max-mb']} MB");
      }
    }
    if (kv.containsKey("memory-min-mb")) {
      if (kv["memory-min-mb"] != null) {
        cfg.add("Minimum Memory: ${kv['memory-min-mb']} MB");
      }
    }

    return cfg;
  }

  Future<List<String>> playersList() async {
    List<String> players = [];
    if (await getStatus() != RunStatus.running) {
      players.add("Instance isn't running.");
    } else {
      final pget = await share.client.get(
          Uri.parse(
              "http://${share.serverIP}:${share.serverPort}/instance/$uuid/game/players"),
          headers: {
            "x-username": share.username,
            "x-password": share.password
          });

      if (pget.statusCode != 200 || pget.body.contains("not running.")) {
        players.add("Failed to fetch player list.");
      } else {
        var jbody = JsonDecoder().convert(pget.body);
        for (dynamic player in jbody) {
          players.add(player);
        }
      }
    }

    return players;
  }

  Future<String> patchInstanceConfig(String field, String value) async {
    if (field == "max-memory") {
      return (await share.client.patch(
              Uri.parse(
                  "http://${share.serverIP}:${share.serverPort}/instance/$uuid/update"),
              headers: {
                "x-username": share.username,
                "x-password": share.password
              },
              body: "field=memory&new-max=$value"))
          .body;
    } else if (field == "min-memory") {
      return (await share.client.patch(
              Uri.parse(
                  "http://${share.serverIP}:${share.serverPort}/instance/$uuid/update"),
              headers: {
                "x-username": share.username,
                "x-password": share.password
              },
              body: "field=memory&new-min=$value"))
          .body;
    } else if (field == "name") {
      return (await share.client.patch(
              Uri.parse(
                  "http://${share.serverIP}:${share.serverPort}/instance/$uuid/update"),
              headers: {
                "x-username": share.username,
                "x-password": share.password
              },
              body: "field=name&new-value=$value"))
          .body;
    }
    return (await share.client.patch(
            Uri.parse(
                "http://${share.serverIP}:${share.serverPort}/instance/$uuid/update"),
            headers: {
              "x-username": share.username,
              "x-password": share.password
            },
            body: "field=$field&new-value=$value"))
        .body;
  }

  void startServer(ScaffoldMessengerState notifyOnError,
      {bool tryStatic = false, bool advertise = false}) async {
    if (await getStatus() != RunStatus.stopped) {
      return;
    }

    final startRequest = await share.client.post(
        Uri.parse(
            "http://${share.serverIP}:${share.serverPort}/instance/$uuid/game/start"),
        headers: {"x-username": share.username, "x-password": share.password},
        body:
            "try-static=${tryStatic ? "true" : "false"}&try-advert=${advertise ? "true" : "false"}");

    if (startRequest.statusCode != 200) {
      notifyOnError.clearSnackBars();
      notifyOnError.showSnackBar(SnackBar(
          content: Text(
              "Failed to start server. HTTP Status code ${startRequest.statusCode}.")));
      return;
    }

    remotePort = await portNumber();

    _waitForRunTimeout = 25;

    waitForRun = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await getStatus();

      _waitForRunTimeout--;
      if (_waitForRunTimeout <= 0) {
        _serverHasStarted();
      }

      if (runStatus == RunStatus.running) {
        _serverHasStarted();
        //await tryConnect();
        //print("tc");
      }

      if (runStatus == RunStatus.stopped) {
        _serverHasStarted();
      }
    });
  }

  void _serverHasStarted() async {
    if (waitForRun != null) {
      waitForRun!.cancel();
      waitForRun = null;
    }
    await portNumber();
    await getStatus();
  }

  void stopServer(ScaffoldMessengerState notifyOnError) async {
    if (safetyLock) {
      return;
    }

    /* if (await getStatus() != RunStatus.running) {
      notifyOnError.clearSnackBars();
      notifyOnError.showSnackBar(
          SnackBar(content: Text("Cannot stop a server that isn't running.")));
      return;
    } */

    final requestStop = await share.client.post(
        Uri.parse(
            "http://${share.serverIP}:${share.serverPort}/instance/$uuid/game/stop"),
        headers: {"x-username": share.username, "x-password": share.password});

    _waitForRunTimeout = 25;

    waitForRun = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await getStatus();

      _waitForRunTimeout--;
      if (_waitForRunTimeout <= 0) {
        _serverHasStarted();
      }

      if (runStatus == RunStatus.stopped) {
        _serverHasStarted(); // Would be the same code if it stopped.
        safetyLock = true;
        Future.delayed(Duration(seconds: 20), () {
          safetyLock = false;
        });
      }
    });
  }

  void kill() async {
    final requestStop = await share.client.post(
        Uri.parse(
            "http://${share.serverIP}:${share.serverPort}/instance/$uuid/game/kill"),
        headers: {"x-username": share.username, "x-password": share.password});
  }

  void sendCommand(String command, ScaffoldMessengerState notify) async {
    if (runStatus != RunStatus.running) {
      return;
    }

    final sendCmd = await share.client.post(
        Uri.parse(
            "http://${share.serverIP}:${share.serverPort}/instance/$uuid/game/sendCmd"),
        headers: {
          "x-username": share.username,
          "x-password": share.password,
          "x-command": command
        });
  }

  void addSDPKey(String kvPair, ScaffoldMessengerState notify) async {
    if (runStatus != RunStatus.stopped) {
      return;
    }

    final trySplit = kvPair.split("=");
    if (trySplit.length != 2) {
      notify.clearSnackBars();
      notify.showSnackBar(
          SnackBar(content: Text("Server.properties kv mismatch (!= 2)")));
      return;
    }

    final sender = await share.client.put(
        Uri.parse(
            "http://${share.serverIP}:${share.serverPort}/instance/$uuid/sdp/addMixin"),
        headers: {"x-username": share.username, "x-password": share.password},
        body: "key=${trySplit.first}&value=${trySplit.last}");

    final srefresh = await share.client.post(
        Uri.parse(
            "http://${share.serverIP}:${share.serverPort}/instance/$uuid/sdp/refresh"),
        headers: {"x-username": share.username, "x-password": share.password});
  }
}

enum RunStatus { running, starting, stopped }
