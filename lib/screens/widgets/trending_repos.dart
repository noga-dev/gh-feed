import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gaf/utils/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common/list_viewer.dart';

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
          data: (data) => ListViewer(
            refreshFunc: () => ref.refresh(trendingReposProvider),
            title: 'Trending Repos',
            data: data.map(
              (e) {
                Color? cardColor;
                if (e.programmingLanguageColor == null) {
                  cardColor = Theme.of(context).cardColor;
                } else {
                  cardColor = Color(int.parse(
                          e.programmingLanguageColor!.replaceAll('#', '0xff')))
                      .withOpacity(0.25);
                }
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      if (await canLaunch(
                          'https://github.com/${e.owner}/${e.repoName}')) {
                        await launch(
                            'https://github.com/${e.owner}/${e.repoName}');
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
                            title: Text('${e.owner}/${e.repoName}'),
                            subtitle: Text(e.description),
                            trailing: Text(e.programmingLanguage),
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 16),
                              RepoDetailItem(
                                icon: const Icon(Icons.star_border),
                                label: '${e.totalStars}',
                              ),
                              const SizedBox(width: 8),
                              RepoDetailItem(
                                icon: const Icon(MdiIcons.sourceFork),
                                label: '${e.totalForks}',
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
            ).toList(),
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
