import 'package:flutter/material.dart';

class RequestsLeft extends StatelessWidget {
  const RequestsLeft({
    Key? key,
    required this.count,
  }) : super(key: key);

  final String count;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Requests left: $count',
    );
  }
}
