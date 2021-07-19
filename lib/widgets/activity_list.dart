import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gaf/theme/app_themes.dart';
import 'package:gaf/widgets/event_card.dart';
import 'package:gaf/widgets/event_title.dart';
import 'package:gaf/widgets/repo_preview.dart';
import 'package:github/github.dart';
import 'package:url_launcher/url_launcher.dart';

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
      useEffect(() {
        for (dynamic item in rawFeed) {
          useEvents.value.add(Event.fromJson(item));
        }
      });
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, idx) {
            final event = useEvents.value[idx];
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
                        RepoPreview(repoName: event.repo!.name),
                        if (event.type != 'PushEvent' &&
                            event.type != 'WatchEvent' &&
                            event.type != 'ForkEvent' &&
                            event.type != 'CreateEvent' &&
                            event.type != 'PullRequestEvent' &&
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
                                    await launch(
                                        event.payload!['issue']['html_url']);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                        if (event.type == 'PullRequestEvent') ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.exit_to_app),
                                label: const Text('View PR'),
                                onPressed: () async {
                                  if (await canLaunch(event
                                      .payload!['pull_request']['html_url'])) {
                                    await launch(event.payload!['pull_request']
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
          childCount: childCount,
        ),
      );
    });
  }
}
