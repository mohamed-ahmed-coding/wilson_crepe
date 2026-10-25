import 'package:equatable/equatable.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_entity.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_item_entity.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderCreating extends OrderState {}

class OrderCreated extends OrderState {
  final OrderEntity order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderDetailsLoaded extends OrderState {
  final OrderEntity order;
  final List<OrderItemEntity> items;

  const OrderDetailsLoaded(this.order, {this.items = const []});

  @override
  List<Object?> get props => [order, items];
}

class OrderCancelled extends OrderState {}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}
