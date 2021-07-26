import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ListViewer extends StatelessWidget {
  const ListViewer({
    Key? key,
    required this.refreshFunc,
    required this.data,
    required this.title,
    this.refreshText = '',
  }) : super(key: key);

  final String title;
  final Function() refreshFunc;
  final List<Widget> data;
  final String refreshText;

  @override
  Widget build(BuildContext context) {
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
                Interval(.1, .9, curve: Curves.easeInOut);
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
                          Text(refreshText.isEmpty ? 'Pull' : refreshText),
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
        HookBuilder(
          builder: (context) {
            final isTrendingRepo = data is List<MouseRegion>;
            final useAnimController = useAnimationController(
                duration: Duration(milliseconds: isTrendingRepo ? 1200 : 250))
              ..forward();
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return SlideTransition(
                    position: MaterialPointArcTween(
                      begin: isTrendingRepo
                          ? const Offset(0, 1)
                          : const Offset(-1, 0),
                      end: const Offset(0, 0),
                    ).animate(useAnimController),
                    child: data[index],
                  );
                },
                childCount: data.length,
              ),
            );
          },
        ),
      ],
    );
  }
}
