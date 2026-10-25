import 'package:wilson_crepe/features/order/domain/entities/order_entity.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_item_entity.dart';

abstract class OrderRepository {
  Future<OrderEntity> createOrder(OrderEntity order, List<OrderItemEntity> items);

  Future<List<OrderEntity>> getOrders(String userId);

  Future<OrderEntity> getOrderById(int orderId);

  Stream<OrderEntity> watchOrder(int orderId);
}