import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gh_trend/gh_trend.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:very_good_analysis/very_good_analysis.dart';

import '../../utils/common.dart';
import '../../utils/providers.dart';
import '../../utils/settings.dart';
import '../widgets/activity_list.dart';
import '../widgets/feed_filter_dialog.dart';
import '../widgets/requests_left.dart';
import '../widgets/trending_repos.dart';

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useUserLogin = useState<String>(
        ref.read(boxProvider).get(kBoxKeyUserLogin) ?? defaultUserLogin);
    final useGetTrendingRepos = useMemoizedFuture(
      () => ghTrendingRepositories(
        spokenLanguageCode: 'en',
        dateRange: GhTrendDateRange.today,
        proxy: kIsWeb ? 'https://cors.bridged.cc/' : '',
      ),
    );
    final useGetUserDetailsFuture = useMemoizedFuture(
      () async => ref
              .read(dioProvider)
              .options
              .headers
              .containsKey('Authorization')
          ? ref.read(dioProvider).get('/user').then((value) {
              ref.read(boxProvider).put(kBoxKeyUserLogin, value.data['login']);
              return value;
            })
          : Future.value(
              Response(
                requestOptions: RequestOptions(path: ''),
                data: {
                  'login': useUserLogin.value,
                  'avatar_url': defaultAvatar,
                },
              ),
            ),
    );
    final useGetUserReceivedEventsFuture = useMemoizedFuture(
      () async => ref
          .read(dioProvider)
          .get('/users/${useUserLogin.value}/received_events'),
    );
    final useGetPublicEvents =
        useMemoizedFuture(() => ref.read(dioProvider).get('/events'));

    if (!useGetUserReceivedEventsFuture.snapshot.hasData &&
        !useGetTrendingRepos.snapshot.hasData) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (useGetUserReceivedEventsFuture.snapshot.hasError ||
        useGetTrendingRepos.snapshot.hasError) {
      return Scaffold(
        body: Center(
          child: Text(
            useGetUserReceivedEventsFuture.snapshot.hasError
                ? useGetUserReceivedEventsFuture.snapshot.error.toString()
                : useGetTrendingRepos.snapshot.error.toString(),
          ),
        ),
      );
    }

    final avatar = CircleAvatar(
      radius: 40,
      backgroundImage: NetworkImage(
        useGetUserDetailsFuture.snapshot.hasData
            ? useGetUserDetailsFuture.snapshot.data!.data['avatar_url']
            : defaultAvatar,
      ),
    );

    return Padding(
      // ignore: prefer_const_constructors
      padding: EdgeInsets.only(
        top: (kIsWeb || // keep kIsWeb first due to bug
                Platform.isLinux ||
                Platform.isMacOS ||
                Platform.isWindows)
            ? .0
            : 22.0,
      ),
      child: Scaffold(
        drawerEdgeDragWidth: 32,
        endDrawer: kDebugMode
            ? Drawer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      onPressed: () async {
                        unawaited(ref.read(boxProvider).clear());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'box cleared',
                              textAlign: TextAlign.center,
                              textScaleFactor: 2,
                            ),
                          ),
                        );
                      },
                      child: const Text('clear box'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await ref.read(boxProvider).delete(kBoxKeySettings);
                        await ref.read(boxProvider).put(
                              kBoxKeySettings,
                              Settings().toJson(),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'settings deleted',
                              textAlign: TextAlign.center,
                              textScaleFactor: 2,
                            ),
                          ),
                        );
                      },
                      child: const Text('delete settings'),
                    )
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      avatar,
                      if (useGetUserDetailsFuture.snapshot.hasData) ...[
                        const SizedBox(height: 8),
                        Text(
                          useGetUserDetailsFuture.snapshot.data!.data['login'],
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ]
                    ],
                  ),
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
                          ref.read(dioProvider).options.headers.update(
                                'Authorization',
                                (value) => 'token $val',
                                ifAbsent: () => 'token $val',
                              );
                          unawaited(
                            ref.read(boxProvider).put(kBoxKeySecretApi, val),
                          );
                          useGetUserDetailsFuture.refresh();
                          useGetUserReceivedEventsFuture.refresh();
                        } on DioError {
                          ref
                              .read(dioProvider)
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
                /*onPressed: () {
                  if (isDesktopDeviceOrWeb) {
                    showDialog(
                      context: context,
                      builder: (_) => const SimpleDialog(
                        title: Text('Settings'),
                      ),
                    );
                  } else {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Container(),
                    );
                  }
                },*/
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RequestsLeft(
                count: ref.watch(requestsCountProvider).state.toString(),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(MdiIcons.filterOutline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const FeedFilterDialog(),
                );
              },
            ),
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                );
              },
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final _activityFeed = (useUserLogin.value != defaultUserLogin)
                ? CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      CupertinoSliverRefreshControl(
                        onRefresh: () => Future<void>.value(
                          useGetUserReceivedEventsFuture.refresh(),
                        ),
                      ),
                      ActivityList(
                        rawFeed:
                            useGetUserReceivedEventsFuture.snapshot.data!.data,
                      ),
                    ],
                  )
                : ListView(
                    children:
                        (useGetPublicEvents.snapshot.data!.data as List).map(
                      (e) {
                        var payload = e['type'];
                        // if (e['type'] == 'IssueCommentEvent') {
                        //   payload =
                        //  e['payload']['issue']['labels'][0]['description'];
                        // } else if (e['type'] == 'PushEvent') {
                        //   payload = e['payload']['commits'][0]['url'];
                        // } else if (e['type'] == 'CreateEvent') {
                        //   payload = e['payload']?['description'] ?? 'error';
                        // } else if (e['type'] == 'PullRequestEvent') {
                        //   payload = e['payload']['pull_request']['title'];
                        // }
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(e['actor']['avatar_url']),
                            ),
                            title: Text(e['repo']['name'] ?? 'error'),
                            subtitle: Text(payload),
                          ),
                        );
                      },
                    ).toList(),
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
      ),
    );
  }
}
