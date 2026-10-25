import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_entity.dart';

extension OrderStatusUi on OrderStatus {
  int get stepIndex => switch (this) {
    OrderStatus.pending => 0,
    OrderStatus.preparing => 1,
    OrderStatus.outForDelivery => 2,
    OrderStatus.canceled => -1,
  };

  String get label => switch (this) {
    OrderStatus.pending => 'order_status.pending'.tr(),
    OrderStatus.preparing => 'order_status.preparing'.tr(),
    OrderStatus.outForDelivery => 'order_status.out_for_delivery'.tr(),
    OrderStatus.canceled => 'order_status.canceled'.tr(),
  };

  String get message => switch (this) {
    OrderStatus.pending => 'order_status.pending_message'.tr(),
    OrderStatus.preparing => 'order_status.preparing_message'.tr(),
    OrderStatus.outForDelivery => 'order_status.out_for_delivery_message'.tr(),
    OrderStatus.canceled => 'order_status.canceled_message'.tr(),
  };

  IconData get icon => switch (this) {
    OrderStatus.pending => Icons.receipt_long,
    OrderStatus.preparing => Icons.restaurant,
    OrderStatus.outForDelivery => Icons.delivery_dining,
    OrderStatus.canceled => Icons.cancel_outlined,
  };

  Color get color => this == OrderStatus.canceled
      ? Colors.red.shade700
      : AppColors.primaryBrown;
}
