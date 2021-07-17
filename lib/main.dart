import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gaf/theme/app_themes.dart';
import 'package:gaf/widgets/activity_list.dart';
import 'package:gaf/widgets/requests_left.dart';
import 'package:gaf/widgets/trending_repos.dart';
import 'package:gh_trend/gh_trend.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:very_good_analysis/very_good_analysis.dart';
import 'package:hive_flutter/hive_flutter.dart';

final dioProvider = Provider<Dio>((ref) => Dio());
final boxProvider = Provider<Box>((ref) => Hive.box('sharedPrefsBox'));

Future<void> main() async {
  final container = ProviderContainer();
  // TODO add encryption
  // TODO costly operation -> show splash?
  await Hive.initFlutter().then((value) => Hive.openBox('sharedPrefsBox'));

  // await dotenv.load(fileName: 'data.env');
  // final ghAuthKey = dotenv.env['GH_SECRET_KEY'];

  final dioRequestHeaders = {
    'Accept': 'application/vnd.github.v3+json',
  };

  final ghAuthKey = container.read(boxProvider).get('secretKey');

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
      ),
    ),
  );
}

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useMemoizerKey = useState<Key>(UniqueKey());
    final useGetTrendingRepos = useFuture<List<GithubRepoItem>>(
      useMemoized(() async => await ghTrendingRepositories()),
    );
    final useUserLogin = useState<String>('rrousselGit');
    final useGetUserDetailsFuture = useFuture<Response>(
      useMemoized(
        () async {
          Response result;
          if (ref
              .watch(dioProvider)
              .options
              .headers
              .containsKey('Authorization')) {
            result = await ref.watch(dioProvider).get('/user');
            useUserLogin.value = result.data['login'];
          } else {
            result = Response(
              requestOptions: RequestOptions(path: ''),
              data: {
                'login': useUserLogin.value,
                'avatar_url':
                    'https://avatars.githubusercontent.com/in/15368?s=64&v=4',
              },
            );
          }
          return result;
        },
        [ref.watch(dioProvider).options.headers['Authorization']],
      ),
    );
    final useGetUserReceivedEventsFuture = useFuture<Response>(
      useMemoized(
        () => ref
            .watch(dioProvider)
            .get('/users/${useUserLogin.value}/received_events'),
        [
          useMemoizerKey.value,
          useUserLogin.value,
          ref.watch(dioProvider).options.headers['Authorization'],
        ],
      ),
    );

    if (useGetUserReceivedEventsFuture.connectionState ==
            ConnectionState.waiting &&
        !useGetUserReceivedEventsFuture.hasData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (useGetUserReceivedEventsFuture.hasError) {
      return Center(
        child: Text(useGetUserReceivedEventsFuture.error.toString()),
      );
    }

    final avatar = CircleAvatar(
      radius: 40,
      backgroundImage: NetworkImage(
        useGetUserDetailsFuture.hasData
            ? useGetUserDetailsFuture.data!.data['avatar_url']
            : 'https://github.com/identicons/jasonlong.png',
      ),
    );

    return Scaffold(
      drawerEdgeDragWidth: 32,
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
                        unawaited(ref.watch(boxProvider).put('secretKey', val));
                      } on DioError {
                        ref
                            .watch(dioProvider)
                            .options
                            .headers
                            .remove('Authorization');
                      }
                      useMemoizerKey.value = UniqueKey();
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
              count: useGetUserReceivedEventsFuture.data!.headers
                  .value('x-ratelimit-remaining')!,
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () {
                    useMemoizerKey.value = UniqueKey();
                    return Future<void>.value(null);
                  },
                ),
                ActivityList(
                  rawFeed: useGetUserReceivedEventsFuture.data!.data,
                  childCount:
                      (useGetUserReceivedEventsFuture.data!.data as List)
                          .length,
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Activity Feed',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Expanded(
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            CupertinoSliverRefreshControl(
                              onRefresh: () {
                                useMemoizerKey.value = UniqueKey();
                                return Future<void>.value(null);
                              },
                            ),
                            ActivityList(
                              rawFeed:
                                  useGetUserReceivedEventsFuture.data!.data,
                              childCount: (useGetUserReceivedEventsFuture
                                      .data!.data as List)
                                  .length,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Trending Repos',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Expanded(
                        child: TrendingRepos(
                          trendingRepos: useGetTrendingRepos.data ?? [],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
