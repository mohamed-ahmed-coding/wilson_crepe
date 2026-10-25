import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wilson_crepe/core/monitoring/crashlytics_service.dart';
import 'package:wilson_crepe/features/order/data/models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder(OrderModel order);

  Future<List<OrderModel>> getOrders(String userId);

  Future<OrderModel> getOrderById(int orderId);

  Stream<OrderModel> watchOrder(int orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final SupabaseClient supabase;

  OrderRemoteDataSourceImpl(this.supabase);

  Future<T> _monitor<T>(String operation, Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      await CrashlyticsService.instance.recordError(
        error,
        stackTrace,
        reason: operation,
      );
      rethrow;
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    return _monitor('Create order', () async {
      final businessDayId = await supabase.rpc('get_current_business_day_id');

      final response = await supabase
          .from('orders')
          .insert({
            'user_id': order.userId,
            'total_price': order.totalPrice,
            'status': order.status.name,
            'customer_name': order.customerName,
            'phone': order.phone,
            'address': order.address,
            'notes': order.notes,
            'business_day_id': businessDayId,
          })
          .select()
          .single();

      return OrderModel.fromJson(response);
    });
  }

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    return _monitor('Get orders', () async {
      final response = await supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<OrderModel> getOrderById(int orderId) async {
    return _monitor('Get order by id', () async {
      final response = await supabase
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();

      return OrderModel.fromJson(response);
    });
  }

  @override
  Stream<OrderModel> watchOrder(int orderId) {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((data) {
          if (data.isEmpty) {
            throw Exception('Order not found.');
          }

          return OrderModel.fromJson(Map<String, dynamic>.from(data.first));
        })
        .handleError((Object error, StackTrace stackTrace) {
          CrashlyticsService.instance.recordError(
            error,
            stackTrace,
            reason: 'Watch order stream failed',
          );
        });
  }
}
