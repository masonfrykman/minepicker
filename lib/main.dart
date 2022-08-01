import 'package:flutter/material.dart';

import 'package:mpickflutter/UI/determiner.dart';

void main() => runApp(const Minepicker());

class Minepicker extends StatelessWidget {
  const Minepicker({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Minepicker',
        darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.dark(
                primary: Colors.deepPurple,
                secondary: Colors.deepPurpleAccent)),
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          brightness: Brightness.light,
          primarySwatch: Colors.deepPurple,
        ),
        home: const Determiner(),
        debugShowCheckedModeBanner: false);
  }
}
