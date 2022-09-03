import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mpickflutter/Helpers/world.dart';

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
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            )),
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
          child: const Text(
            "Submit",
            style: TextStyle(color: Colors.white),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red)),
        )
      ]),
    );
  }
}
