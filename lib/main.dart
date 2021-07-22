import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaf/screens/main/init.dart';
import 'package:gaf/theme/app_themes.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'screens/main/app.dart';

Future<void> main() async {
  final container = await init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Github Feeder',
        theme: themeDataLight,
        darkTheme: themeDataDark,
        themeMode: ThemeMode.dark,
        home: const MyApp(),
        builder: (context, child) => MediaQuery(
          data: const MediaQueryData(textScaleFactor: .8),
          child: child!,
        ),
      ),
    ),
  );
}
