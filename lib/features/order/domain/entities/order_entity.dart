import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  preparing,
  outForDelivery,
  canceled,
}

class OrderEntity extends Equatable {
  final int? id;
  final String userId;
  final double totalPrice;
  final OrderStatus status;
  final String? customerName;
  final String? phone;
  final String? address;
  final String? notes;
  final DateTime? createdAt;

  const OrderEntity({
    this.id,
    required this.userId,
    required this.totalPrice,
    this.status = OrderStatus.pending,
    this.customerName,
    this.phone,
    this.address,
    this.notes,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        totalPrice,
        status,
        customerName,
        phone,
        address,
        notes,
        createdAt,
      ];
}
