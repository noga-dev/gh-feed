import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gaf/theme/app_themes.dart';
import 'package:gaf/widgets/event_card.dart';
import 'package:gaf/widgets/event_title.dart';
import 'package:gaf/widgets/repo_preview.dart';
import 'package:github/github.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers.dart';

class ActivityList extends HookConsumerWidget {
  const ActivityList({
    Key? key,
    required this.rawFeed,
    required this.childCount,
  }) : super(key: key);

  final dynamic rawFeed;
  final int childCount;

  @override
  Widget build(context, ref) {
    final useRepos = useState(<SliverRepoItem>[]);
    useEffect(() {
      for (var item in rawFeed) {
        useRepos.value.add(SliverRepoItem(event: Event.fromJson(item)));
      }
    });

    return SliverAnimatedList(
      itemBuilder: (context, idx, anim) {
        return useRepos.value[idx];
      },
      initialItemCount: childCount,
      // delegate: SliverChildBuilderDelegate(
      //   (context, idx) => ,
      //   childCount: childCount,
      // ),
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

    if (useGetRepoDetails.snapshot.hasError) {
      return const Text('Error');
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
          EventCard(
            title: EventTitle(
              event: event,
            ),
            content: Column(
              children: [
                useGetRepoDetails.snapshot.hasData
                    ? RepoPreview(
                        repo: Repository.fromJson(
                            useGetRepoDetails.snapshot.data!.data),
                      )
                    : const SizedBox(
                        height: RepoPreview.totalPreviewBoxHeight,
                        child: LinearProgressIndicator(),
                      ),
                if (event.type != 'PushEvent' &&
                    event.type != 'WatchEvent' &&
                    event.type != 'ForkEvent' &&
                    event.type != 'CreateEvent' &&
                    event.type != 'IssueCommentEvent' &&
                    event.type != 'ReleaseEvent') ...[
                  ListTile(
                    leading: const Text('Type'),
                    title: Text(
                      event.type!,
                    ),
                  ),
                ],
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
