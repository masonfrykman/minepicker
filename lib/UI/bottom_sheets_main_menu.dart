import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mpickflutter/Helpers/super_mc_share.dart';
import 'package:mpickflutter/Helpers/world.dart';
import 'package:mpickflutter/UI/change_password_alert.dart';
import 'package:mpickflutter/UI/setup.dart';

class CreateWorldSheetWidget extends StatefulWidget {
  CreateWorldSheetWidget({required this.client, Key? key}) : super(key: key);

  final SuperMCShare client;

  @override
  CreateWorldSheetState createState() => CreateWorldSheetState();
}

class CreateWorldSheetState extends State<CreateWorldSheetWidget> {
  String releaseVersion() {
    return widget.client.versions.first;
  }

  String dropdownCurrentValue = "!! SELECT VERSION !!";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController maxMemCtrl = TextEditingController();
  final TextEditingController minMemCtrl = TextEditingController();
  final TextEditingController motdCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: ListView(children: [
        const Text(
          "Create world",
          style: TextStyle(fontSize: 45, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        const Divider(thickness: 2),
        Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(color: Colors.blueGrey)),
                  validator: (value) {
                    if (value == null) {
                      return "World name is required.";
                    }
                    if (value.isEmpty) {
                      return "World name is required.";
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField(
                    validator: (String? value) {
                      if (value == null) {
                        return "A version must be selected.";
                      }
                      if (value == "!! SELECT VERSION !!") {
                        return "A version must be selected.";
                      }
                      return null;
                    },
                    value: dropdownCurrentValue,
                    items: <String>["!! SELECT VERSION !!"]
                        .followedBy(widget.client.versions)
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: const TextStyle(color: Colors.blueGrey)));
                    }).toList(),
                    onChanged: (String? text) {
                      if (text != null) {
                        setState(() {
                          dropdownCurrentValue = text;
                        });
                      }
                    }),
                const Divider(),
                TextFormField(
                  controller: maxMemCtrl,
                  decoration: const InputDecoration(
                      labelText: "Maximum memory allocation",
                      suffixText: "MB",
                      labelStyle: TextStyle(color: Colors.blueGrey)),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                TextFormField(
                  controller: minMemCtrl,
                  decoration: const InputDecoration(
                      labelText: "Minimum memory allocation",
                      helperText:
                          "1 GB = 1024 MB\nLeave blank to use server default",
                      suffixText: "MB",
                      labelStyle: TextStyle(color: Colors.blueGrey)),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            )),
        const SizedBox.square(dimension: 10),
        ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState == null) {
                setState(() {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(
                    children: const [
                      SizedBox.square(dimension: 15),
                      Text("Failed to validate form fields.")
                    ],
                  )));
                });
                return;
              }

              final validate = _formKey.currentState!.validate();
              if (!validate) {
                return;
              }

              String? maxMemCapt;
              String? minMemCapt;
              if (maxMemCtrl.text.isNotEmpty) {
                maxMemCapt = maxMemCtrl.text;
              }
              if (minMemCtrl.text.isNotEmpty) {
                minMemCapt = minMemCtrl.text;
              }

              await widget.client.submitWorldCreation(
                  nameCtrl.text, dropdownCurrentValue,
                  maxMemory: maxMemCapt, minMemory: minMemCapt);
              Navigator.of(context).pop();
              return;
            },
            child: const Text("Submit")),
        const SizedBox.square(dimension: 10),
        ElevatedButton(
          onPressed: (() {
            _formKey.currentState?.reset();
          }),
          child: const Text("Reset"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red)),
        )
      ]),
    );
  }
}

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
        const Divider(),
        Text(
          "Minepicker version SIMBA patch 3",
          style: GoogleFonts.notoSansMono(fontSize: 15),
        ),
        Text(
          "July 26, 2022",
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

class EditServerConfigs extends StatefulWidget {
  EditServerConfigs(this.world, {Key? key}) : super(key: key);

  final World world;

  @override
  EditServerState createState() => EditServerState();
}

class EditServerState extends State<EditServerConfigs> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController maxMemCtrl = TextEditingController();
  final TextEditingController minMemCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: ListView(children: [
        const Text(
          "Edit attributes",
          style: TextStyle(fontSize: 45, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        const Divider(thickness: 2),
        Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(color: Colors.blueGrey),
                      helperText:
                          "Leave blank to keep current value. Changing name requires full refresh to take effect."),
                  validator: (value) {
                    if (value == null) {
                      return "World name is required.";
                    }
                    if (value.isEmpty) {
                      return "World name is required.";
                    }
                    return null;
                  },
                ),
                const Divider(),
                TextFormField(
                  controller: maxMemCtrl,
                  decoration: const InputDecoration(
                      labelText: "Maximum memory allocation",
                      suffixText: "MB",
                      labelStyle: TextStyle(color: Colors.blueGrey)),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                TextFormField(
                  controller: minMemCtrl,
                  decoration: const InputDecoration(
                      labelText: "Minimum memory allocation",
                      helperText:
                          "1 GB = 1024 MB\nLeave blank to keep current values",
                      suffixText: "MB",
                      labelStyle: TextStyle(color: Colors.blueGrey)),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            )),
        const SizedBox.square(dimension: 10),
        ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        const SizedBox.square(dimension: 10),
        ElevatedButton(
          onPressed: () async {
            if (maxMemCtrl.text.isNotEmpty) {
              await widget.world
                  .patchInstanceConfig("max-memory", maxMemCtrl.text);
            }
            if (minMemCtrl.text.isNotEmpty) {
              await widget.world
                  .patchInstanceConfig("min-memory", minMemCtrl.text);
            }
            if (nameCtrl.text.isNotEmpty) {
              await widget.world.patchInstanceConfig("name", nameCtrl.text);
            }
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            return;
          },
          child: const Text("Submit"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red)),
        )
      ]),
    );
  }
}

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
              "SIMBA patch 4",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              "July 28, 2022",
              style: TextStyle(fontSize: 20),
            ),
            Text("(you are here)"),
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
