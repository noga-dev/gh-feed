import 'package:flutter/material.dart';
import 'package:gaf/theme/github_colors.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  final Widget title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        title,
        //const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? GhColors.grey.shade900
                  : Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: GhColors.grey.shade400!,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: content,
            ),
          ),
        ),
      ],
    );
  }
}
