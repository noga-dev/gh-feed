import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';

class CreatedAt extends StatelessWidget {
  const CreatedAt({
    Key? key,
    required this.timeCreated,
  }) : super(key: key);

  final DateTime timeCreated;

  @override
  Widget build(BuildContext context) {
    return Text(
      GetTimeAgo.parse(timeCreated),
    );
  }
}
