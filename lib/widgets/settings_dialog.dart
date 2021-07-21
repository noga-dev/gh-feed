import 'package:flutter/material.dart';
import 'package:gaf/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsDialog extends HookConsumerWidget {
  const SettingsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.read(boxProvider).get('userLogin');
    print(username);
    return SimpleDialog(
      title: Text('Settings'),
      children: [
        username != null
            ? ListTile(
                leading: CircleAvatar(),
                title: Text(username),
                trailing: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    primary: Theme.of(context).colorScheme.onBackground,
                    shape: StadiumBorder(),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  child: Text('Log out'),
                  onPressed: () {},
                ),
              )
            : TextField(),
      ],
    );
  }
}
