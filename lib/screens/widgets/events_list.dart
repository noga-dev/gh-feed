import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gaf/utils/settings.dart';
import 'package:github/github.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timeago/timeago.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_themes.dart';
import '../../utils/providers.dart';
import 'components/list_viewer.dart';
import 'events_list/event_card.dart';
import 'events_list/event_title.dart';
import 'events_list/repo_preview.dart';

class EventsList extends HookConsumerWidget {
  const EventsList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(context, ref) {
    final useEvents = useState(<SliverEventItem>[]);
    final useFilteredEvents = useState(<SliverEventItem>[]);
    final useUpdateTime = useState(DateTime.now());
    final filter = ref.watch(settingsProvider).state;
    return ref
        .watch(
          dioGetProvider(
            '/users/${ref.read(userProvider).state.login}/received_events',
          ),
        )
        .when(
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          error: (err, stack) => Text(stack?.toString() ?? ''),
          data: (data) {
            useEffect(() {
              for (var item in data.data) {
                final event = Event.fromJson(item);
                if (event.payload!.isNotEmpty) {
                  useEvents.value.add(SliverEventItem(event: event));
                }
              }
            }, [data.data]);

            useEffect(() {
              useFilteredEvents.value = useEvents.value;
              if (filter.filterPushEvent) {
                useFilteredEvents.value = useFilteredEvents.value
                    .where((element) =>
                        element.event.type != Settings.kFilterPushEvent)
                    .toList();
              }
              if (filter.filterForkEvent) {
                useFilteredEvents.value = useFilteredEvents.value
                    .where((element) =>
                        element.event.type != Settings.kFilterForkEvent)
                    .toList();
              }
              if (filter.filterWatchEvent) {
                useFilteredEvents.value = useFilteredEvents.value
                    .where((element) =>
                        element.event.type != Settings.kFilterWatchEvent)
                    .toList();
              }
              if (filter.filterCreateEvent) {
                useFilteredEvents.value = useFilteredEvents.value
                    .where((element) =>
                        element.event.type != Settings.kFilterCreateEvent)
                    .toList();
              }
              if (filter.filterPullRequestEvent) {
                useFilteredEvents.value = useFilteredEvents.value
                    .where((element) =>
                        element.event.type != Settings.kFilterPullRequestEvent)
                    .toList();
              }
              if (filter.filterReleaseEvent) {
                useFilteredEvents.value = useFilteredEvents.value
                    .where((element) =>
                        element.event.type != Settings.kFilterReleaseEvent)
                    .toList();
              }
            }, [filter]);

            return ListViewer(
              refreshFunc: () => ref.refresh(dioGetProvider(
                  '/users/${ref.read(userProvider).state.login}/received_events')),
              title: 'Activity Feed',
              refreshText: format(useUpdateTime.value),
              data: useFilteredEvents.value,
            );
          },
        );
  }
}

class SliverEventItem extends HookConsumerWidget {
  const SliverEventItem({
    Key? key,
    required this.event,
  }) : super(key: key);

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(dioGetProvider('/repos/${event.repo!.name}')).when(
          loading: () => const CircularProgressIndicator.adaptive(),
          error: (err, stack) => Text(stack?.toString() ?? ''),
          data: (data) {
            return Card(
              color: Theme.of(context).brightness == Brightness.dark
                  ? themeDataDark.cardColor
                  : themeDataLight.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  EventsListView(
                    title: EventTitle(
                      event: event,
                    ),
                    content: Column(
                      children: [
                        RepoPreview(
                          repo: Repository.fromJson(
                            data.data,
                          ),
                        ),
                        if (event.type == 'IssueCommentEvent') ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.exit_to_app),
                                label: const Text('View issue'),
                                onPressed: () async {
                                  if (await canLaunch(
                                      event.payload!['issue']['html_url'])) {
                                    await launch(
                                        event.payload!['issue']['html_url']);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
  }
}

class ErrorPreview extends StatelessWidget {
  const ErrorPreview({
    Key? key,
    required this.request,
    required this.error,
  }) : super(key: key);

  final String request;
  final String error;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: RepoPreview.totalPreviewBoxHeight,
      child: SingleChildScrollView(
        child: Text(
          error,
          style: TextStyle(color: Colors.red.shade300),
        ),
      ),
    );
  }
}
