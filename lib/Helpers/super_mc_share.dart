import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mpickflutter/Helpers/determine_installation.dart';

import 'dart:convert';
import 'dart:io';

import '../Helpers/world.dart';

class SuperMCShare {
  SuperMCShare(
      {required this.username,
      required this.password,
      required this.serverIP,
      required this.serverPort});

  String username;
  String password;
  late String serverIP;
  late int serverPort;

  List<World> worlds = [];

  List<String> hideUuids = [];
  bool firstTimeHide = true;

  List<String> versions = [];

  Client client = Client();

  void hideWorld(World world) {
    if (hideUuids.contains(world.uuid)) {
      return;
    }
    hideUuids.add(world.uuid);
  }

  void unhideWorld(World world) => hideUuids.remove(world.uuid);

  Future<void> tryLoadHide() async {
    final iDir = await getInstallation();
    if (iDir == null) {
      return;
    }

    if (await File("$iDir/hasHidden.cfg").exists()) {
      if ((await File("$iDir/hasHidden.cfg").readAsString()).trim() == "true") {
        firstTimeHide = false;
      }
    }

    if (await File("$iDir/hidden.cfg").exists()) {
      hideUuids = await File("$iDir/hidden.cfg").readAsLines();
      if (hideUuids.isNotEmpty) {
        firstTimeHide = false;
      }
    }
  }

  Future<void> saveHide() async {
    final iDir = await getInstallation();
    if (iDir == null) {
      return;
    }

    await Directory(iDir).create(recursive: true);

    final hf = File("$iDir/hidden.cfg").openWrite();

    for (String hiddenUUID in hideUuids) {
      hf.writeln(hiddenUUID);
    }

    await hf.flush();
    await hf.close();

    await File("$iDir/hasHidden.cfg")
        .writeAsString(firstTimeHide == true ? "false" : "true");
  }

  Future<void> saveHideSilent() async {
    try {
      await saveHide();
    } catch (err) {
      var b = err;
    }
  }

  Future<bool> saveCredentialsToDisk() async {
    var iDir = await getInstallation();
    if (iDir == null) {
      return false;
    }

    await Directory(iDir).create(recursive: true);

    await File("${iDir}/mpl.json").writeAsString(JsonEncoder().convert({
      "username": username,
      "password": password,
      "ip": serverIP,
      "port": serverPort
    }));
    return true;
  }

  Future<bool> changePassword(String oldPass, String newPass) async {
    if (oldPass.trim() != password ||
        newPass == password ||
        oldPass == newPass ||
        newPass.trim().isEmpty) {
      return false;
    }

    final sender = await client.post(
        Uri.parse("http://$serverIP:$serverPort/account/changePassword"),
        body: "username=$username&old-password=$oldPass&new-password=$newPass");

    if (sender.statusCode != 200) {
      return false;
    }
    return true;
  }

  Future<bool> willLogOut() async {
    var iDir = await getInstallation();
    if (iDir == null) {
      return false;
    }
    try {
      await File("${iDir}/mpl.json").delete(recursive: true);
    } on FileSystemException {
      return false;
    }

    return true;
  }

  static Future<dynamic> loadCredentialsFromDisk() async {
    var iDir = await getInstallation();
    if (iDir == null) {
      return null;
    }

    if (!await File("${iDir}/mpl.json").exists()) {
      return null;
    }

    var jbody =
        JsonDecoder().convert(await File("${iDir}/mpl.json").readAsString());

    return jbody;
  }

  Future<bool> verifyCredentials() async {
    final reqToServ = await client.post(
        Uri.parse("http://$serverIP:$serverPort/account/check"),
        body: "username=$username&password=$password");

    if (reqToServ.statusCode != 200) {
      return false;
    }
    return true;
  }

  Future<void> listInstances() async {
    final req = await client.get(
        Uri.parse("http://$serverIP:$serverPort/instance/list"),
        headers: {"x-username": username, "x-password": password});

    if (req.statusCode != 200) {
      return;
    }
    if (req.headers["content-type"] != "application/json") {
      return;
    }

    final worldsJSON = JsonDecoder().convert(req.body);
    worlds.clear();
    for (dynamic world in worldsJSON) {
      if (world["name"] == null || world["uuid"] == null) {
        continue;
      }

      final newWorld = World(world["name"], world["uuid"], share: this);
      worlds.add(newWorld);
    }
  }

  Future<void> resetAllInstanceStates() async {
    final req = await client.post(
        Uri.parse("http://$serverIP:$serverPort/instance/resetAllStates"),
        headers: {"x-username": username, "x-password": password});

    if (req.statusCode != 200) {
      return;
    }
  }

  Future<void> prepareVersionsListIfEmpty() async {
    if (versions.isEmpty) {
      await prepareVersionsList();
    }
  }

  Future<void> prepareVersionsList() async {
    final req = await client
        .get(Uri.parse("http://$serverIP:$serverPort/versionctrl/list"));

    if (req.statusCode != 200) {
      if (versions.isEmpty) {
        // Only overwrite if it doesn't already have some versions.
        versions = ["Failed to get versions list."];
      }
      return;
    }

    if (versions.isNotEmpty) {
      versions = [];
    }

    for (dynamic worldJSONRep in JsonDecoder().convert(req.body)) {
      if (worldJSONRep["name"] == null) {
        continue;
      }

      versions.add(worldJSONRep["name"]!);
    }
  }

  Future<bool> refreshRemoteVersionsList() async {
    final req = await client.post(
        Uri.parse("http://$serverIP:$serverPort/versionctrl/refresh"),
        headers: {"x-username": username, "x-password": password});

    if (req.statusCode != 200) {
      return false;
    }

    await prepareVersionsList();
    return true;
  }

  Future<String> submitWorldCreation(String name, String version,
      {String? maxMemory, String? minMemory, String? motd}) async {
    String reqBdy = "name=$name&version=$version";

    if (maxMemory != null) {
      reqBdy += "&max-memory=$maxMemory";
    }
    if (minMemory != null) {
      reqBdy += "&min-memory=$minMemory";
    }

    final sender = await client.put(
        Uri.parse("http://$serverIP:$serverPort/instance/new"),
        body: reqBdy,
        headers: {"X-Username": username, "X-Password": password});

    if (sender.statusCode == 500) {
      return "ERROR: An Internal Server Error occured. (Code 500)";
    } else if (sender.statusCode == 401 || sender.statusCode == 403) {
      return "ERROR: Incorrect server credentials.";
    } else if (sender.statusCode != 200) {
      return "ERROR: An unknown HTTP status code was returned: ${sender.statusCode}";
    }

    if (sender.headers["content-type"] != "application/json") {
      return "ERROR: Server did not respond with a JSON body.";
    }

    final worldData = JsonDecoder().convert(sender.body);
    if (worldData["uuid"] == null) {
      return "ERROR: Server did not send back UUID (Universally Unique Identifier). Try refreshing the world list.";
    }

    final worldCreation = World(name, worldData["uuid"], share: this);
    worldCreation.version = version;

    worlds.add(worldCreation);
    return "Successfully created world. ($name, ${worldData["uuid"]})";
  }

  Future<String> getStatusOfUUID(String uuid) async {
    final sender = await client.get(
        Uri.parse("http://$serverIP:$serverPort/instance/$uuid/game/status"),
        headers: {"X-Username": username, "X-Password": password});
    if (sender.statusCode != 200) {
      return "Non-OK response code. (${sender.statusCode} -- ${sender.body}).";
    }
    return sender.body;
  }

  Future<bool> deleteByUUID(String uuid) async {
    final sender = await client.delete(
        Uri.parse("http://$serverIP:$serverPort/instance/$uuid/trash"),
        headers: {"x-username": username, "x-password": password});

    if (sender.statusCode != 200) {
      return false;
    }
    await listInstances();
    return true;
  }

  Future<bool> commitManifest() async {
    final sender = await client.post(
        Uri.parse("http://$serverIP:$serverPort/instance/manifest/save"),
        headers: {"x-username": username, "x-password": password});

    if (sender.statusCode != 200) {
      return false;
    }
    await listInstances();
    return true;
  }
}
