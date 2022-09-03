//
// instance_mgmt_page.dart
// Instance Management Widget
// Main page to access & manage a running server instance
//

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpickflutter/Helpers/generate_math_problem.dart';
import 'package:mpickflutter/Helpers/super_mc_share.dart';
import 'package:mpickflutter/Helpers/world.dart';
import 'package:mpickflutter/UI/Bottom Sheets/edit_server_configs.dart';

class InstanceMgmtPageWidget extends StatefulWidget {
  InstanceMgmtPageWidget(this.world, {Key? key, required this.share});

  final World world;
  final SuperMCShare share;

  @override
  IMPWState createState() => IMPWState();
}

class IMPWState extends State<InstanceMgmtPageWidget> {
  Widget playersInGame = Text(
    "Loading...",
    textAlign: TextAlign.left,
  );

  Widget serverConfig = Text("Loading...");

  bool svcLock = false;

  Timer? pageRefreshTimer;
  int _lpcount = 20;

  TextEditingController sendCmdClearer = TextEditingController();
  TextEditingController SDPClearer = TextEditingController();

  @override
  void dispose() {
    if (pageRefreshTimer != null) {
      pageRefreshTimer!.cancel();
      pageRefreshTimer = null;
    }
/*     if (widget.world.stdoutHndlr != null) {
      widget.world.sockDone();
    } */
    _lpcount = 20;
    super.dispose();
  }

  Widget portWidget() {
    if (widget.world.remotePort == null) {
      return SizedBox.shrink();
    }
    return Material(
      borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
      elevation: 2,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.share.serverIP}:${widget.world.remotePort}",
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              )
            ],
          )),
    );
  }

  void _loadPlayersInGameList() async {
    List<Widget> columnChildren = [];

    for (String player in await widget.world.playersList()) {
      columnChildren.add(Text(
        player,
        style: TextStyle(color: Colors.white),
      ));
    }

    setState(() {
      playersInGame = Column(
        children: columnChildren,
        crossAxisAlignment: CrossAxisAlignment.start,
      );
    });
  }

  void _timerLP() async {
    if (pageRefreshTimer != null) {
      return;
    }

    _loadPlayersInGameList();
    pageRefreshTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      setState(() {
        _lpcount = _lpcount - 2;
      });

      if (_lpcount == 0) {
        widget.world.getStatus().then((value) {
          setState(() {
            _lpcount = 20;
            _loadPlayersInGameList();
          });
        });
      }
    });
  }

  Widget ssb() {
    if (widget.world.runStatus == RunStatus.stopped) {
      return Material(
        borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
        elevation: 5,
        color: Colors.green,
        child: InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Start Configuration"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              widget.world
                                  .startServer(ScaffoldMessenger.of(context));
                              Navigator.of(context).pop();
                            },
                            child: Text("Normal (dynamic port)")),
                        TextButton(
                            onPressed: () {
                              widget.world.startServer(
                                  ScaffoldMessenger.of(context),
                                  advertise: true);
                              Navigator.of(context).pop();
                            },
                            child: Text("Advertise via mDNS (dynamic port)")),
                        TextButton(
                            onPressed: () {
                              widget.world.startServer(
                                  ScaffoldMessenger.of(context),
                                  tryStatic: true);
                              Navigator.of(context).pop();
                            },
                            child: Text("With Static Port")),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel"))
                      ],
                    );
                  });
            },
            borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
            child: SizedBox(
              height: 200,
              width: 200,
              child: Column(
                children: const [
                  Icon(
                    Icons.thumb_up,
                    color: Colors.white,
                    size: 50,
                  ),
                  Text(
                    "Start",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.w500),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            )),
      );
    }
    return Material(
      borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
      elevation: 5,
      color: (widget.world.safetyLock == false &&
              widget.world.runStatus != RunStatus.starting)
          ? Colors.red
          : Colors.grey,
      child: InkWell(
          onTap: () {
            if (!widget.world.safetyLock &&
                widget.world.runStatus != RunStatus.starting) {
              widget.world.stopServer(ScaffoldMessenger.of(context));
            }
          },
          borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
          child: SizedBox(
            height: 200,
            width: 200,
            child: Column(
              children: const [
                Icon(
                  Icons.thumb_down,
                  color: Colors.white,
                  size: 50,
                ),
                Text(
                  "Stop",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.w500),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
          )),
    );
  }

  void _loadServerConfigs() async {
    if (svcLock) {
      return;
    }
    svcLock = true;
    List<SelectableText> gather = [];

    for (String cfgs in await widget.world.configs()) {
      gather.add(SelectableText(
        cfgs,
        cursorColor: Colors.red,
        style: TextStyle(color: Colors.white),
      ));
    }

    setState(() {
      serverConfig = Column(
        children: gather,
        crossAxisAlignment: CrossAxisAlignment.start,
      );
    });
  }

  Future<void> _deleteConfirmDialog() async {
    GlobalKey<FormState> _fk = GlobalKey<FormState>();
    var mathProb = MathProblem.random();

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Math challenge"),
            content: SingleChildScrollView(
                child: ListBody(
              children: <Widget>[
                Text(
                    "To ensure you know what you're doing, answer this math problem."),
                SizedBox.square(dimension: 10),
                Text(
                  mathProb.humanReadable,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Form(
                    key: _fk,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.disabled,
                      decoration: InputDecoration(
                          labelText: "Answer",
                          helperText:
                              "Round to the tenths place in every circumstance.\nDecimals only."),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "An answer must be submitted.";
                        }
                        if (!mathProb.check(value)) {
                          return "Incorrect answer.";
                        }
                        return null;
                      },
                    ))
              ],
            )),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () async {
                    if (_fk.currentState == null) {
                      return;
                    }
                    if (!_fk.currentState!.validate()) {
                      return;
                    }

                    if (await widget.share.deleteByUUID(widget.world.uuid)) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Successfully deleted instance ${widget.world.name}.")));
                    } else {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Failed to delete instance ${widget.world.name}.")));
                    }
                  },
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.blue),
                  )),
              //TextButton(onPressed: onPressed, child: child)
            ],
          );
        });
  }

  Widget statLine() {
    if (widget.world.runStatus == RunStatus.running) {
      return Material(
        color: Colors.green,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.thumb_up,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox.square(dimension: 5),
                  Text("Running",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))
                ],
              )),
        ),
      );
    } else if (widget.world.runStatus == RunStatus.starting) {
      return Material(
        color: Colors.yellow[600],
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.thumbs_up_down,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox.square(dimension: 5),
                  Text("Starting",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))
                ],
              )),
        ),
      );
    }
    return Material(
      color: Colors.red,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.thumb_down,
                  size: 18,
                  color: Colors.white,
                ),
                SizedBox.square(dimension: 5),
                Text("Stopped",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))
              ],
            )),
      ),
    );
  }

/*
  void _tryCon() async {
    if (widget.world.runStatus == RunStatus.running) {
      await widget.world.tryConnect();
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    _loadServerConfigs();
    _timerLP();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              "Refresh in $_lpcount seconds. Some elements may refresh more frequently.",
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontFamily: "Roboto", fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
      body: ListView(padding: EdgeInsets.only(top: 0), children: [
        Material(
          child: SizedBox(
            child: DecoratedBox(
              decoration: BoxDecoration(
                  gradient: MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                              Color.fromRGBO(102, 126, 234, 1),
                              Color.fromRGBO(118, 75, 162, 1)
                            ])
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [
                              0,
                              0.48,
                              1,
                            ],
                          colors: [
                              Color.fromRGBO(172, 50, 228, 1),
                              Color.fromRGBO(122, 24, 242, 1),
                              Color.fromRGBO(72, 1, 255, 1),
                            ])),
              child: Align(
                child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      widget.world.name,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.height / 8,
                          fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                    )),
                alignment: Alignment.center,
              ),
            ),
            height: MediaQuery.of(context).size.height / 3,
            width: double.infinity,
          ),
          elevation: 4,
        ),
        statLine(),
        Padding(
            padding: EdgeInsets.all(15).add(EdgeInsets.only(top: 10)),
            child: Align(
                alignment: Alignment.center,
                child: Wrap(
                  runSpacing: 10,
                  spacing: 20,
                  children: [
                    ssb(),
                    Material(
                      borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
                      elevation: 5,
                      color: Colors.black,
                      child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Kill world?"),
                                    content: Text(
                                        "This will terminate the world's server process abruptly.\nONLY USE IF YOU BELIEVE THERE IS AN IRRECOVERABLE CATASTROPHIC ERROR.\nUnsaved changes will be lost."),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            return;
                                          },
                                          child: Text("Cancel")),
                                      TextButton(
                                          onPressed: () {
                                            widget.world.kill();
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Status will not update until next refresh. (see top left)")));
                                          },
                                          child: Text(
                                            "I understand, kill the instance.",
                                            style: TextStyle(color: Colors.red),
                                          ))
                                    ],
                                  );
                                });
                          },
                          borderRadius:
                              BorderRadius.all(Radius.elliptical(10, 10)),
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                Text(
                                  "Kill",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 50,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                            ),
                          )),
                    ),
                    Material(
                      borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
                      elevation: 5,
                      color: Colors.redAccent,
                      child: InkWell(
                          onTap: () {
                            _deleteConfirmDialog();
                          },
                          enableFeedback:
                              widget.world.runStatus == RunStatus.stopped
                                  ? true
                                  : false,
                          borderRadius:
                              BorderRadius.all(Radius.elliptical(10, 10)),
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                Text(
                                  "Delete",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 50,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                            ),
                          )),
                    ),
                  ],
                ))),
        Padding(
          padding: EdgeInsets.all(15),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              portWidget(),
              widget.world.runStatus == RunStatus.running
                  ? Material(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius:
                          const BorderRadius.all(Radius.elliptical(5, 5)),
                      elevation: 2,
                      child: SizedBox(
                        child: Padding(
                          child: Material(
                            child: Padding(
                              child: TextFormField(
                                controller: sendCmdClearer,
                                cursorColor: Colors.white,
                                style: TextStyle(color: Colors.white),
                                onFieldSubmitted: (value) {
                                  widget.world.sendCommand(
                                      value, ScaffoldMessenger.of(context));
                                  sendCmdClearer.clear();
                                },
                                decoration: InputDecoration(
                                    enabled: widget.world.runStatus ==
                                            RunStatus.running
                                        ? true
                                        : false,
                                    hintText: "Send command",
                                    helperText:
                                        "Hit enter to send. Command has no effect if instance is stopped or starting.",
                                    helperStyle:
                                        TextStyle(color: Colors.white60),
                                    hintStyle: TextStyle(color: Colors.white60),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white60)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white))),
                              ),
                              padding: EdgeInsets.all(5),
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.elliptical(5, 5)),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          padding: EdgeInsets.all(15),
                        ),
                        width: 500,
                      ),
                    )
                  : SizedBox.shrink(),
              /*  widget.world.runStatus == RunStatus.running
                  ? Material(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius:
                          const BorderRadius.all(Radius.elliptical(5, 5)),
                      elevation: 2,
                      child: SizedBox(
                        child: Padding(
                          child: Material(
                            child: Padding(
                              child: ListView(
                                children:
                                    widget.world.stdoutHndlr?.runningMessages ??
                                        [Text("No socket to connect to.")],
                              ),
                              padding: EdgeInsets.all(5),
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.elliptical(5, 5)),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          padding: EdgeInsets.all(15),
                        ),
                        width: 400,
                        height: 150,
                      ),
                    )
                  : SizedBox.shrink(), */
              widget.world.runStatus == RunStatus.running
                  ? Material(
                      borderRadius:
                          const BorderRadius.all(Radius.elliptical(5, 5)),
                      elevation: 2,
                      color: Theme.of(context).colorScheme.primary,
                      child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Player List",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox.square(dimension: 15),
                              playersInGame
                            ],
                          )),
                    )
                  : SizedBox.shrink(),
              widget.world.runStatus == RunStatus.stopped
                  ? Material(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius:
                          const BorderRadius.all(Radius.elliptical(5, 5)),
                      elevation: 2,
                      child: SizedBox(
                        child: Padding(
                          child: Material(
                              child: Padding(
                                child: TextFormField(
                                  controller: SDPClearer,
                                  onFieldSubmitted: (value) {
                                    widget.world.addSDPKey(
                                        value, ScaffoldMessenger.of(context));
                                    SDPClearer.clear();
                                  },
                                  enabled: widget.world.runStatus ==
                                          RunStatus.stopped
                                      ? true
                                      : false,
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                      hintText: "Add server.properties key",
                                      helperText: "Hit enter to send.",
                                      helperStyle:
                                          TextStyle(color: Colors.white60),
                                      hintStyle:
                                          TextStyle(color: Colors.white60),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white60)),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white))),
                                ),
                                padding: EdgeInsets.all(5),
                              ),
                              borderRadius: const BorderRadius.all(
                                  Radius.elliptical(5, 5)),
                              color: Theme.of(context).colorScheme.secondary),
                          padding: EdgeInsets.all(15),
                        ),
                        width: 500,
                      ),
                    )
                  : SizedBox.shrink(),
              Material(
                borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
                elevation: 2,
                color: Theme.of(context).colorScheme.primary,
                child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Server configuration",
                          style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox.square(dimension: 15),
                        serverConfig,
                        SizedBox.square(dimension: 15),
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return EditServerConfigs(widget.world);
                                });
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          tooltip: "Edit",
                        )
                      ],
                    )),
              ),
            ],
            runSpacing: 15,
            spacing: 15,
          ),
        ),

        /*OverflowBox(
          child: Row(
            children: [],
          ),
        )*/
      ]),
    );
  }
}
