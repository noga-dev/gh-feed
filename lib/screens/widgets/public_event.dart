import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaf/screens/widgets/components/list_viewer.dart';
import 'package:gaf/utils/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PublicEvents extends HookConsumerWidget {
  const PublicEvents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(dioGetProvider('/events')).when(
          loading: () => const CircularProgressIndicator.adaptive(),
          error: (err, stack) => Text(err.toString()),
          data: (data) => ListViewer(
            refreshFunc: () {
              return ref.refresh(dioGetProvider('/events'));
            },
            title: 'Public Events',
            data: (data.data as List).map(
              (e) {
                var payload = e['type'];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(e['actor']['avatar_url']),
                    ),
                    title: Text(e['repo']['name'] ?? 'error'),
                    subtitle: Text(payload),
                  ),
                );
              },
            ).toList(),
          ),
        );
  }
}
