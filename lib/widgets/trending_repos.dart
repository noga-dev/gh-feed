import 'package:flutter/material.dart';
import 'package:gh_trend/gh_trend.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TrendingRepos extends StatelessWidget {
  const TrendingRepos({
    Key? key,
    required this.trendingRepos,
  }) : super(key: key);

  final List<GithubRepoItem> trendingRepos;

  @override
  Widget build(BuildContext context) {
    if (trendingRepos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    } else {
      return ListView.builder(
        itemCount: trendingRepos.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          Color? cardColor;
          if (trendingRepos[index].programmingLanguageColor == null) {
            cardColor = Theme.of(context).cardColor;
          } else {
            cardColor = Color(int.parse(trendingRepos[index]
                    .programmingLanguageColor!
                    .replaceAll('#', '0xff')))
                .withOpacity(0.25);
          }
          return Card(
            color: cardColor,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                      '${trendingRepos[index].owner}/${trendingRepos[index].repoName}'),
                  subtitle: Text(trendingRepos[index].description),
                  trailing: Text(trendingRepos[index].programmingLanguage),
                ),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    RepoDetailItem(
                      icon: const Icon(Icons.star_border),
                      label: '${trendingRepos[index].totalStars}',
                    ),
                    const SizedBox(width: 8),
                    RepoDetailItem(
                      icon: const Icon(MdiIcons.sourceFork),
                      label: '${trendingRepos[index].totalForks}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    }
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
