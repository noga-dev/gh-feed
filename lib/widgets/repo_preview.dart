import 'package:flutter/material.dart';
import 'package:gaf/widgets/user_avatar.dart';
import 'package:github/github.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RepoPreview extends StatelessWidget {
  const RepoPreview({
    Key? key,
    required this.repo,
  }) : super(key: key);

  final Repository repo;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          if (await canLaunch(repo.htmlUrl)) {
            await launch(repo.htmlUrl);
          }
        },
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(
                  avatarUrl: repo.owner!.avatarUrl,
                  username: repo.owner!.login,
                  height: 24,
                ),
                const SizedBox(width: 8),
                Text(repo.name),
                const Spacer(),
                Text(repo.language),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(repo.description),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                RepoDetailItem(
                  icon: const Icon(Icons.remove_red_eye_outlined),
                  label: '${repo.watchersCount}',
                ),
                const SizedBox(width: 12),
                RepoDetailItem(
                  icon: const Icon(Icons.star_border),
                  label: '${repo.stargazersCount}',
                ),
                const SizedBox(width: 12),
                RepoDetailItem(
                  icon: const Icon(MdiIcons.sourceFork),
                  label: '${repo.forksCount}',
                ),
                const SizedBox(width: 12),
                RepoDetailItem(
                  icon: const Icon(Icons.info_outline),
                  label: '${repo.openIssuesCount}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RepoDetailItem extends StatelessWidget {
  const RepoDetailItem({
    Key? key,
    required this.icon,
    required this.label,
  }) : super(key: key);

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
