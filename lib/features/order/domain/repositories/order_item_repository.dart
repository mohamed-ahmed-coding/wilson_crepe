import 'package:wilson_crepe/features/order/domain/entities/order_item_entity.dart';

abstract class OrderItemRepository {
  Future<List<OrderItemEntity>> getOrderItems(int orderId);

  Future<List<OrderItemEntity>> createOrderItems(
    List<OrderItemEntity> items,
  );

  Future<void> deleteOrderItems(int orderId);
}