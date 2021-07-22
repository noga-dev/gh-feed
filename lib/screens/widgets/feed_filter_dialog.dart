import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gaf/utils/common.dart';
import 'package:gaf/utils/providers.dart';
import 'package:gaf/utils/settings.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Map<String, dynamic> defaults = {
//   'filterPushEvents': false,
// };

class FeedFilterDialog extends HookConsumerWidget {
  const FeedFilterDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsBox = ref.read(boxProvider);
    final useSettingsState = useState(
      Settings.fromJson(settingsBox.get(kBoxKeySettings)),
    );

    // late Settings settings;

    // if (settingsState.value.runtimeType == Settings) {
    //   settings = settingsState.value;
    // } else {
    //   settings = Settings.fromJson(settingsState.value);
    // }

    return SimpleDialog(
      title: const Text('Feed Filters'),
      children: [
        CheckboxListTile(
          value: useSettingsState.value.filterPushEvents,
          title: const Text('Filter PushEvents'),
          onChanged: (newValue) {
            useSettingsState.value =
                useSettingsState.value.copyWith(filterPushEvents: newValue);
            settingsBox.put(kBoxKeySettings, useSettingsState.value.toJson());
          },
        )
      ],
    );
  }
}
