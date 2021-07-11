import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timeago/timeago.dart';

final dioProvider = Provider<Dio>(
  (red) => Dio(
    BaseOptions(
      baseUrl: 'https://api.github.com/',
      // responseType: ResponseType.json,
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'Authorization': 'token ${dotenv.env['GH_SECRET_KEY']}',
      },
    ),
  ),
);

void main() async {
  await dotenv.load(fileName: 'data.env');
  // ignore: unused_local_variable
  var ghKey = dotenv.env['GH_SECRET_KEY'];

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final useDioProvider = useProvider(dioProvider);
    final useGetUser = useFuture(
      useMemoized(
        () => useDioProvider.get('/users/agondev/received_events'),
        // () => useDioProvider.get('/users/agondev/events'),
      ),
    );

    if (!useGetUser.hasData) {
      return const Center(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: LinearProgressIndicator(),
        ),
      );
    }

    if (useGetUser.hasError) {
      return const Center(
        child: Text('😢'),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                // ignore: lines_longer_than_80_chars
                'Requests left: ${useGetUser.data!.headers.value('x-ratelimit-remaining')!}',
              ),
            ],
          ),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () {
                return Future.delayed(
                  const Duration(seconds: 1),
                );
              },
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, idx) {
                  final datum = useGetUser.data!.data[idx];
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
                                text:
                                    datum['repo']['name'].toString().substring(
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
                childCount: (useGetUser.data!.data as List).length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
