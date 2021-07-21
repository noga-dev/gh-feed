import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gaf/providers.dart';
import 'package:gaf/settings.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Map<String, dynamic> defaults = {
  'filterPushEvents': false,
};

class FeedFilterDialog extends HookConsumerWidget {
  const FeedFilterDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterBox = ref.read(boxProvider);
    final settingsState =
        useState(filterBox.get('settings', defaultValue: defaults));
    print(settingsState.value);
    late Settings settings;
    if (settingsState.value.runtimeType == Settings) {
      settings = settingsState.value;
    } else {
      settings = Settings.fromJson(settingsState.value);
    }

    return SimpleDialog(
      title: const Text('Feed Filters'),
      children: [
        CheckboxListTile(
          value: settings.filterPushEvents,
          title: const Text('Filter PushEvents'),
          onChanged: (newValue) {
            settingsState.value = settings.copyWith(filterPushEvents: newValue);
            filterBox.put('settings', settings.toJson());
          },
        )
      ],
    );
  }
}
