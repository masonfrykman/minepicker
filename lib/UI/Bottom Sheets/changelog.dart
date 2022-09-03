import 'package:flutter/material.dart';

class ChangelogWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: Container(
          padding: const EdgeInsets.all(25),
          child: ListView(children: const [
            Text(
              "Changelog",
              style: TextStyle(fontSize: 45, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            Divider(thickness: 2),
            SizedBox.square(dimension: 10),
            Text(
              "NALA patch 1",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              "September 3, 2022",
              style: TextStyle(fontSize: 20),
            ),
            Text("(you are here)"),
            SizedBox.square(dimension: 10),
            Text('''\u2022 Interface
    \t\u2022 Added dark mode
    \t\u2022 Changed color scheme's primary color from Blue to Deep Purple
    \t\u2022 Changed widgets to be more colorful
\u2022 Server debug options
    \t\u2022 Force refresh of remote versions list
    \t\u2022 Reset remote instance states
\u2022 Improved hang prevention on startup with connection timeouts
\u2022 Added Advertise via mDNS start option to allow the instance to automatically pop up in the Multiplayer menu
\u2022 Fixed issue where local versions list was not clear when being refreshed.'''),
            SizedBox.square(dimension: 10),
            Divider(),
            SizedBox.square(dimension: 10),
            Text(
              "SIMBA patch 4",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              "July 28, 2022",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox.square(dimension: 10),
            Text('''\u2022 Static port support'''),
            SizedBox.square(dimension: 10),
            Divider(),
            SizedBox.square(dimension: 10),
            Text(
              "SIMBA patch 3",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              "July 26, 2022",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox.square(dimension: 10),
            Text('''\u2022 Added actual settings in the settings menu.
\u2022 Added Change password & Logout settings options.
\u2022 Added killing a world instance.
\u2022 Added dashboard widget to show server IP & port of the instance.
\u2022 Changed delete "Are you sure" dialog to a math challenge.
\u2022 Combined start & stop buttons into one.
\u2022 Fixed text alignment in the player list widget.
\u2022 Fixed text overflow on a main menu world entry title.
\u2022 Fixed other miscellaneous bugs.'''),
            SizedBox.square(dimension: 10),
            Divider(),
            SizedBox.square(dimension: 10),
            Text(
              "SIMBA patch 2",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              "July 23, 2022",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox.square(dimension: 10),
            Text('''\u2022 Fixed getting server version
\u2022 Rolled some bugs out.'''),
            SizedBox.square(dimension: 10),
            Divider(),
            SizedBox.square(dimension: 10),
            Text(
              "SIMBA patch 1",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              "July 22, 2022",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox.square(dimension: 10),
            Text('''\u2022 Initial release! 🎉'''),
            SizedBox.square(dimension: 10),
            Divider(),
          ]),
        ));
  }
}
