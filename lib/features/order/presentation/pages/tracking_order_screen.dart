import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/routes/app_routes.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_entity.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_item_entity.dart';
import 'package:wilson_crepe/features/order/presentation/cubit/order_cubit.dart';
import 'package:wilson_crepe/features/order/presentation/cubit/order_state.dart';
import 'package:wilson_crepe/features/order/presentation/widgets/order_info_card.dart';
import 'package:wilson_crepe/features/order/presentation/widgets/order_items_card.dart';
import 'package:wilson_crepe/features/order/presentation/widgets/order_status_time_line.dart';
import 'package:wilson_crepe/features/order/presentation/widgets/order_status_ui.dart';
import 'package:wilson_crepe/injection_container.dart';

class TrackingOrderScreen extends StatelessWidget {
  final int orderId;

  const TrackingOrderScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrderCubit>()..watchOrder(orderId),
      child: _TrackingView(orderId: orderId),
    );
  }
}

class _TrackingView extends StatefulWidget {
  final int orderId;

  const _TrackingView({required this.orderId});

  @override
  State<_TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends State<_TrackingView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<OrderCubit>().watchOrder(widget.orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBrown),
          onPressed: () {
            if (context.canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).goNamed(AppRoutes.homeScreen);
            }
          },
        ),
        title: Text(
          'tracking_order.title'.tr(
            namedArgs: {'id': widget.orderId.toString()},
          ),
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.lightBrown.withValues(alpha: 0.1),
        foregroundColor: AppColors.primaryBrown,
        shape: Border.symmetric(
          horizontal: BorderSide(color: AppColors.primaryBrown, width: 2.w),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Wilson_bg_white.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            if (state is OrderDetailsLoaded) {
              return RefreshIndicator(
                color: AppColors.primaryBrown,
                onRefresh: () async {
                  await context.read<OrderCubit>().watchOrder(widget.orderId);
                },
                child: _OrderContent(order: state.order, items: state.items),
              );
            }

            if (state is OrderError) {
              return _ErrorView(
                message: state.message,
                onRetry: () {
                  context.read<OrderCubit>().watchOrder(widget.orderId);
                },
              );
            }

            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBrown),
            );
          },
        ),
      ),
    );
  }
}

class _OrderContent extends StatelessWidget {
  final OrderEntity order;
  final List<OrderItemEntity> items;

  const _OrderContent({required this.order, required this.items});

  @override
  Widget build(BuildContext context) {
    final canceled = order.status == OrderStatus.canceled;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      children: [
        _StatusHeader(status: order.status),
        SizedBox(height: 16.h),
        if (!canceled) ...[
          OrderStatusTimeline(currentStep: order.status.stepIndex),
          SizedBox(height: 16.h),
        ],
        if (items.isNotEmpty) ...[
          OrderItemsCard(items: items),
          SizedBox(height: 16.h),
        ],
        OrderInfoCard(order: order),
      ],
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final OrderStatus status;

  const _StatusHeader({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(status.icon, color: Colors.white, size: 40.sp),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localizedStatusLabel(status),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _localizedStatusMessage(status),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _localizedStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'order_status.pending'.tr();
      case OrderStatus.preparing:
        return 'order_status.preparing'.tr();
      case OrderStatus.outForDelivery:
        return 'order_status.out_for_delivery'.tr();
      case OrderStatus.canceled:
        return 'order_status.canceled'.tr();
    }
  }

  String _localizedStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'order_status.pending_message'.tr();
      case OrderStatus.preparing:
        return 'order_status.preparing_message'.tr();
      case OrderStatus.outForDelivery:
        return 'order_status.out_for_delivery_message'.tr();
      case OrderStatus.canceled:
        return 'order_status.canceled_message'.tr();
    }
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56.sp, color: Colors.red.shade700),
            SizedBox(height: 12.h),
            Text(
              'tracking_order.error_title'.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBrown,
              ),
            ),
            SizedBox(height: 6.h),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrown,
                foregroundColor: Colors.white,
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text('tracking_order.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
