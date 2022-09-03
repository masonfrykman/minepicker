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
            snackBarTheme: SnackBarThemeData(
                backgroundColor: Colors.deepPurple,
                contentTextStyle: TextStyle(color: Colors.white)),
            brightness: Brightness.dark,
            textSelectionTheme:
                TextSelectionThemeData(selectionColor: Colors.grey),
            colorScheme: ColorScheme.dark(
                primary: Colors.deepPurple,
                secondary: Colors.deepPurpleAccent)),
        theme: ThemeData(
          textSelectionTheme:
              TextSelectionThemeData(selectionColor: Colors.grey),
          brightness: Brightness.light,
          primarySwatch: Colors.deepPurple,
        ),
        home: const Determiner(),
        debugShowCheckedModeBanner: false);
  }
}
