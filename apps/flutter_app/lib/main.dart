import 'dart:ui';

import 'package:flutter/material.dart';

import 'app/app_shell.dart';

void main() {
  runApp(const InkStudioApp());
}

class InkStudioApp extends StatefulWidget {
  const InkStudioApp({super.key});

  @override
  State<InkStudioApp> createState() => _InkStudioAppState();
}

class _InkStudioAppState extends State<InkStudioApp> {
  ThemeMode themeMode = ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InkStudio',
      debugShowCheckedModeBanner: false,
      
      themeMode: themeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Color.fromARGB(255, 255, 127, 0)
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Color.fromARGB(255, 0, 127, 255),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF323232),
          contentTextStyle: TextStyle(color: Colors.white),
          actionTextColor: Colors.lightBlueAccent
        )
      ),

      builder: (context, child) {
        return ExcludeSemantics(
          child: child ?? const SizedBox.shrink()
        );
      },

      home: AppShell(
        onToggleTheme: toggleTheme
      )
    );
  }
}
