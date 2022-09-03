/*import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mpickflutter/Helpers/world.dart';

class SocketHandler {
  Socket? socket;
  World world;

  SocketHandler(this.world);

  List<Text> runningMessages = [];
  int runningMessagesCeiling = 50;

  Future<bool> tryConnect() async {
    var getSockAddr = await world.share.client.get(
        Uri.parse(
            "http://${world.share.serverIP}:${world.share.serverPort}/instance/${world.uuid}/socket/stdout"),
        headers: {
          "x-username": world.share.username,
          "x-password": world.share.password
        });
    if (getSockAddr.statusCode != 200) {
      return false;
    }

    var addr = getSockAddr.body.split(":");
    var ip = addr[0];
    var port = int.tryParse(addr[1]);
    if (port == null) {
      return false;
    }

    socket = await Socket.connect(ip, port);
    socket!.listen((event) => _handleMessage(Utf8Decoder().convert(event)));
    //_handleMessage("WANTSAUTH");
    return true;
  }

  void _handleMessage(String message) {
    print("mmmmmm + $message");
    if (socket == null) {
      return;
    }

    print(message);

    if (message == "WANTSAUTH") {
      socket!.write("AUTH; ${world.share.username}; ${world.share.password}");
      socket!.flush();
      return;
    }
    _pushAndPopIfNeeded(message);
  }

  void _pushAndPopIfNeeded(String serverStdoutMsg) {
    runningMessages.add(Text(serverStdoutMsg));
    while (runningMessages.length > 100) {
      runningMessages.removeAt(0);
    }
  }

  void done() {
    socket?.close();
    socket = null;
  }
}
*/