import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gaf/providers.dart';
import 'package:gaf/theme/app_themes.dart';
import 'package:gaf/widgets/activity_list.dart';
import 'package:gaf/widgets/requests_left.dart';
import 'package:gaf/widgets/trending_repos.dart';
import 'package:gh_trend/gh_trend.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:very_good_analysis/very_good_analysis.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _secretKey = 'secretKey';
Future<void> main() async {
  final container = ProviderContainer();
  // TODO add encryption
  // TODO costly operation -> show splash?
  await Hive.initFlutter().then((value) => Hive.openBox('sharedPrefsBox'));

  // await dotenv.load(fileName: 'data.env');
  // final ghAuthKey = dotenv.env['GH_SECRET_KEY'];

  final dioRequestHeaders = {'Accept': 'application/vnd.github.v3+json'};

  final ghAuthKey = container.read(boxProvider).get(_secretKey);

  if (ghAuthKey != null) {
    dioRequestHeaders.putIfAbsent(
      'Authorization',
      () => 'token $ghAuthKey',
    );
  }

  container.read(dioProvider).options = BaseOptions(
    baseUrl: 'https://api.github.com/',
    headers: dioRequestHeaders,
  );

  // TODO add shared prefs or secured shared prefs or hive to store key
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
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: const MediaQueryData(textScaleFactor: .8),
          child: child!,
        ),
      ),
    ),
  );
}

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useUserLogin = useState<String>('rrousselGit');
    final useGetTrendingRepos = useMemoizedFuture(
      () => ghTrendingRepositories(
        spokenLanguageCode: 'en',
        dateRange: GhTrendDateRange.today,
      ),
    );
    final useGetUserDetailsFuture = useMemoizedFuture(() async {
      Future<Response> result;
      if (ref.watch(dioProvider).options.headers.containsKey('Authorization')) {
        result = ref.watch(dioProvider).get('/user');
        await result
            .then((value) async => useUserLogin.value = value.data['login']);
      } else {
        result = Future.value(
          Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'login': useUserLogin.value,
              'avatar_url':
                  'https://avatars.githubusercontent.com/in/15368?s=64&v=4',
            },
          ),
        );
      }
      return result;
    });
    final useGetUserReceivedEventsFuture = useMemoizedFuture(
      () => ref
          .watch(dioProvider)
          .get('/users/${useUserLogin.value}/received_events'),
    );

    if (useGetUserReceivedEventsFuture.snapshot.connectionState ==
            ConnectionState.waiting &&
        !useGetUserReceivedEventsFuture.snapshot.hasData &&
        useGetTrendingRepos.snapshot.connectionState ==
            ConnectionState.waiting &&
        !useGetTrendingRepos.snapshot.hasData) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (useGetUserReceivedEventsFuture.snapshot.hasError ||
        useGetTrendingRepos.snapshot.hasError) {
      return const Center(child: Text('Error'));
    }

    final avatar = CircleAvatar(
      radius: 40,
      backgroundImage: NetworkImage(
        useGetUserDetailsFuture.snapshot.hasData
            ? useGetUserDetailsFuture.snapshot.data!.data['avatar_url']
            : 'https://github.com/identicons/jasonlong.png',
      ),
    );

    return Scaffold(
      drawerEdgeDragWidth: 32,
      endDrawer: kDebugMode
          ? Drawer(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      unawaited(ref.watch(boxProvider).delete(_secretKey));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Key Reset!',
                            textAlign: TextAlign.center,
                            textScaleFactor: 2,
                          ),
                        ),
                      );
                    },
                    child: const Text('Reset key'),
                  ),
                ],
              ),
            )
          : null,
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal.shade700,
              ),
              child: Center(
                child: avatar,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // TODO make optional either username for only public data
                  // OR key for private as well
                  // AND add this as a separate option to track other users?
                  TextField(
                    decoration: const InputDecoration(hintText: 'Auth Key'),
                    obscureText: true,
                    onChanged: (val) async {
                      try {
                        ref.watch(dioProvider).options.headers.update(
                              'Authorization',
                              (value) => 'token $val',
                              ifAbsent: () => 'token $val',
                            );
                        unawaited(ref.watch(boxProvider).put(_secretKey, val));
                        useGetUserDetailsFuture.refresh();
                        useGetUserReceivedEventsFuture.refresh();
                      } on DioError {
                        ref
                            .watch(dioProvider)
                            .options
                            .headers
                            .remove('Authorization');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Builder(
            builder: (context) => IconButton(
              icon: avatar,
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RequestsLeft(
              count: useGetUserReceivedEventsFuture.snapshot.data!.headers
                  .value('x-ratelimit-remaining')!,
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          var _activityFeed = CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: () => Future<void>.value(
                  useGetUserReceivedEventsFuture.refresh(),
                ),
              ),
              ActivityList(
                rawFeed: useGetUserReceivedEventsFuture.snapshot.data!.data,
                childCount:
                    (useGetUserReceivedEventsFuture.snapshot.data!.data as List)
                        .length,
              ),
            ],
          );
          return constraints.maxWidth < 900
              ? _activityFeed
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              'Activity Feed',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          Expanded(child: _activityFeed),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              'Trending Repos',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          Expanded(
                            child: CustomScrollView(
                              physics: const BouncingScrollPhysics(),
                              slivers: [
                                CupertinoSliverRefreshControl(
                                  onRefresh: () => Future<void>.value(
                                    useGetTrendingRepos.refresh(),
                                  ),
                                ),
                                TrendingRepos(
                                  trendingRepos:
                                      useGetTrendingRepos.snapshot.data ?? [],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
