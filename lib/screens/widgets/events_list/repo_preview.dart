import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../user_avatar.dart';

const _horizontalDivider = Divider(
  height: 8.0,
  color: Colors.transparent,
);
const _iconsDivider = SizedBox(
  height: 12.0,
  width: 12.0,
);

class RepoPreview extends StatelessWidget {
  const RepoPreview({
    Key? key,
    required this.repo,
  }) : super(key: key);

  final Repository repo;

  static const totalPreviewBoxHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () async {
          if (await canLaunch(repo.htmlUrl)) {
            await launch(repo.htmlUrl);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(
                  avatarUrl: repo.owner!.avatarUrl,
                  height: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    repo.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(repo.language),
              ],
            ),
            _horizontalDivider,
            Row(
              children: [
                Expanded(
                  child: Text(
                    repo.description,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            _horizontalDivider,
            Row(
              children: [
                RepoDetailItem(
                  icon: const Icon(Icons.remove_red_eye_outlined),
                  label: '${repo.subscribersCount}',
                ),
                _iconsDivider,
                RepoDetailItem(
                  icon: const Icon(Icons.star_border),
                  label: '${repo.stargazersCount}',
                ),
                _iconsDivider,
                RepoDetailItem(
                  icon: const Icon(MdiIcons.sourceFork),
                  label: '${repo.forksCount}',
                ),
                _iconsDivider,
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
