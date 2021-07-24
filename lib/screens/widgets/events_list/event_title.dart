import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:google_fonts/google_fonts.dart';

import '../user_avatar.dart';
import 'created_at.dart';

class EventTitle extends StatelessWidget {
  const EventTitle({
    Key? key,
    required this.event,
  }) : super(key: key);

  final Event event;

  TextSpan _buildTitleText(Event event) {
    var textSpanList = <TextSpan>[];
    switch (event.type) {
      case 'CreateEvent':
        final refType = event.payload!['ref_type'];
        if (refType == 'branch') {
          final ref = event.payload!['ref'];
          textSpanList.addAll(
            [
              TextSpan(
                text: event.actor!.login,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' created $refType ',
              ),
              TextSpan(
                style: GoogleFonts.firaCode(),
                text: '$ref',
              ),
              const TextSpan(
                text: ' at ',
              ),
              TextSpan(
                text: event.repo!.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        } else {
          textSpanList.addAll(
            [
              TextSpan(
                text: event.actor!.login,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: ' created ',
              ),
              TextSpan(
                text: event.repo!.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }
        break;
      case 'DeleteEvent':
        if (event.payload!['ref_type'] == 'branch') {
          textSpanList.addAll([
            TextSpan(
              text: event.actor!.login,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: ' deleted branch ',
            ),
            TextSpan(
              style: GoogleFonts.firaCode(),
              text: '${event.payload!['ref']}',
            ),
            const TextSpan(
              text: ' at ',
            ),
            TextSpan(
              text: event.repo!.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ]);
        } else {
          textSpanList.addAll([
            TextSpan(
              text: event.actor!.login,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: ' deleted ',
            ),
          ]);
        }
        break;
      case ('ForkEvent'):
        textSpanList.addAll(
          [
            TextSpan(
              text: event.actor!.login,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: ' forked ',
            ),
            TextSpan(
              text: event.repo!.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
        break;
      case 'IssueCommentEvent':
        final issue = event.payload!['issue'];
        textSpanList.addAll(
          [
            TextSpan(
              text: event.actor!.login,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: ' commented on issue ',
            ),
            TextSpan(
              text: '#${issue['number']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: ' at ',
            ),
            TextSpan(
              text: event.repo!.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
        break;
      case 'PullRequestEvent':
        final number = event.payload!['number'];
        textSpanList.addAll(
          [
            TextSpan(
              text: event.actor!.login,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: ' opened pull request #$number to ',
            ),
            TextSpan(
              text: event.repo!.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
        break;
      case 'PushEvent':
        final commitsCount = event.payload!['size'];
        final ref = event.payload!['ref'].split('/').last;
        final commitText = commitsCount == '1' ? 'commit' : 'commits';
        textSpanList.addAll(
          [
            TextSpan(
              text: event.actor!.login,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: ' pushed $commitsCount $commitText to ',
            ),
            TextSpan(
              text: '${event.repo!.name}/$ref',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
        break;
      case 'ReleaseEvent':
        final tagName = event.payload!['release']['tag_name'];
        textSpanList.addAll(
          [
            TextSpan(
              text: event.actor!.login,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: ' released version ',
            ),
            TextSpan(
              text: tagName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: ' of ',
            ),
            TextSpan(
              text: event.repo!.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
        break;
      case 'WatchEvent':
        textSpanList.addAll(
          [
            TextSpan(
              text: event.actor!.login,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: ' starred ',
            ),
            TextSpan(
              text: event.repo!.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
        break;
      default:
        return TextSpan(text: event.actor!.login!);
    }
    return TextSpan(children: textSpanList);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(
        avatarUrl: event.actor!.avatarUrl!,
      ),
      title: SelectableText.rich(
        _buildTitleText(event),
      ),
      subtitle: CreatedAt(
        timeCreated: event.createdAt!,
      ),
    );
  }
}
