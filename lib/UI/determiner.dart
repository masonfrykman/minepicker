import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mpickflutter/Helpers/determine_installation.dart';
import 'package:mpickflutter/UI/main_menu.dart';
import 'package:mpickflutter/UI/setup.dart';
import 'package:mpickflutter/Helpers/super_mc_share.dart';

class Determiner extends StatelessWidget {
  const Determiner({Key? key}) : super(key: key);

  void startDetermine(BuildContext context) async {
    var determine = await SuperMCShare.loadCredentialsFromDisk();
    if (determine == null) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return SetupWidget();
      }));
    } else {
      // TODO: Go to landing.
      // Verify loaded credentials.
      try {
        await Client().read(
            Uri.parse("http://${determine['ip']}:${determine['port']}"),
            headers: {
              "x-username": determine["username"],
              "x-password": determine["password"]
            });
      } catch (err) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return SetupWidget();
        }));
        return;
      }

      try {
        var ccheck = await Client()
            .post(
                Uri.parse(
                    "http://${determine['ip']}:${determine['port']}/account/check"),
                body:
                    "username=${determine['username']}&password=${determine['password']}")
            .timeout(const Duration(seconds: 5));

        if (ccheck.statusCode != 200) {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) {
            return SetupWidget();
          }));
          return;
        }
      } on TimeoutException {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return SetupWidget();
        }));
        return;
      }

      final share = SuperMCShare(
          username: determine["username"],
          password: determine["password"],
          serverIP: determine["ip"],
          serverPort: determine["port"]);

      await share.listInstances();

      ScaffoldMessenger.of(context).clearSnackBars();
      final MainAppWidget nw = MainAppWidget(share: share);

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return nw;
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    startDetermine(context);
    return Scaffold(
      body: Center(
        child: Row(
          children: const [
            CircularProgressIndicator(color: Colors.lightGreen),
            Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text("Detecting existing installation. One sec plz.",
                    style: TextStyle(fontWeight: FontWeight.w300)))
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
