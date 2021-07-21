import 'package:flutter/material.dart';
import 'package:gaf/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FeedFilterDialog extends HookConsumerWidget {
  const FeedFilterDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterBox = ref.watch(boxProvider);
    return SimpleDialog(
      title: const Text('Feed Filters'),
      children: [
        CheckboxListTile(
          value: filterBox.get('filterPushEvents') ?? false,
          title: const Text('Filter PushEvents'),
          onChanged: (newValue) => filterBox.put('filterPushEvents', newValue),
        )
      ],
    );
  }
}
