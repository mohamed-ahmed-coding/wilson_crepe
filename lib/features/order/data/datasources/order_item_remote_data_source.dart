import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wilson_crepe/features/order/data/models/order_item_model.dart';

abstract class OrderItemRemoteDataSource {
  Future<List<OrderItemModel>> getOrderItems(int orderId);

  Future<List<OrderItemModel>> createOrderItems(List<OrderItemModel> items);

  Future<void> deleteOrderItems(int orderId);
}

class OrderItemRemoteDataSourceImpl implements OrderItemRemoteDataSource {
  final SupabaseClient supabase;

  OrderItemRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<OrderItemModel>> getOrderItems(int orderId) async {
    final response = await supabase
        .from('order_items')
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => OrderItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<OrderItemModel>> createOrderItems(
    List<OrderItemModel> items,
  ) async {
    final payload = items.map((item) {
      final json = item.toJson();
      return json;
    }).toList();

    final response = await supabase
        .from('order_items')
        .insert(payload)
        .select();

    return (response as List)
        .map((json) => OrderItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deleteOrderItems(int orderId) async {
    await supabase.from('order_items').delete().eq('order_id', orderId);
  }
}
