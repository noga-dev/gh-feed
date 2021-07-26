import 'package:flutter/material.dart';
import 'package:gaf/utils/common.dart';
import 'package:gaf/utils/providers.dart';
import 'package:gaf/utils/settings.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FeedFilterDialog extends HookConsumerWidget {
  const FeedFilterDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsBox = ref.read(boxProvider);
    final useSettingsProvider = ref.watch(settingsProvider);

    void setFilter(String filter) {
      switch (filter) {
        case Settings.kFilterPushEvent:
          useSettingsProvider.state = useSettingsProvider.state.copyWith(
              filterPushEvent: !useSettingsProvider.state.filterPushEvent);
          break;
        case Settings.kFilterForkEvent:
          useSettingsProvider.state = useSettingsProvider.state.copyWith(
              filterForkEvent: !useSettingsProvider.state.filterForkEvent);
          break;
        case Settings.kFilterWatchEvent:
          useSettingsProvider.state = useSettingsProvider.state.copyWith(
              filterWatchEvent: !useSettingsProvider.state.filterWatchEvent);
          break;
        case Settings.kFilterCreateEvent:
          useSettingsProvider.state = useSettingsProvider.state.copyWith(
              filterCreateEvent: !useSettingsProvider.state.filterCreateEvent);
          break;
        case Settings.kFilterPullRequestEvent:
          useSettingsProvider.state = useSettingsProvider.state.copyWith(
              filterPullRequestEvent:
                  !useSettingsProvider.state.filterPullRequestEvent);
          break;
        case Settings.kFilterReleaseEvent:
          useSettingsProvider.state = useSettingsProvider.state.copyWith(
              filterReleaseEvent:
                  !useSettingsProvider.state.filterReleaseEvent);
          break;
        default:
          break;
      }
      settingsBox.put(
        kBoxKeySettings,
        useSettingsProvider.state.toJson(),
      );
    }

    return SimpleDialog(
      title: const Text('Feed Filters'),
      children: [
        CheckboxListTile(
          value: useSettingsProvider.state.filterPushEvent,
          title: const Text('Filter Push'),
          onChanged: (newValue) => setFilter(Settings.kFilterPushEvent),
        ),
        CheckboxListTile(
          value: useSettingsProvider.state.filterForkEvent,
          title: const Text('Filter Fork'),
          onChanged: (newValue) => setFilter(Settings.kFilterForkEvent),
        ),
        CheckboxListTile(
          value: useSettingsProvider.state.filterWatchEvent,
          title: const Text('Filter Star'),
          onChanged: (newValue) => setFilter(Settings.kFilterWatchEvent),
        ),
        CheckboxListTile(
          value: useSettingsProvider.state.filterCreateEvent,
          title: const Text('Filter Created'),
          onChanged: (newValue) => setFilter(Settings.kFilterCreateEvent),
        ),
        CheckboxListTile(
          value: useSettingsProvider.state.filterPullRequestEvent,
          title: const Text('Filter PR'),
          onChanged: (newValue) => setFilter(Settings.kFilterPullRequestEvent),
        ),
        CheckboxListTile(
          value: useSettingsProvider.state.filterReleaseEvent,
          title: const Text('Filter Release'),
          onChanged: (newValue) => setFilter(Settings.kFilterReleaseEvent),
        ),
      ],
    );
  }
}
