import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gaf/utils/settings.dart';
import 'package:gh_trend/gh_trend.dart';
import 'package:github/github.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'common.dart';

final dioProvider = Provider<Dio>((ref) => Dio());
final boxProvider = Provider<Box>((ref) => Hive.box(kBoxSharedPrefs));

final dioGetProvider = FutureProvider.family(
  (ref, String param) => ref.read(dioProvider).get(param),
);

final trendingReposProvider = FutureProvider(
  (ref) => ghTrendingRepositories(
    spokenLanguageCode: 'en',
    dateRange: GhTrendDateRange.today,
    proxy: kIsWeb ? 'https://cors.bridged.cc/' : '',
  ),
);

final settingsProvider = StateProvider<Settings>((ref) => Settings());
final userProvider = StateProvider<User>((ref) => User());

final requestsCountProvider = StateProvider<int>((ref) => 0);
final pageIndexProvider = StateProvider<int>((ref) => 0);
