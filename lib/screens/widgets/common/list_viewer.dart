import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListViewer extends StatelessWidget {
  const ListViewer({
    Key? key,
    required this.refreshFunc,
    required this.data,
    required this.title,
  }) : super(key: key);

  final String title;
  final Function() refreshFunc;
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async => refreshFunc(),
        ),
        SliverAppBar(
          pinned: true,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(data),
          ),
        ),
      ],
    );
  }
}
