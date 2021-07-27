import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ListViewer extends HookConsumerWidget {
  const ListViewer({
    Key? key,
    required this.refreshFunc,
    required this.data,
    required this.title,
  }) : super(key: key);

  final String title;
  final Function() refreshFunc;
  final List<Widget> data;

  @override
  Widget build(context, ref) {
    final isTrendingRepo = data is List<MouseRegion>;
    final useUpdateTime = useState(DateTime.now());
    useEffect(() {
      useUpdateTime.value = DateTime.now();
    }, [refreshFunc]);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async => refreshFunc(),
          builder: (
            context,
            RefreshIndicatorMode refreshState,
            double pulledExtent,
            double refreshTriggerPullDistance,
            double refreshIndicatorExtent,
          ) {
            const Curve opacityCurve =
                Interval(.1, .9, curve: Curves.easeInToLinear);
            return Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: refreshState == RefreshIndicatorMode.drag
                    ? Opacity(
                        opacity: opacityCurve.transform(
                          min(pulledExtent / refreshTriggerPullDistance, 1.0),
                        ),
                        child: OverflowBar(children: [
                          Transform.rotate(
                            angle: pulledExtent / 4,
                            child: const Icon(
                              Icons.refresh,
                              color: CupertinoColors.inactiveGray,
                              size: 24.0,
                            ),
                          ),
                          Text(GetTimeAgo.parse(useUpdateTime.value)),
                        ]),
                      )
                    : Opacity(
                        opacity: opacityCurve.transform(
                            min(pulledExtent / refreshIndicatorExtent, 1.0)),
                        child:
                            const CircularProgressIndicator(strokeWidth: 2.0),
                      ),
              ),
            );
          },
        ),
        SliverAppBar(
          floating: true,
          snap: true,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
        SliverAnimatedList(
          itemBuilder: (context, index, anim) {
            return SlideTransition(
              position: MaterialPointArcTween(
                begin:
                    isTrendingRepo ? const Offset(0, 1) : const Offset(-1, 0),
                end: const Offset(0, 0),
              ).animate(anim),
              child: data[index],
            );
          },
          initialItemCount: data.length,
        ),
      ],
    );
  }
}
