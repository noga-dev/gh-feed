import 'package:flutter/material.dart';
import 'package:gaf/theme/app_themes.dart';
import 'package:gaf/theme/github_colors.dart';
import 'package:gaf/widgets/created_at.dart';
import 'package:gaf/widgets/event_card.dart';
import 'package:gaf/widgets/event_title.dart';
import 'package:gaf/widgets/repo_preview.dart';
import 'package:gaf/widgets/user_avatar.dart';
import 'package:github/github.dart';

class ActivityList extends StatefulWidget {
  const ActivityList({
    Key? key,
    required this.rawFeed,
    required this.childCount,
  }) : super(key: key);

  final dynamic rawFeed;
  final int childCount;

  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  final List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    for (dynamic item in widget.rawFeed) {
      _events.add(Event.fromJson(item));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, idx) {
          final event = _events[idx];
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
                    event: _events[idx],
                  ),
                  content: Column(
                    children: [
                      RepoPreview(repoName: event.repo!.name),
                      if (event.type != 'PushEvent' &&
                          event.type != 'WatchEvent' &&
                          event.type != 'ForkEvent' &&
                          event.type != 'ReleaseEvent') ...[
                        ListTile(
                          leading: const Text('Type'),
                          title: Text(
                            event.type!,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        childCount: widget.childCount,
      ),
    );
  }
}
