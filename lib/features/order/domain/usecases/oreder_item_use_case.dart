import 'package:wilson_crepe/features/order/domain/entities/order_item_entity.dart';
import 'package:wilson_crepe/features/order/domain/repositories/order_item_repository.dart';

class GetOrderItems {
  final OrderItemRepository repository;

  GetOrderItems(this.repository);

  Future<List<OrderItemEntity>> call(int orderId) {
    return repository.getOrderItems(orderId);
  }
}

class CreateOrderItems {
  final OrderItemRepository repository;

  CreateOrderItems(this.repository);

  Future<List<OrderItemEntity>> call(List<OrderItemEntity> items) {
    return repository.createOrderItems(items);
  }
}

class DeleteOrderItems {
  final OrderItemRepository repository;

  DeleteOrderItems(this.repository);

  Future<void> call(int orderId) {
    return repository.deleteOrderItems(orderId);
  }
}
