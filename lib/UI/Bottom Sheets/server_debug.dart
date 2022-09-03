import 'package:flutter/material.dart';
import 'package:mpickflutter/Helpers/super_mc_share.dart';

class ServerDebugSheet extends StatelessWidget {
  ServerDebugSheet(this.share);

  final SuperMCShare share;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: ListView(children: [
        const Text(
          "Server Debug",
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
                Navigator.of(context).pop();
              },
              child: SizedBox(
                child: Row(
                  children: const [
                    Icon(
                      Icons.arrow_back,
                      size: 25,
                    ),
                    SizedBox.square(dimension: 5),
                    Text(
                      "Back",
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
                await share.resetAllInstanceStates();
              },
              child: SizedBox(
                child: Row(
                  children: const [
                    Icon(
                      Icons.refresh,
                      size: 25,
                    ),
                    SizedBox.square(dimension: 5),
                    Text(
                      "Reset instance states",
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
        /* Material(
          child: InkWell(
              onTap: () async {},
              child: SizedBox(
                child: Row(
                  children: const [
                    Icon(
                      Icons.bolt,
                      size: 25,
                    ),
                    SizedBox.square(dimension: 5),
                    Text(
                      "Restart server software",
                      style: TextStyle(fontSize: 25),
                    ),
                    Spacer(),
                    Text(
                      "All unsaved data will be lost.",
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
        ), */
        Material(
          child: InkWell(
              onTap: () async {
                final refreshCmd = await share.refreshRemoteVersionsList();
                if (!refreshCmd) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text("Failed to refresh remote versions list.")));
                }
              },
              child: SizedBox(
                child: Row(
                  children: const [
                    Icon(
                      Icons.restart_alt,
                      size: 25,
                    ),
                    SizedBox.square(dimension: 5),
                    Text(
                      "Force refresh of versions list",
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
      ]),
    );
  }
}
