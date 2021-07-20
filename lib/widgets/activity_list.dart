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

class ActivityList extends StatelessWidget {
  const ActivityList({
    Key? key,
    required this.rawFeed,
    required this.childCount,
  }) : super(key: key);

  final dynamic rawFeed;
  final int childCount;

  @override
  Widget build(BuildContext context) {
    return HookBuilder(builder: (context) {
      final useEvents = useState(<Event>[]);
      // TODO put and retrieve from box
      final useRepos = useState(<Repository>[]);
      useEffect(() {
        for (dynamic item in rawFeed) {
          useEvents.value.add(Event.fromJson(item));
        }
      });

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, idx) {
            final event = useEvents.value[idx];

            return HookConsumer(
              builder: (context, ref, _) {
                final useGetRepoDetails = useMemoizedFuture(() async {
                  if (useRepos.value
                      .where((element) => element.name == event.repo!.name)
                      .isNotEmpty) {
                    return Future.value(
                      Response(
                        requestOptions: RequestOptions(
                          path: '',
                          data: useRepos.value.firstWhere(
                              (element) => element.name == event.repo!.name),
                        ),
                      ),
                    );
                  }

                  final result =
                      ref.watch(dioProvider).get('/repos/${event.repo!.name}');
                  await result.then(
                    (value) => useRepos.value.add(
                      Repository.fromJson(value.data),
                    ),
                  );
                  return result;
                });

                if (!useGetRepoDetails.snapshot.hasData) {
                  return const LinearProgressIndicator();
                } else if (useGetRepoDetails.snapshot.hasError) {
                  return const Text('Error');
                }
                final repo =
                    Repository.fromJson(useGetRepoDetails.snapshot.data!.data);

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
                          event: useEvents.value[idx],
                        ),
                        content: Column(
                          children: [
                            RepoPreview(repo: repo),
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
                                      if (await canLaunch(event
                                          .payload!['issue']['html_url'])) {
                                        await launch(event.payload!['issue']
                                            ['html_url']);
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
              },
            );
          },
          childCount: childCount,
        ),
      );
    });
  }
}
