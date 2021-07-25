import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gaf/utils/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TrendingRepos extends HookConsumerWidget {
  const TrendingRepos({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(context, ref) {
    final useGetTrendingRepos = useMemoizedFuture(
      () => ref.read(trendingReposProvider),
      keys: [],
    );

    if (!useGetTrendingRepos.snapshot.hasData) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (useGetTrendingRepos.snapshot.hasError) {
      return Scaffold(
        body: Center(
          child: Text(
            useGetTrendingRepos.snapshot.error.toString(),
          ),
        ),
      );
    }

    final trendingRepos = useGetTrendingRepos.snapshot.data!;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () => Future<void>.value(
            useGetTrendingRepos.refresh(),
          ),
        ),
        SliverAppBar(
          pinned: true,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Trending Repos',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (trendingRepos.isEmpty) {
                  return const CircularProgressIndicator.adaptive();
                }
                Color? cardColor;
                if (trendingRepos[index].programmingLanguageColor == null) {
                  cardColor = Theme.of(context).cardColor;
                } else {
                  cardColor = Color(int.parse(trendingRepos[index]
                          .programmingLanguageColor!
                          .replaceAll('#', '0xff')))
                      .withOpacity(0.25);
                }
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      if (await canLaunch(
                          'https://github.com/${trendingRepos[index].owner}/${trendingRepos[index].repoName}')) {
                        await launch(
                            'https://github.com/${trendingRepos[index].owner}/${trendingRepos[index].repoName}');
                      }
                    },
                    child: Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                                '${trendingRepos[index].owner}/${trendingRepos[index].repoName}'),
                            subtitle: Text(trendingRepos[index].description),
                            trailing:
                                Text(trendingRepos[index].programmingLanguage),
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
                    ),
                  ),
                );
              },
              childCount: trendingRepos.length,
            ),
          ),
        ),
      ],
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
