import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mpickflutter/Helpers/super_mc_share.dart';
import 'package:mpickflutter/Misc/version.dart';
import 'package:mpickflutter/UI/Bottom%20Sheets/server_debug.dart';
import 'package:mpickflutter/UI/change_password_alert.dart';
import 'package:mpickflutter/UI/setup.dart';
import 'package:mpickflutter/UI/Bottom Sheets/changelog.dart';

class SettingsMenu extends StatefulWidget {
  SettingsMenu({required this.client, Key? key}) : super(key: key);

  final SuperMCShare client;

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<SettingsMenu> {
  String serverVersion = "Getting server version";
  String serverDate = "Getting server date";
  String serverCompat = "Getting server compatibility.";

  bool servLock = false;

  void _servCompatibility() async {
    if (servLock) {
      return;
    }
    servLock = true;
    var gsv = await widget.client.client.get(Uri.parse(
        "http://${widget.client.serverIP}:${widget.client.serverPort}/version"));

    if (gsv.statusCode == 200) {
      setState(() {
        serverVersion = gsv.body;
      });
    }

    var gsd = await widget.client.client.get(Uri.parse(
        "http://${widget.client.serverIP}:${widget.client.serverPort}/version/date"));

    if (gsd.statusCode == 200) {
      setState(() {
        serverDate = gsd.body;
      });
    }

    var gsc = await widget.client.client.get(Uri.parse(
        "http://${widget.client.serverIP}:${widget.client.serverPort}/version/compatibility"));

    if (gsc.statusCode == 200) {
      setState(() {
        serverCompat = gsc.body;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _servCompatibility();
    return Container(
      padding: const EdgeInsets.all(25),
      child: ListView(children: [
        const Text(
          "Settings",
          style: TextStyle(fontSize: 45, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        const Divider(thickness: 2),
        // TODO: Account MGMT thru GUI
        Material(
          child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return ChangelogWidget();
                }));
              },
              child: SizedBox(
                child: Row(
                  children: const [
                    Icon(
                      Icons.history,
                      size: 25,
                    ),
                    SizedBox.square(dimension: 5),
                    Text(
                      "Changelog",
                      style: TextStyle(fontSize: 25),
                    ),
                    Spacer(),
                    IconButton(
                        padding: EdgeInsets.zero,
                        disabledColor: Colors.black,
                        hoverColor: Colors.red,
                        onPressed: null,
                        icon: Icon(
                          Icons.chevron_right,
                          size: 35,
                        ))
                  ],
                ),
                width: double.infinity,
                height: 50,
              )),
        ),
        Material(
          child: InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return changePasswordAlert(context, widget.client);
                    });
              },
              child: SizedBox(
                child: Row(
                  children: const [
                    Icon(
                      Icons.password,
                      size: 25,
                    ),
                    SizedBox.square(dimension: 5),
                    Text(
                      "Change Password",
                      style: TextStyle(fontSize: 25),
                    ),
                    Spacer(),
                    IconButton(
                        padding: EdgeInsets.zero,
                        disabledColor: Colors.black,
                        hoverColor: Colors.red,
                        onPressed: null,
                        icon: Icon(
                          Icons.chevron_right,
                          size: 35,
                        ))
                  ],
                ),
                width: double.infinity,
                height: 50,
              )),
        ),
        Material(
          child: InkWell(
              onTap: () async {
                await widget.client.willLogOut();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return SetupWidget();
                }));
              },
              child: SizedBox(
                child: Row(
                  children: const [
                    Icon(
                      Icons.logout,
                      size: 25,
                    ),
                    SizedBox.square(dimension: 5),
                    Text(
                      "Logout",
                      style: TextStyle(fontSize: 25),
                    ),
                    Spacer(),
                    Text(
                      "WARNING: Saved login will be deleted.",
                      style: TextStyle(color: Colors.red),
                    ),
                    IconButton(
                        padding: EdgeInsets.zero,
                        disabledColor: Colors.black,
                        hoverColor: Colors.red,
                        onPressed: null,
                        icon: Icon(
                          Icons.chevron_right,
                          size: 35,
                        ))
                  ],
                ),
                width: double.infinity,
                height: 50,
              )),
        ),
        Material(
          child: InkWell(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return ServerDebugSheet(widget.client);
                    });
              },
              child: SizedBox(
                child: Row(
                  children: const [
                    Icon(
                      Icons.dns,
                      size: 25,
                    ),
                    SizedBox.square(dimension: 5),
                    Text(
                      "Server Debug",
                      style: TextStyle(fontSize: 25),
                    ),
                    Spacer(),
                    IconButton(
                        padding: EdgeInsets.zero,
                        disabledColor: Colors.black,
                        hoverColor: Colors.red,
                        onPressed: null,
                        icon: Icon(
                          Icons.chevron_right,
                          size: 35,
                        ))
                  ],
                ),
                width: double.infinity,
                height: 50,
              )),
        ),
        const Divider(),
        Text(
          "Minepicker version $mp_version",
          style: GoogleFonts.notoSansMono(fontSize: 15),
        ),
        Text(
          mp_reldate,
          style: GoogleFonts.notoSansMono(fontSize: 15),
        ),
        SizedBox.square(dimension: 10),
        Text(
          "Backend server version $serverVersion",
          style: GoogleFonts.notoSansMono(fontSize: 15),
        ),
        Text(
          serverDate,
          style: GoogleFonts.notoSansMono(fontSize: 15),
        ),
        Text(
          serverCompat,
          style: GoogleFonts.notoSansMono(fontSize: 15),
        )
      ]),
    );
  }
}
