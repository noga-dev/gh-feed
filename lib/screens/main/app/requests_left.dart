import 'package:flutter/material.dart';
import 'package:gaf/utils/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RequestsLeft extends HookConsumerWidget {
  const RequestsLeft({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(context, ref) {
    return Text(
      'Requests left: ${ref.watch(requestsCountProvider).state.toString()}',
    );
  }
}
