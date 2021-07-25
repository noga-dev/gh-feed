import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaf/screens/main/init.dart';
import 'package:gaf/theme/app_themes.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'screens/main/app.dart';

Future<void> main() async {
  InitializerNotifier().addListener(
    (state) => runApp(
      state.when(
        error: (err, stack) => const Center(),
        loading: () => const Material(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator.adaptive(
              backgroundColor: Colors.amber,
            ),
          ),
        ),
        data: (data) => UncontrolledProviderScope(
          container: data,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Github Feeder',
            theme: themeDataLight,
            darkTheme: themeDataDark,
            themeMode: ThemeMode.dark,
            home: const MyApp(),
          ),
        ),
      ),
    ),
  );
}
