import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timeago/timeago.dart';

final dioProvider = Provider<Dio>((red) => Dio());

Future<void> main() async {
  await dotenv.load(fileName: 'data.env');
  final container = ProviderContainer();

  final dioRequestHeaders = {
    'Accept': 'application/vnd.github.v3+json',
  };

  final ghAuthKey = dotenv.env['GH_SECRET_KEY'];

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
        theme: ThemeData.dark(),
        home: const MyApp(),
      ),
    ),
  );
}

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useMemoizerKey = useState<Key>(const ValueKey('regular'));
    final useGetUserReceivedEventsMemoize = useMemoized(
      () => ref.watch(dioProvider).get('/users/agondev/received_events'),
      [useMemoizerKey.value],
    );
    // final useGetAuthenticatedUser =
    //     useMemoized(() => ref.watch(dioProvider).get('/user'));

    final useGetUserReceivedEventsFuture =
        useFuture(useGetUserReceivedEventsMemoize);

    // final useGetAuthenticatedUserFuture = useFuture(useGetAuthenticatedUser);

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

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(10.0),
          child: CircleAvatar(
              // backgroundImage: NetworkImage(
              //   // useGetAuthenticatedUserFuture.data!.data['avatar_url'],
              // ),
              ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              // ignore: lines_longer_than_80_chars
              'Requests left: ${useGetUserReceivedEventsFuture.data!.headers.value('x-ratelimit-remaining')!}',
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, idx) {
                final datum = useGetUserReceivedEventsFuture.data!.data[idx];
                return Center(
                  child: Card(
                    color: datum['public']
                        ? Colors.green.shade800.withOpacity(.5)
                        : Colors.orange.shade800.withOpacity(.5),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10) +
                          const EdgeInsets.only(left: 12, right: 4),
                      leading: Image.network(
                        datum['actor']['avatar_url'].toString(),
                        height: 36,
                      ),
                      title: RichText(
                        text: TextSpan(
                          children: [
                            const WidgetSpan(
                              child: Icon(Icons.chevron_right),
                              alignment: PlaceholderAlignment.bottom,
                            ),
                            WidgetSpan(
                              child: Icon(
                                datum['payload']['action'].toString() ==
                                        'started'
                                    ? Icons.star
                                    : Icons.help,
                              ),
                            ),
                            const WidgetSpan(
                              child: Icon(Icons.chevron_right),
                              alignment: PlaceholderAlignment.bottom,
                            ),
                            TextSpan(
                              text: datum['repo']['name'].toString().substring(
                                    0,
                                    datum['repo']['name']
                                        .toString()
                                        .indexOf('/'),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Text(
                        format(
                          DateTime.parse(
                            datum['created_at'],
                          ),
                        ),
                      ),
                      children: [
                        Card(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: const Text('User'),
                            title: Text(
                              datum['actor']['display_login'].toString(),
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: const Text('Repo'),
                            title: Text(
                              datum['repo']['name'].toString(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount:
                  (useGetUserReceivedEventsFuture.data!.data as List).length,
            ),
          ),
        ],
      ),
    );
  }
}
