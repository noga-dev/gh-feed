import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gaf/theme/app_themes.dart';
import 'package:gaf/widgets/activity_list.dart';
import 'package:gaf/widgets/created_at.dart';
import 'package:gaf/theme/github_colors.dart';
import 'package:gaf/widgets/requests_left.dart';
import 'package:gaf/widgets/user_avatar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timeago/timeago.dart';
import 'package:url_launcher/url_launcher.dart';

final dioProvider = Provider<Dio>((red) => Dio());

Future<void> main() async {
  await dotenv.load(fileName: 'data.env');
  final container = ProviderContainer();

  final dioRequestHeaders = {
    'Accept': 'application/vnd.github.v3+json',
  };

  final ghAuthKey = dotenv.env['GH_SECRET_KEY1'];

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

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: basicLight,
        darkTheme: basicDark,
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

    // ignore: avoid_print
    print('test');

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
      body: CustomScrollView(
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
                (useGetUserReceivedEventsFuture.data!.data as List).length,
          ),
        ],
      ),
    );
  }
}
