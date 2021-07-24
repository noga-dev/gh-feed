import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gaf/utils/common.dart';
import 'package:gaf/utils/settings.dart';
import 'package:github/github.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_themes.dart';
import '../../utils/providers.dart';
import 'events_list/event_card.dart';
import 'events_list/event_title.dart';
import 'events_list/repo_preview.dart';

class EventsList extends HookConsumerWidget {
  const EventsList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(context, ref) {
    final useRepos = useState(<SliverRepoItem>[]);
    final useFilteredRepos = useState(<SliverRepoItem>[]);
    final useGetUserReceivedEventsFuture = useMemoizedFuture(
      () async {
        if (ref.read(userProvider).state != null) {
          return ref.read(dioProvider).get(
              '/users/${ref.read(userProvider).state!.login}/received_events');
        }
        return Future.value(null);
      },
      keys: [ref.read(userProvider)],
    );

    if (!useGetUserReceivedEventsFuture.snapshot.hasData) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (useGetUserReceivedEventsFuture.snapshot.hasError) {
      Center(
        child: Text(
          useGetUserReceivedEventsFuture.snapshot.error.toString(),
        ),
      );
    }

    /*TODO P2: for PR, Issue, IssueComment, and Fork events show relevant
       details instead of repo preview*/
    useEffect(() {
      for (var item in useGetUserReceivedEventsFuture.snapshot.data!.data) {
        final event = Event.fromJson(item);
        if (event.payload!.isNotEmpty) {
          useRepos.value.add(SliverRepoItem(event: event));
        }
      }
    }, [useGetUserReceivedEventsFuture.snapshot.data!.data]);

    if (ref.watch(settingsProvider).state.filterPushEvents) {
      useFilteredRepos.value = useRepos.value
          .where((element) => element.event.type != 'PushEvent')
          .toList();
    } else {
      useFilteredRepos.value = useRepos.value.toList();
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () => Future<void>.value(
            useGetUserReceivedEventsFuture.refresh(),
          ),
        ),
        SliverAppBar(
          pinned: true,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Activity Feed',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(useFilteredRepos.value),
          ),
        ),
      ],
    );
  }
}

class SliverRepoItem extends HookConsumerWidget {
  const SliverRepoItem({
    Key? key,
    required this.event,
  }) : super(key: key);

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useGetRepoDetails = useMemoizedFuture(() async {
      if (ref
          .read(reposCacheProvider)
          .state
          .where((element) => element.fullName == event.repo!.name)
          .isNotEmpty) {
        return Future.value(
          Response(
            requestOptions: RequestOptions(
              path: '',
            ),
            data: jsonDecode(
              jsonEncode(
                ref.read(reposCacheProvider).state.firstWhere(
                    (element) => element.fullName == event.repo!.name),
              ),
            ),
          ),
        );
      }

      final result = ref.read(dioProvider).get('/repos/${event.repo!.name}');
      await result.then(
        (value) => ref.read(reposCacheProvider).state.add(
              Repository.fromJson(value.data),
            ),
      );
      return result;
    });

    final settingsBox = ref.read(boxProvider);
    final useSettingsState = useState(
      Settings.fromJson(
          settingsBox.get(kBoxKeySettings, defaultValue: Settings().toJson())),
    );

    if (event.type == 'PushEvent' && useSettingsState.value.filterPushEvents) {
      return const SizedBox.shrink();
    }

    if (event.type == 'DeleteEvent' &&
        useSettingsState.value.filterDeleteEvents) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? themeDataDark.cardColor
          : themeDataLight.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          EventsListView(
            title: EventTitle(
              event: event,
            ),
            content: Column(
              children: [
                if (useGetRepoDetails.snapshot.hasData)
                  RepoPreview(
                    repo: Repository.fromJson(
                      useGetRepoDetails.snapshot.data!.data,
                    ),
                  )
                else if (useGetRepoDetails.snapshot.hasError)
                  ErrorPreview(
                    request: useGetRepoDetails.snapshot.data?.requestOptions
                            .toString() ??
                        'null',
                    error: useGetRepoDetails.snapshot.error.toString(),
                  )
                else if (!(useGetRepoDetails.snapshot.connectionState ==
                    ConnectionState.done))
                  const SizedBox(
                    height: RepoPreview.totalPreviewBoxHeight,
                    child: LinearProgressIndicator(),
                  ),
                // if (event.type != 'PushEvent' &&
                //     event.type != 'WatchEvent' &&
                //     event.type != 'ForkEvent' &&
                //     event.type != 'CreateEvent' &&
                //     event.type != 'IssueCommentEvent' &&
                //     event.type != 'ReleaseEvent') ...[
                //   ListTile(
                //     leading: const Text('Type'),
                //     title: Text(
                //       event.type!,
                //     ),
                //   ),
                // ],
                if (event.type == 'IssueCommentEvent') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('View issue'),
                        onPressed: () async {
                          if (await canLaunch(
                              event.payload!['issue']['html_url'])) {
                            await launch(event.payload!['issue']['html_url']);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorPreview extends StatelessWidget {
  const ErrorPreview({
    Key? key,
    required this.request,
    required this.error,
  }) : super(key: key);

  final String request;
  final String error;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: RepoPreview.totalPreviewBoxHeight,
      child: SingleChildScrollView(
        child: Text(
          error,
          style: TextStyle(color: Colors.red.shade300),
        ),
      ),
    );
  }
}
