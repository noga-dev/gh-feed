import 'package:flutter/material.dart';
import 'package:gaf/widgets/created_at.dart';
import 'package:gaf/widgets/user_avatar.dart';
import 'package:github/github.dart';
import 'package:google_fonts/google_fonts.dart';

class EventTitle extends StatelessWidget {
  const EventTitle({
    Key? key,
    required this.event,
  }) : super(key: key);

  final Event event;

  Widget _buildTitleText(Event event) {
    switch (event.type) {
      case 'CreateEvent':
        final refType = event.payload!['ref_type'];
        if (refType == 'branch') {
          final ref = event.payload!['ref'];
          return RichText(
            text: TextSpan(
              children: [
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
            ),
          );
        }
        return RichText(
          text: TextSpan(
            children: [
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
          ),
        );
      case ('ForkEvent'):
        return RichText(
          text: TextSpan(
            children: [
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
          ),
        );
      case 'IssueCommentEvent':
        final issue = event.payload!['issue'];
        return RichText(
          text: TextSpan(
            children: [
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
          ),
        );
      case 'PullRequestEvent':
        final number = event.payload!['number'];
        return RichText(
          text: TextSpan(
            children: [
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
              )
            ],
          ),
        );
      case 'PushEvent':
        final commitsCount = event.payload!['size'];
        final ref = event.payload!['ref'].split('/').last;
        final commitText = commitsCount == '1' ? 'commit' : 'commits';
        return RichText(
          text: TextSpan(
            children: [
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
          ),
        );
      case 'ReleaseEvent':
        final tagName = event.payload!['release']['tag_name'];
        return RichText(
          text: TextSpan(
            children: [
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
          ),
        );
      case 'WatchEvent':
        return RichText(
          text: TextSpan(
            children: [
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
          ),
        );
      default:
        return Text(event.actor!.login!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(
        username: event.actor!.login!,
        avatarUrl: event.actor!.avatarUrl!,
      ),
      title: _buildTitleText(event),
      subtitle: CreatedAt(
        timeCreated: event.createdAt!,
      ),
    );
  }
}
