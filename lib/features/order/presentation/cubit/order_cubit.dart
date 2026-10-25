import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_entity.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_item_entity.dart';
import 'package:wilson_crepe/features/order/domain/repositories/order_repository.dart';
import 'package:wilson_crepe/features/order/domain/usecases/oreder_item_use_case.dart';
import 'package:wilson_crepe/features/order/domain/usecases/order_use_case.dart';
import 'package:wilson_crepe/features/order/presentation/cubit/order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository repository;
  final CreateOrder createOrderUseCase;
  final GetOrders getOrdersUseCase;
  final GetOrderById getOrderByIdUseCase;
  final GetOrderItems getOrderItemsUseCase;
  StreamSubscription<OrderEntity>? _orderSubscription;
  List<OrderItemEntity> _items = const [];
  int? _itemsOrderId;

  OrderCubit(
    this.repository, {
    required this.createOrderUseCase,
    required this.getOrdersUseCase,
    required this.getOrderByIdUseCase,
    required this.getOrderItemsUseCase,
  }) : super(OrderInitial());

  Future<void> createOrder(
    OrderEntity order,
    List<OrderItemEntity> items,
  ) async {
    if (isClosed) return;
    emit(OrderCreating());

    try {
      final createdOrder = await createOrderUseCase(order, items);

      if (isClosed) return;

      emit(OrderCreated(createdOrder));
    } catch (e) {
      if (isClosed) return;
      emit(OrderError(_errorMessage(e)));
    }
  }

  Future<void> getOrders(String userId) async {
    if (isClosed) return;
    emit(OrderLoading());

    try {
      final orders = await repository.getOrders(userId);

      if (isClosed) return;

      emit(OrdersLoaded(orders));
    } catch (e) {
      if (isClosed) return;
      emit(OrderError(_errorMessage(e)));
    }
  }

  Future<void> getOrderById(int orderId) async {
    if (isClosed) return;
    emit(OrderLoading());

    try {
      final order = await repository.getOrderById(orderId);
      final items = await _fetchItems(orderId);

      if (isClosed) return;

      emit(OrderDetailsLoaded(order, items: items));
    } catch (e) {
      if (isClosed) return;
      emit(OrderError(_errorMessage(e)));
    }
  }

  Future<void> watchOrder(int orderId) async {
    await _orderSubscription?.cancel();

    if (_itemsOrderId != orderId) {
      _items = const [];
      _itemsOrderId = orderId;
    }

    if (state is! OrderDetailsLoaded && !isClosed) emit(OrderLoading());

    _orderSubscription = repository
        .watchOrder(orderId)
        .listen(
          (order) {
            if (isClosed) return;
            emit(OrderDetailsLoaded(order, items: _items));
          },
          onError: (error) {
            if (isClosed) return;
            emit(OrderError(_errorMessage(error)));
          },
        );

    try {
      final items = await _fetchItems(orderId);
      if (isClosed || _itemsOrderId != orderId) return;

      _items = items;

      final current = state;
      if (current is OrderDetailsLoaded) {
        emit(OrderDetailsLoaded(current.order, items: _items));
      }
    } catch (e) {
      if (isClosed || _itemsOrderId != orderId) return;

      emit(OrderError(_errorMessage(e)));
    }
  }

  Future<List<OrderItemEntity>> _fetchItems(int orderId) =>
      getOrderItemsUseCase(orderId);

  @override
  Future<void> close() async {
    await _orderSubscription?.cancel();
    return super.close();
  }

  String _errorMessage(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('handshakeexception') ||
        message.contains('certificate_verify_failed') ||
        message.contains('unable to get local issuer certificate') ||
        message.contains('socketexception') ||
        message.contains('network') ||
        message.contains('connection') ||
        message.contains('failed host lookup') ||
        message.contains('timed out') ||
        message.contains('timeout')) {
      return 'error.network';
    }

    return 'error.something_went_wrong';
  }
}
