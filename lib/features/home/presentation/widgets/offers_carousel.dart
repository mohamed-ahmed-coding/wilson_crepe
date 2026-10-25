import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';

class OffersCarousel extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Duration autoPlayInterval;

  const OffersCarousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.autoPlayInterval = const Duration(seconds: 5),
  });

  @override
  State<OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<OffersCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant OffersCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      if (_current >= widget.itemCount) {
        _current = 0;
        if (_controller.hasClients) _controller.jumpToPage(0);
      }
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (widget.itemCount < 2) return;
    _timer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_current + 1) % widget.itemCount;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 190.h,
          child: NotificationListener<ScrollStartNotification>(
            onNotification: (n) {
              if (n.dragDetails != null) _startAutoPlay();
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.itemCount,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: widget.itemBuilder,
            ),
          ),
        ),
        if (widget.itemCount > 1) ...[
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.itemCount, (i) {
              final active = i == _current;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: active ? 20.w : 7.w,
                height: 7.h,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primaryBrown
                      : AppColors.lightBrown.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}