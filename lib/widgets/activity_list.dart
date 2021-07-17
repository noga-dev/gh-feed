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
                    title: RichText(
                      text: TextSpan(
                        children: [
                          const WidgetSpan(
                            child: Icon(Icons.chevron_right),
                            alignment: PlaceholderAlignment.bottom,
                          ),
                          WidgetSpan(
                            child: Icon(
                              event.payload!['action'].toString() == 'started'
                                  ? Icons.star
                                  : Icons.help,
                            ),
                          ),
                          const WidgetSpan(
                            child: Icon(Icons.chevron_right),
                            alignment: PlaceholderAlignment.bottom,
                          ),
                          TextSpan(
                            text: event.repo!.name.substring(
                              0,
                              event.repo!.name.indexOf('/'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: CreatedAt(
                      timeCreated: event.createdAt!,
                    ),
                  ),
                  Card(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: const Text('User'),
                      title: Text(
                        event.actor!.login!,
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: const Text('Repo'),
                      title: Text(
                        event.repo!.name,
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: const Text('Type'),
                      title: Text(
                        event.type!,
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
