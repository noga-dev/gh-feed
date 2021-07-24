import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaf/models/user.dart';
import 'package:gaf/utils/common.dart';
import 'package:gaf/utils/settings.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:very_good_analysis/very_good_analysis.dart';

import '../../utils/providers.dart';

Future<ProviderContainer> init() async {
  final container = ProviderContainer();
  // TODO p3 add encryption
  // TODO p3 costly operation -> show splash?
  await Hive.initFlutter().then((value) => Hive.openBox(kBoxSharedPrefs));

  final box = container.read(boxProvider);

  // await dotenv.load(fileName: 'data.env');
  // final ghAuthKey = dotenv.env['GH_SECRET_KEY'];

  final dioRequestHeaders = {'Accept': 'application/vnd.github.v3+json'};

  final ghAuthKey = box.get(kBoxKeySecretApi);

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
        onError: (error, handler) {
          if (error.response != null) {
            return handler.reject(
              DioError(
                requestOptions: error.requestOptions,
                error:
                    // ignore: lines_longer_than_80_chars
                    'REQUSTS REMAINING: ${error.response?.headers.value('x-ratelimit-remaining')!}',
              ),
            );
          }
        },
        onResponse: (response, handler) {
          container.read(requestsCountProvider).state = int.parse(
              response.headers.value('x-ratelimit-remaining') ?? '-1');
          return handler.next(response);
        },
      ),
    );

  if (!box.containsKey(kBoxKeySettings)) {
    unawaited(box.put(kBoxKeySettings, Settings().toJson()));
  }

  if (box.containsKey(kBoxKeyUserJson)) {
    container.read(userProvider).state = UserWrapper.fromJsonHive(
      box.get(kBoxKeyUserJson),
    );
  }

  // container.read(boxProvider).listenable();

  // else {
  //   container.read(settingsProvider).state =
  //       Settings.fromJson(container.read(boxProvider).get(kBoxKeySettings));
  // }

  return container;
}
