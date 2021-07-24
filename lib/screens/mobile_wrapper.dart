import 'package:flutter/material.dart';
import 'package:gaf/utils/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MobileWrapper extends HookConsumerWidget {
  const MobileWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (ref.watch(pageIndexProvider).state) {
      case 0:
        // return feed
        return const SizedBox.shrink();
      case 1:
        // return trending
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }
}
