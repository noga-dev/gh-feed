import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:github/github.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'common.dart';

final dioProvider = Provider<Dio>((ref) => Dio());
final boxProvider = Provider<Box>((ref) => Hive.box(kBoxSharedPrefs));

final userProvider = StateProvider<User?>((ref) => null);

// TODO p3 put and retrieve from box
final reposCacheProvider = StateProvider<List<Repository>>((ref) => []);
final requestsCountProvider = StateProvider<int>((ref) => 0);

/// Stores an [AsyncSnapshot] as well as a reference to a function [refresh]
/// that should re-call the future that was used to generate the [snapshot].
class MemoizedAsyncSnapshot<T> {
  const MemoizedAsyncSnapshot(this.snapshot, this.refresh);

  final AsyncSnapshot<T> snapshot;
  final Function() refresh;
}

/// Subscribes to a [Future] and returns its current state in a
/// [MemoizedAsyncSnapshot].
/// The [future] is memoized and will only be re-called if any of the [keys]
/// change or if [MemoizedAsyncSnapshot.refresh] is called.
///
/// * [initialData] specifies what initial value the [AsyncSnapshot] should
///   have.
/// * [preserveState] defines if the current value should be preserved when
///   changing the [Future] instance.
///
/// See also:
///   * [useFuture], the hook responsible for getting the future.
///   * [useMemoized], the hook responsible for the memoization.
MemoizedAsyncSnapshot<T> useMemoizedFuture<T>(
  Future<T> Function() future, {
  List<Object> keys = const [],
  T? initialData,
  bool preserveState = true,
}) {
  final refresh = useState(0);
  final result = useFuture(
    useMemoized(future, [refresh.value, ...keys]),
    initialData: initialData,
    preserveState: preserveState,
  );

  void refreshMe() => refresh.value++;

  return MemoizedAsyncSnapshot<T>(result, refreshMe);
}
