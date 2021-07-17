import 'package:flutter/material.dart';
import 'package:gaf/theme/app_themes.dart';
import 'package:gaf/theme/github_colors.dart';
import 'package:gaf/widgets/created_at.dart';
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
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Theme.of(context).brightness == Brightness.dark
                  ? themeDataDark.cardColor
                  : themeDataLight.cardColor,
              child: Column(
                children: [
                  ListTile(
                    leading: UserAvatar(
                      avatarUrl: event.actor!.avatarUrl!,
                      username: event.actor!.login!,
                    ),
                    title: Text(event.actor!.login!),
                    trailing: CreatedAt(
                      timeCreated: event.createdAt!,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? GhColors.grey.shade900
                          : Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Text('Repo'),
                            title: Text(
                              event.repo!.name,
                            ),
                          ),
                          ListTile(
                            leading: const Text('Type'),
                            title: Text(
                              event.type!,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: widget.childCount,
      ),
    );
  }
}
