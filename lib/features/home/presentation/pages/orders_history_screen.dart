import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/routes/app_routes.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/error_view.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_entity.dart';
import 'package:wilson_crepe/features/order/presentation/cubit/order_cubit.dart';
import 'package:wilson_crepe/features/order/presentation/cubit/order_state.dart';

class _StatusStyle {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusStyle(this.label, this.color, this.icon);
}

_StatusStyle _styleOf(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return _StatusStyle(
        'order_status.pending'.tr(),
        AppColors.orange,
        Icons.hourglass_top_rounded,
      );
    case OrderStatus.preparing:
      return _StatusStyle(
        'order_status.preparing'.tr(),
        AppColors.blue,
        Icons.soup_kitchen_rounded,
      );
    case OrderStatus.outForDelivery:
      return _StatusStyle(
        'order_status.out_for_delivery'.tr(),
        AppColors.green,
        Icons.delivery_dining_rounded,
      );
    case OrderStatus.canceled:
      return _StatusStyle(
        'order_status.canceled'.tr(),
        AppColors.error,
        Icons.cancel_rounded,
      );
  }
}

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadOrders();
    });
  }

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  Future<void> _loadOrders() async {
    final id = _userId;
    if (id == null) return;
    await context.read<OrderCubit>().getOrders(id);
  }

  Future<void> _openTracking(OrderEntity order) async {
    if (order.id == null) return;

    await context.pushNamed(
      AppRoutes.trackingOrderScreen,
      pathParameters: {'id': order.id.toString()},
    );

    if (mounted) _loadOrders();
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
              context.pop();
            } else {
              context.goNamed(AppRoutes.homeScreen);
            }
          },
        ),
        title: Text(
          'orders_history.title'.tr(),
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
        child: SafeArea(
          child: BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              if (state is OrderLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBrown,
                  ),
                );
              }
              if (state is OrderError) {
                return ErrorView(
                  message: state.message.tr(),
                  onRetry: _loadOrders,
                );
              }
              if (state is OrdersLoaded) {
                final orders = state.orders;
                return RefreshIndicator(
                  color: AppColors.primaryBrown,
                  onRefresh: _loadOrders,
                  child: orders.isEmpty
                      ? LayoutBuilder(
                          builder: (context, constraints) =>
                              SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: constraints.maxHeight,
                                  child: const _EmptyOrdersView(),
                                ),
                              ),
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(16.w),
                          itemCount: orders.length,
                          separatorBuilder: (_, _) => SizedBox(height: 14.h),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return _OrderCard(
                              order: order,
                              onTap: () => _openTracking(order),
                            );
                          },
                        ),
                );
              }
              return const _EmptyOrdersView();
            },
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  String _formatDate(DateTime date, BuildContext context) {
    final locale = context.locale.toString();

    return DateFormat('dd MMM yyyy • hh:mm a', locale).format(date.toLocal());
  }

  String _formatPrice(num price) {
    final amount = price.toStringAsFixed(2);

    return 'orders_history.currency_amount'.tr(namedArgs: {'amount': amount});
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleOf(order.status);
    final color = style.color;

    return Material(
      color: AppColors.white,
      elevation: 3,
      shadowColor: color.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(18.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(color: color, width: 6.w),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 8.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: color.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        size: 22.sp,
                        color: color,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'orders_history.order_number'.tr(
                              namedArgs: {'id': order.id?.toString() ?? '-'},
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                          if (order.createdAt != null) ...[
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 13.sp,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    _formatDate(order.createdAt!, context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: Row(
                    children: [
                      _StatusChip(style: style),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _formatPrice(order.totalPrice),
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'orders_history.track_order'.tr(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final _StatusStyle style;

  const _StatusChip({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: style.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14.sp, color: style.color),
          SizedBox(width: 5.w),
          Text(
            style.label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: style.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrdersView extends StatelessWidget {
  const _EmptyOrdersView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBrown.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 64.sp,
                color: AppColors.primaryBrown,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'orders_history.empty_title'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBrown,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'orders_history.empty_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
