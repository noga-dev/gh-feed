import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gaf/theme/github_colors.dart';
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
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                currentUser?.avatarUrl ?? defaultAvatar,
              ),
            ),
            title: Text(
              currentUser?.login ?? 'Anonymous',
              style: Theme.of(context).textTheme.headline6,
            ),
            trailing: OutlinedButton(
              style: OutlinedButton.styleFrom(
                primary: Theme.of(context).colorScheme.onBackground,
                shape: const StadiumBorder(),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              onPressed: () {
                if (currentUser?.login == null) {
                  showDialog(
                    context: context,
                    builder: (_) => SimpleDialog(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Auth Key',
                              filled: true,
                              fillColor: GhColors.grey.shade800,
                            ),
                            obscureText: true,
                            onChanged: (val) async {
                              try {
                                ref.read(dioProvider).options.headers.update(
                                      'Authorization',
                                      (value) => 'token $val',
                                      ifAbsent: () => 'token $val',
                                    );
                                unawaited(
                                  ref
                                      .read(boxProvider)
                                      .put(kBoxKeySecretApi, val),
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
                        ),
                        ButtonBar(
                          children: [
                            TextButton(
                              child: Text('Log In'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  unawaited(ref.read(boxProvider).clear());
                }
              },
              child: Text(currentUser?.login == null ? 'Log In' : 'Log Out'),
            ),
          ),
          if (kDebugMode) ...[
            const Divider(),
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
