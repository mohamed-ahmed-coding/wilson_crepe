import 'package:wilson_crepe/features/order/domain/entities/order_entity.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_item_entity.dart';
import 'package:wilson_crepe/features/order/domain/repositories/order_repository.dart';

class CreateOrder {
  final OrderRepository repository;

  CreateOrder(this.repository);

  Future<OrderEntity> call(OrderEntity order, List<OrderItemEntity> items) {
    return repository.createOrder(order, items);
  }
}

class GetOrders {
  final OrderRepository repository;

  GetOrders(this.repository);

  Future<List<OrderEntity>> call(String userId) {
    return repository.getOrders(userId);
  }
}

class GetOrderById {
  final OrderRepository repository;

  GetOrderById(this.repository);

  Future<OrderEntity> call(int orderId) {
    return repository.getOrderById(orderId);
  }
}

class WatchOrder {
  final OrderRepository repository;

  WatchOrder(this.repository);

  Stream<OrderEntity> call(int orderId) {
    return repository.watchOrder(orderId);
  }
}
