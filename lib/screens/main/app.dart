import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gaf/screens/main/app/requests_left.dart';
import 'package:gh_trend/gh_trend.dart';
import 'package:github/github.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../utils/common.dart';
import '../../utils/providers.dart';
import '../widgets/events_list.dart';
import '../widgets/trending_repos.dart';
import 'app/feed_filter_dialog.dart';
import 'app/menu_bottom_sheet.dart';

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

    // final useGetUserDetailsFuture = useMemoizedFuture(
    useMemoizedFuture(
      () async => ref
              .read(dioProvider)
              .options
              .headers
              .containsKey('Authorization')
          ? ref.read(dioProvider).get('/user').then((value) {
              ref.read(boxProvider).put(kBoxKeyUserLogin, value.data['login']);
              ref.read(userProvider).setUser(User.fromJson(value.data));
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

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Builder(
            builder: (context) => IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(
                  ref.read(userProvider).getUser().avatarUrl ?? defaultAvatar,
                ),
              ),
              // onPressed: () => Scaffold.of(context).openDrawer(),
              onPressed: () {
                // final screenSize = getSize(context);
                // if (screenSize == ScreenSize.large ||
                //     screenSize == ScreenSize.extraLarge) {
                //   showDialog(
                //     context: context,
                //     builder: (_) => const SimpleDialog(
                //       title: Text('Settings'),
                //       children: [],
                //     ),
                //   );
                // } else {
                showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return MenuBottomSheet(
                      currentUser: ref.read(userProvider).getUser(),
                    );
                  },
                );
                // }
              },
            ),
          ),
        ),
        title: kDebugMode
            ? RequestsLeft(
                count: ref.read(requestsCountProvider).state.toString(),
              )
            : const Text('Activity Feed'),
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
                    SliverPadding(
                      padding: const EdgeInsets.all(8.0),
                      sliver: ActivityList(
                        rawFeed:
                            useGetUserReceivedEventsFuture.snapshot.data!.data,
                      ),
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
          // mobile, logged in
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
                                SliverPadding(
                                  padding: const EdgeInsets.all(8),
                                  sliver: TrendingRepos(
                                    trendingRepos:
                                        useGetTrendingRepos.snapshot.data ?? [],
                                  ),
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
