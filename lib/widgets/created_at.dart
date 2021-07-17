import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart';

class CreatedAt extends StatelessWidget {
  const CreatedAt({
    Key? key,
    required this.timeCreated,
  }) : super(key: key);

  final String timeCreated;

  @override
  Widget build(BuildContext context) {
    return Text(
      format(
        DateTime.parse(
          timeCreated,
        ),
      ),
    );
  }
}
