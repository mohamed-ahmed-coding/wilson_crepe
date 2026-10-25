import 'package:wilson_crepe/features/order/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    super.id,
    required super.userId,
    required super.totalPrice,
    super.status,
    super.customerName,
    super.phone,
    super.address,
    super.notes,
    super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      totalPrice: (json['total_price'] as num).toDouble(),
      status: _statusFromString(json['status'] as String?),
      customerName: json['customer_name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_price': totalPrice,
      'status': status.name,
      'customer_name': customerName,
      'phone': phone,
      'address': address,
      'notes': notes,
    };
  }

  static OrderStatus _statusFromString(String? value) {
    final normalized = (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_\-]'), '');

    switch (normalized) {
      case 'preparing':
        return OrderStatus.preparing;
      case 'outfordelivery':
        return OrderStatus.outForDelivery;
      case 'canceled':
      case 'cancelled':
        return OrderStatus.canceled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}