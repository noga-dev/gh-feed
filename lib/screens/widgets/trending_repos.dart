import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gaf/utils/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SomeClass extends StatefulHookWidget {
  const SomeClass({Key? key}) : super(key: key);

  @override
  _SomeClassState createState() => _SomeClassState();
}

class _SomeClassState extends State<SomeClass> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class TrendingRepos extends HookConsumerWidget {
  const TrendingRepos({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(context, ref) {
    return ref.watch(trendingReposProvider).when(
          loading: () => const CircularProgressIndicator.adaptive(),
          error: (err, stack) => Text(err.toString()),
          data: (data) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () => Future<void>.value(
                    ref.refresh(trendingReposProvider),
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
                        Color? cardColor;
                        if (data[index].programmingLanguageColor == null) {
                          cardColor = Theme.of(context).cardColor;
                        } else {
                          cardColor = Color(int.parse(data[index]
                                  .programmingLanguageColor!
                                  .replaceAll('#', '0xff')))
                              .withOpacity(0.25);
                        }
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              if (await canLaunch(
                                  'https://github.com/${data[index].owner}/${data[index].repoName}')) {
                                await launch(
                                    'https://github.com/${data[index].owner}/${data[index].repoName}');
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
                                        '${data[index].owner}/${data[index].repoName}'),
                                    subtitle: Text(data[index].description),
                                    trailing:
                                        Text(data[index].programmingLanguage),
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(width: 16),
                                      RepoDetailItem(
                                        icon: const Icon(Icons.star_border),
                                        label: '${data[index].totalStars}',
                                      ),
                                      const SizedBox(width: 8),
                                      RepoDetailItem(
                                        icon: const Icon(MdiIcons.sourceFork),
                                        label: '${data[index].totalForks}',
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
                      childCount: data.length,
                    ),
                  ),
                ),
              ],
            );
          },
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
