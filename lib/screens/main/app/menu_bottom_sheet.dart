import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gaf/utils/common.dart';
import 'package:gaf/utils/providers.dart';
import 'package:gaf/utils/settings.dart';
import 'package:github/github.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:very_good_analysis/very_good_analysis.dart';

class MenuBottomSheet extends HookConsumerWidget {
  const MenuBottomSheet({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  final User? currentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal.shade700,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentUser?.login ?? defaultUserLogin,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 8),
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      currentUser?.avatarUrl ?? defaultAvatar,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.orange),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.all(12),
                      ),
                    ),
                    onPressed: () {
                      unawaited(ref.read(boxProvider).clear());
                    },
                    child: const Text('Log Out'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // TODO p4 make optional either username for only public data
                // OR key for private as well
                // AND add this as a separate option to track other users?
                TextField(
                  decoration: const InputDecoration(hintText: 'Auth Key'),
                  obscureText: true,
                  onChanged: (val) async {
                    try {
                      ref.read(dioProvider).options.headers.update(
                            'Authorization',
                            (value) => 'token $val',
                            ifAbsent: () => 'token $val',
                          );
                      unawaited(
                        ref.read(boxProvider).put(kBoxKeySecretApi, val),
                      );
                      // TODO p1 fix ui not refreshing since moving this
                      // useGetUserDetailsFuture.refresh();
                      // useGetUserReceivedEventsFuture.refresh();
                    } on DioError {
                      ref
                          .read(dioProvider)
                          .options
                          .headers
                          .remove('Authorization');
                    }
                  },
                ),
              ],
            ),
          ),
          if (kDebugMode) ...[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red.shade900),
              ),
              onPressed: () async {
                unawaited(ref.read(boxProvider).clear());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'box cleared',
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                    ),
                  ),
                );
              },
              child: const Text('clear box'),
            ),
            const Divider(),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.lightBlue.shade900),
              ),
              onPressed: () async {
                await ref.read(boxProvider).delete(kBoxKeySettings);
                await ref.read(boxProvider).put(
                      kBoxKeySettings,
                      Settings().toJson(),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'settings deleted',
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                    ),
                  ),
                );
              },
              child: const Text('delete settings'),
            ),
          ],
        ],
      ),
    );
  }
}
