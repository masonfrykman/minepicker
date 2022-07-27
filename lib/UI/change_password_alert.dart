import 'package:flutter/material.dart';
import 'package:mpickflutter/Helpers/super_mc_share.dart';
import 'package:mpickflutter/UI/setup.dart';

Widget changePasswordAlert(BuildContext context, SuperMCShare share) {
  TextEditingController old = TextEditingController();
  TextEditingController newPass = TextEditingController();
  TextEditingController confirm = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  return AlertDialog(
    title: Text("Change password"),
    content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: old,
              decoration: InputDecoration(labelText: "Old password"),
              obscureText: true,
              autocorrect: false,
              autovalidateMode: AutovalidateMode.disabled,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Cannot be empty.";
                }
                return null;
              },
            ),
            TextFormField(
              controller: newPass,
              decoration: InputDecoration(labelText: "New password"),
              obscureText: true,
              autocorrect: false,
              autovalidateMode: AutovalidateMode.disabled,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Cannot be empty.";
                }
                return null;
              },
            ),
            TextFormField(
              controller: confirm,
              decoration: InputDecoration(labelText: "Confirm new password"),
              obscureText: true,
              autocorrect: false,
              autovalidateMode: AutovalidateMode.disabled,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Cannot be empty.";
                }
                return null;
              },
            ),
            SizedBox.square(dimension: 20),
            ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState == null) {
                    return;
                  }
                  final val = _formKey.currentState!.validate();
                  if (!val) {
                    return;
                  }

                  if (newPass.text != confirm.text) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: Text(
                                  "New password & Confirm new password values are not equal."),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Ok"))
                              ]);
                        });
                    confirm.clear();
                    newPass.clear();
                    return;
                  }

                  final cp = await share.changePassword(old.text, newPass.text);

                  if (cp) {
                    await share.willLogOut();
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Success"),
                            content: Text(
                                "Successfully changed password. You will be logged out now."),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .popUntil((route) => false);
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return SetupWidget();
                                    }));
                                  },
                                  child: Text("Ok"))
                            ],
                          );
                        });

                    return;
                  }
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Failed to change password."),
                          content: Text("Please try again."),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Ok"))
                          ],
                        );
                      });
                },
                child: Text("Submit"))
          ],
        )),
  );
}
