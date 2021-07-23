import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gaf/theme/github_colors.dart';
import 'package:gaf/utils/common.dart';
import 'package:gaf/utils/providers.dart';
import 'package:gaf/utils/settings.dart';
import 'package:github/github.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:very_good_analysis/very_good_analysis.dart';

class MenuBottomSheet extends HookConsumerWidget {
  const MenuBottomSheet({
    Key? key,
    required this.refreshDelegate,
  }) : super(key: key);

  final MemoizedAsyncSnapshot refreshDelegate;

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
                if (useUser.state?.login == null) {
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
                                await ref
                                    .read(dioProvider)
                                    .get('/user')
                                    .then((value) {
                                  ref.read(boxProvider).put(
                                      kBoxKeyUserLogin, value.data['login']);
                                  ref.read(userProvider).state =
                                      User.fromJson(value.data);
                                  return value;
                                });
                                refreshDelegate.refresh();
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
                }
              },
              child: Text(useUser.state?.login == null ? 'Log In' : 'Log Out'),
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
