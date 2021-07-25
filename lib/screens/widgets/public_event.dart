import 'package:flutter/material.dart';
import 'package:gaf/utils/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PublicEvents extends HookConsumerWidget {
  const PublicEvents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useGetPublicEvents = useMemoizedFuture(
        () => ref.read(httpGetProvider('/events')),
        keys: [ref.read(userProvider)]);

    if (!useGetPublicEvents.snapshot.hasData) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (useGetPublicEvents.snapshot.hasError) {
      return Center(
        child: Text(
          useGetPublicEvents.snapshot.error.toString(),
        ),
      );
    }

    // TODO p5 switch to sliver
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Trending Repos',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Expanded(
          child: ListView(
            children: (useGetPublicEvents.snapshot.data!.data as List).map(
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
        ),
      ],
    );
  }
}
