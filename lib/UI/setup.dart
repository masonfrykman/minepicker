import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:mpickflutter/Helpers/super_mc_share.dart';
import 'package:mpickflutter/UI/main_menu.dart';

class SetupWidget extends StatefulWidget {
  const SetupWidget({Key? key}) : super(key: key);

  @override
  SetupWidgetState createState() => SetupWidgetState();
}

class SetupWidgetState extends State<SetupWidget> {
  final formKey = GlobalKey<FormState>();
  bool verifying = false;

  final serverIP = TextEditingController();
  final username = TextEditingController();

  String? identity;
  final password = TextEditingController();

  void _verifyAndPass() async {
    verifying = true;
    setState(() {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Row(children: const [
              CircularProgressIndicator(),
              SizedBox.square(dimension: 15),
              Text("Verifying credentials...")
            ]),
          ),
          duration: const Duration(days: 365)));
    });
    if (formKey.currentState == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(children: const [Text("An unknown error occured (1)")]),
          ),
          duration: const Duration(seconds: 10)));
      verifying = false;
      return;
    }
    if (!formKey.currentState!.validate()) {
      // Expecting the red text to pop up under the form fields, informing the user.
      ScaffoldMessenger.of(context).clearSnackBars();
      verifying = false;
      return;
    }

    final check = await post(Uri.parse("http://${serverIP.text}/account/check"),
        body: "username=${username.text}&password=${password.text}");

    if (check.statusCode != 200) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(children: const [Text("Credentials failed. (2)")]),
          ),
          duration: const Duration(seconds: 10)));
      verifying = false;
      return;
    }

    final share = SuperMCShare(
        username: username.text,
        password: password.text,
        serverIP: serverIP.text.split(":").first,
        serverPort: int.parse(serverIP.text.split(":").last));

    await share.listInstances();

    await share.saveCredentialsToDisk();

    ScaffoldMessenger.of(context).clearSnackBars();
    final MainAppWidget nw = MainAppWidget(share: share);

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return nw;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
          child: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints.tight(const Size.square(450)),
        child: Form(
          key: formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextFormField(
              controller: serverIP,
              autocorrect: false,
              autofocus: true,
              autovalidateMode: AutovalidateMode.disabled,
              decoration: const InputDecoration(
                  labelText: "Server IP",
                  fillColor: Colors.lightGreenAccent,
                  helperText: "xxx.xxx.xxx.xxx:xxxxx / example.com:xxxxx"),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Form field must contain a value.";
                }
                if (value.trim().split(":").length != 2) {
                  return "Form field must contain base URL / IP and a port number.";
                }
                return null;
              },
            ),
            TextFormField(
              controller: username,
              autocorrect: false,
              autovalidateMode: AutovalidateMode.disabled,
              decoration: const InputDecoration(
                  labelText: "Username", fillColor: Colors.lightGreenAccent),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Form field must contain a value.";
                }
                return null;
              },
            ),
            TextFormField(
              controller: password,
              autocorrect: false,
              autovalidateMode: AutovalidateMode.disabled,
              decoration: const InputDecoration(
                  labelText: "Password", fillColor: Colors.lightGreenAccent),
              obscureText: true,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Form field must contain a value.";
                }
                return null;
              },
            ),
            const SizedBox.square(dimension: 4),
            ElevatedButton(
                onPressed: () {
                  if (!verifying) {
                    _verifyAndPass();
                  }
                },
                child: const Padding(
                  padding:
                      EdgeInsets.only(left: 11, right: 11, top: 6, bottom: 6),
                  child: Text(
                    "Save",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
                  ),
                ))
          ]),
        ),
      )),
    );
  }
}
