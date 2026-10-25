import 'package:wilson_crepe/features/order/data/datasources/order_item_remote_data_source.dart';
import 'package:wilson_crepe/features/order/data/datasources/order_remote_data_source.dart';
import 'package:wilson_crepe/features/order/data/models/order_item_model.dart';
import 'package:wilson_crepe/features/order/data/models/order_model.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_entity.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_item_entity.dart';
import 'package:wilson_crepe/features/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final OrderItemRemoteDataSource itemRemoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource, this.itemRemoteDataSource);

  @override
  Future<OrderEntity> createOrder(
    OrderEntity order,
    List<OrderItemEntity> items,
  ) async {
    final orderModel = OrderModel(
      id: order.id,
      userId: order.userId,
      totalPrice: order.totalPrice,
      status: order.status,
      customerName: order.customerName,
      phone: order.phone,
      address: order.address,
      notes: order.notes,
      createdAt: order.createdAt,
    );

    final createdOrder = await remoteDataSource.createOrder(orderModel);

    final orderId = createdOrder.id;

    if (orderId == null) {
      throw Exception('Failed to create order : Order ID is null');
    }

    final itemModels = items
        .map(
          (item) => OrderItemModel(
            id: item.id,
            orderId: orderId,
            productId: item.productId,
            productName: item.productName,
            productPrice: item.productPrice,
            quantity: item.quantity,
            itemTotal: item.itemTotal,
            discountPercentage: item.discountPercentage,
            createdAt: item.createdAt,
            crepeType: item.crepeType,
            priceModifier: item.priceModifier,
            extras: item.extras,
          ),
        )
        .toList();

    await itemRemoteDataSource.createOrderItems(itemModels);

    return createdOrder;
  }

  @override
  Future<List<OrderEntity>> getOrders(String userId) {
    return remoteDataSource.getOrders(userId);
  }

  @override
  Future<OrderEntity> getOrderById(int orderId) {
    return remoteDataSource.getOrderById(orderId);
  }

  @override
  Stream<OrderEntity> watchOrder(int orderId) {
    return remoteDataSource.watchOrder(orderId);
  }
}
