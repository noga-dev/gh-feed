import 'package:flutter/material.dart';
import 'package:gaf/providers.dart';
import 'package:gaf/widgets/user_avatar.dart';
import 'package:github/github.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RepoPreview extends HookConsumerWidget {
  const RepoPreview({
    Key? key,
    required this.repoName,
  }) : super(key: key);

  final String repoName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useGetRepoDetails = useMemoizedFuture(() async {
      return ref.watch(dioProvider).get('/repos/$repoName');
    });
    final repo = Repository.fromJson(useGetRepoDetails.snapshot.data!.data);
    return Column(
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
            Text(repoName),
            const Spacer(),
            Text(repo.language),
          ],
        ),
      ],
    );
  }
}
