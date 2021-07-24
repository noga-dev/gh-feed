import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gaf/screens/main/app/requests_left.dart';
import 'package:gaf/utils/mock_data.dart';
import 'package:gh_trend/gh_trend.dart';
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
    // final useUserLogin = useState<String>(
    //     ref.read(boxProvider).get(kBoxKeyUserLogin) ?? defaultUserLogin);

    final useGetTrendingRepos = useMemoizedFuture(
      () => ghTrendingRepositories(
        spokenLanguageCode: 'en',
        dateRange: GhTrendDateRange.today,
        proxy: kIsWeb ? 'https://cors.bridged.cc/' : '',
      ),
    );

    final useGetUserReceivedEventsFuture = useMemoizedFuture(
      () async {
        if (ref.read(userProvider).state != null) {
          return ref.read(dioProvider).get(
              '/users/${ref.read(userProvider).state!.login}/received_events');
        }
        return Future.value(null);
      },
      keys: [ref.read(userProvider).state?.login ?? mockDefaultUsername],
    );

    final useGetPublicEvents = useMemoizedFuture(
      () => ref.read(dioProvider).get('/events'),
    );

    if (!useGetUserReceivedEventsFuture.snapshot.hasData &&
            !useGetTrendingRepos.snapshot.hasData ||
        !useGetPublicEvents.snapshot.hasData) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (useGetUserReceivedEventsFuture.snapshot.hasError ||
        useGetTrendingRepos.snapshot.hasError ||
        useGetPublicEvents.snapshot.hasError) {
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
                  ref.read(userProvider).state?.avatarUrl ?? defaultAvatar,
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => const MenuBottomSheet(),
                );
              },
            ),
          ),
        ),
        title: kDebugMode ? const RequestsLeft() : const Text('Activity Feed'),
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
      // TODO p2 refactor this layoutBuilder for soc & adaptive future state
      body: LayoutBuilder(
        builder: (context, constraints) {
          final Widget _activityFeed;
          if ((ref.watch(userProvider).state != null)) {
            if ((useGetUserReceivedEventsFuture.snapshot.connectionState !=
                ConnectionState.done)) {
              _activityFeed = const CircularProgressIndicator.adaptive();
            } else {
              _activityFeed = CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () => Future<void>.value(
                      useGetUserReceivedEventsFuture.refresh(),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(8.0),
                    sliver: EventsList(
                      rawFeed:
                          useGetUserReceivedEventsFuture.snapshot.data!.data,
                    ),
                  ),
                ],
              );
            }
          } else {
            _activityFeed = ListView(
              children: (useGetPublicEvents.snapshot.data!.data as List).map(
                (e) {
                  var payload = e['type'];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(e['actor']['avatar_url']),
                      ),
                      title: Text(e['repo']['name'] ?? 'error'),
                      subtitle: Text(payload),
                    ),
                  );
                },
              ).toList(),
            );
          }
          if (constraints.maxWidth < 900) {
            return _activityFeed;
          } else {
            return Row(
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
          }
        },
      ),
    );
  }
}
