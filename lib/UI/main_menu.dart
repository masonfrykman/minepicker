import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mpickflutter/Helpers/super_mc_share.dart';
import 'package:mpickflutter/Helpers/world.dart';
import 'package:mpickflutter/UI/bottom_sheets_main_menu.dart';
import 'package:mpickflutter/UI/world_tile.dart';

class MainAppWidget extends StatefulWidget {
  const MainAppWidget({Key? key, required this.share}) : super(key: key);

  final SuperMCShare share;

  @override
  MainMenuState createState() => MainMenuState();
}

class MainMenuState extends State<MainAppWidget> {
  Widget? currentBody;
  String? title;

  SuperMCShare get client {
    return widget.share;
  }

  void buildCurrentOptionView(BuildContext context) async {
    await client.prepareVersionsListIfEmpty();
    if (client.worlds.isEmpty) {
      setState(() {
        title = "Worlds";
        currentBody = const Text(
            "No worlds found. You can add more with the +.",
            textAlign: TextAlign.center);
      });
      return;
    }

    final build = <Widget>[];
    for (World instw in client.worlds) {
      build.add(WorldTile(instw, client: client));
    }

    setState(() {
      title = "Worlds";
      currentBody = ListView(children: build);
    });
  }

  @override
  Widget build(BuildContext context) {
    buildCurrentOptionView(context);
    return Scaffold(
      persistentFooterButtons: [
        TextButton.icon(
            onPressed: () async {
              await widget.share.commitManifest();
            },
            icon: const Icon(Icons.arrow_downward),
            label: const Text("Commit Trash")),
        TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SettingsMenu(client: client);
                  });
            },
            icon: const Icon(Icons.settings),
            label: const Text("Settings")),
        TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return CreateWorldSheetWidget(client: client);
                  });
            },
            icon: const Icon(Icons.add),
            label: const Text("Create world")),

        // TextButton.icon(
        //     onPressed: () {},
        //     icon: const Icon(Icons.delete),
        //     label: const Text("Trash world")),
        //TextButton.icon(
        //    onPressed: () {},
        //    icon: const Icon(Icons.restore_from_trash),
        //    label: const Text("Restore world"))
      ],
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(title.toString()),
        actions: [
          IconButton(
              onPressed: () async {
                await client.listInstances();
                setState(() {
                  buildCurrentOptionView(context);
                });
              },
              icon: const Icon(Icons.refresh)),
          const SizedBox.square(dimension: 15)
        ],
      ),
      body: currentBody,
      /*floatingActionButton: FloatingActionButton(
            onPressed: () {
              return;
            },
            tooltip: "Create a world",
            child: const Icon(Icons.add))*/
    );
  }
}

enum MainMenuOption { loadWorld, manageWorld }
