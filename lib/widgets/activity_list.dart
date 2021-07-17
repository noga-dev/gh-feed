import 'package:flutter/material.dart';
import 'package:gaf/theme/github_colors.dart';
import 'package:gaf/widgets/created_at.dart';
import 'package:gaf/widgets/user_avatar.dart';

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
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, idx) {
          final event = rawFeed[idx];
          return Card(
            color: event['public']
                ? GhColors.green.shade800!.withOpacity(.5)
                : GhColors.orange.shade800!.withOpacity(.5),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 10) +
                      const EdgeInsets.only(left: 12, right: 4),
              leading: UserAvatar(
                avatarUrl: event['actor']['avatar_url'].toString(),
                username: event['actor']['login'],
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
                        event['payload']['action'].toString() == 'started'
                            ? Icons.star
                            : Icons.help,
                      ),
                    ),
                    const WidgetSpan(
                      child: Icon(Icons.chevron_right),
                      alignment: PlaceholderAlignment.bottom,
                    ),
                    TextSpan(
                      text: event['repo']['name'].toString().substring(
                            0,
                            event['repo']['name'].toString().indexOf('/'),
                          ),
                    ),
                  ],
                ),
              ),
              trailing: CreatedAt(
                timeCreated: event['created_at'],
              ),
              children: [
                Card(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Text('User'),
                    title: Text(
                      event['actor']['display_login'].toString(),
                    ),
                  ),
                ),
                Card(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Text('Repo'),
                    title: Text(
                      event['repo']['name'].toString(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        childCount: childCount,
      ),
    );
  }
}
