import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gaf/screens/widgets/public_event.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../utils/common.dart';
import '../../utils/providers.dart';
import '../widgets/events_list.dart';
import '../widgets/trending_repos.dart';
import 'app/feed_filter_dialog.dart';
import 'app/menu_bottom_sheet.dart';

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Builder(
            builder: (context) => IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(
                  ref.read(userProvider).state?.avatarUrl ?? defaultAvatar,
                ),
              ),
              onPressed: () {
                const child = SettingsView();
                isMobileDevice
                    ? showModalBottomSheet(
                        context: context,
                        builder: (_) => child,
                      )
                    : showDialog(
                        context: context,
                        builder: (_) => const Dialog(
                          child: child,
                        ),
                      );
              },
            ),
          ),
        ),
        title: Text(
          kDebugMode
              // ignore: lines_longer_than_80_chars
              ? 'Requests left: ${ref.watch(requestsCountProvider).state.toString()}'
              : 'Activity Feed',
        ),
        actions: [
          IconButton(
            icon: const Icon(MdiIcons.filterOutline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const FeedFilterDialog(),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final user = ref.watch(userProvider).state;
          if (constraints.maxWidth < 700) {
            return user == null ? const PublicEvents() : const EventsList();
          } else {
            return Row(
              children: [
                Expanded(
                  child:
                      user == null ? const PublicEvents() : const EventsList(),
                ),
                const Expanded(
                  child: TrendingRepos(),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 700
          ? BottomNavigationBar(
              currentIndex: ref.watch(pageIndexProvider).state,
              onTap: (value) => ref.read(pageIndexProvider).state = value,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.feed),
                  label: 'Feed',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.trending_up),
                  label: 'Trending',
                ),
              ],
            )
          : null,
    );
  }
}
