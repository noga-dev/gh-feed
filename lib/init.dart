import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaf/common.dart';
import 'package:gaf/settings.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:very_good_analysis/very_good_analysis.dart';

import 'providers.dart';

Future<ProviderContainer> init() async {
  final container = ProviderContainer();
  // TODO add encryption
  // TODO costly operation -> show splash?
  await Hive.initFlutter().then((value) => Hive.openBox(kSharedPrefsBox));

  // await dotenv.load(fileName: 'data.env');
  // final ghAuthKey = dotenv.env['GH_SECRET_KEY'];

  final dioRequestHeaders = {'Accept': 'application/vnd.github.v3+json'};

  final ghAuthKey = container.read(boxProvider).get(kSecretApiKey);

  if (ghAuthKey != null) {
    dioRequestHeaders.putIfAbsent(
      'Authorization',
      () => 'token $ghAuthKey',
    );
  }

  container.read(dioProvider)
    ..options = BaseOptions(
      baseUrl: 'https://api.github.com/',
      headers: dioRequestHeaders,
    )
    ..interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          container.read(requestsCountProvider).state = int.parse(
              response.headers.value('x-ratelimit-remaining') ?? '-1');
          return handler.next(response);
        },
      ),
    );

  if (!container.read(boxProvider).containsKey('settings')) {
    unawaited(container.read(boxProvider).put('settings', Settings().toJson()));
  }

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.black),
  );

  return container;
}
