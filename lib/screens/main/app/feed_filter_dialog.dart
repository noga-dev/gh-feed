import 'package:flutter/material.dart';
import 'package:gaf/utils/common.dart';
import 'package:gaf/utils/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FeedFilterDialog extends HookConsumerWidget {
  const FeedFilterDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsBox = ref.read(boxProvider);
    final useSettingsProvider = ref.watch(settingsProvider);

    return SimpleDialog(
      title: const Text('Feed Filters'),
      children: [
        CheckboxListTile(
          value: useSettingsProvider.state.filterPushEvents,
          title: const Text('Filter PushEvents'),
          onChanged: (newValue) {
            settingsBox.put(
              kBoxKeySettings,
              useSettingsProvider.state
                  .copyWith(filterPushEvents: newValue)
                  .toJson(),
            );
          },
        ),
        CheckboxListTile(
          value: useSettingsProvider.state.filterDeleteEvents,
          title: const Text('Filter DeleteEvents'),
          onChanged: (newValue) {
            settingsBox.put(
              kBoxKeySettings,
              useSettingsProvider.state
                  .copyWith(filterDeleteEvents: newValue)
                  .toJson(),
            );
          },
        ),
      ],
    );
  }
}
