import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gaf/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FeedFilterDialog extends HookConsumerWidget {
  const FeedFilterDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterBox = ref.read(boxProvider);
    final checkBoxState =
        useState(filterBox.get('filterPushEvents', defaultValue: false));

    return SimpleDialog(
      title: const Text('Feed Filters'),
      children: [
        CheckboxListTile(
          value: checkBoxState.value,
          title: const Text('Filter PushEvents'),
          onChanged: (newValue) {
            checkBoxState.value = newValue;
            filterBox.put('filterPushEvents', newValue);
          },
        )
      ],
    );
  }
}
