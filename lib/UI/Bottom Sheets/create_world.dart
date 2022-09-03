import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mpickflutter/Helpers/super_mc_share.dart';

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
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.white),
            )),
        const SizedBox.square(dimension: 10),
        ElevatedButton(
          onPressed: (() {
            _formKey.currentState?.reset();
          }),
          child: const Text(
            "Reset",
            style: TextStyle(color: Colors.white),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red)),
        )
      ]),
    );
  }
}
