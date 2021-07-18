import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    Key? key,
    required this.avatarUrl,
    required this.username,
    this.height = 36,
    this.borderRadius = 8,
  }) : super(key: key);

  final String avatarUrl;
  final double height;
  final double borderRadius;
  final String username;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        avatarUrl,
        height: height,
      ),
    );
  }
}
