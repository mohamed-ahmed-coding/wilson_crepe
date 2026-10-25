import 'package:wilson_crepe/features/order/data/datasources/order_item_remote_data_source.dart';
import 'package:wilson_crepe/features/order/data/models/order_item_model.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_item_entity.dart';
import 'package:wilson_crepe/features/order/domain/repositories/order_item_repository.dart';

class OrderItemRepositoryImpl implements OrderItemRepository {
  final OrderItemRemoteDataSource remoteDataSource;

  OrderItemRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<OrderItemEntity>> getOrderItems(int orderId) {
    return remoteDataSource.getOrderItems(orderId);
  }

  @override
  Future<List<OrderItemEntity>> createOrderItems(
    List<OrderItemEntity> items,
  ) {
    final models = items
        .map(
          (item) => OrderItemModel(
            id: item.id,
            orderId: item.orderId,
            productId: item.productId,
            productName: item.productName,
            productPrice: item.productPrice,
            quantity: item.quantity,
            itemTotal: item.itemTotal,
            createdAt: item.createdAt,
            discountPercentage: item.discountPercentage,
            crepeType: item.crepeType,
            priceModifier: item.priceModifier,
            extras: item.extras,
          ),
        )
        .toList();

    return remoteDataSource.createOrderItems(models);
  }

  @override
  Future<void> deleteOrderItems(int orderId) {
    return remoteDataSource.deleteOrderItems(orderId);
  }
}