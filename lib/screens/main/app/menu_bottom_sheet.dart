import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:very_good_analysis/very_good_analysis.dart';

import '../../../models/user.dart';
import '../../../theme/github_colors.dart';
import '../../../utils/common.dart';
import '../../../utils/providers.dart';
import '../../../utils/settings.dart';

class MenuBottomSheet extends HookConsumerWidget {
  const MenuBottomSheet({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useUser = ref.watch(userProvider);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ModalDrawerHandle(),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                useUser.state?.avatarUrl ?? defaultAvatar,
              ),
            ),
            title: Text(
              useUser.state?.login ?? 'Anonymous',
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
                if (useUser.state == null) {
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
                                final res =
                                    await ref.read(dioProvider).get('/user');
                                ref.read(userProvider).state =
                                    UserWrapper.fromJsonHive(res.data);
                                unawaited(
                                  ref.read(boxProvider).put(
                                        kBoxKeyUserJson,
                                        res.data,
                                      ),
                                );
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
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Log In'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  unawaited(ref.read(boxProvider).clear());
                  ref.read(userProvider).state = null;
                }
              },
              child: Text(useUser.state == null ? 'Log In' : 'Log Out'),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('GitHub Activity Feed'),
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
