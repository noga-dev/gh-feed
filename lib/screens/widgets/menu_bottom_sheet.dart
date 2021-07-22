import 'package:flutter/material.dart';
import 'package:gaf/screens/widgets/user_avatar.dart';
import 'package:gaf/utils/mock_data.dart';
import 'package:gaf/utils/providers.dart';
import 'package:github/github.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:very_good_analysis/very_good_analysis.dart';

class MenuBottomSheet extends HookConsumerWidget {
  const MenuBottomSheet({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  final User currentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: UserAvatar(
              avatarUrl: currentUser.avatarUrl ?? mockDefaultAvatar,
              borderRadius: 25,
            ),
            title: Text(currentUser.login!),
            trailing: OutlinedButton(
              child: Text('Log Out'),
              onPressed: () {
                unawaited(ref.read(boxProvider).clear());
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
