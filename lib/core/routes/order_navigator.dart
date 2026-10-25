import 'package:wilson_crepe/core/routes/app_routes.dart';

class OrderNavigator {
  OrderNavigator._();

  static int? _pendingOrderId;

  static void openOrder(int orderId) {
    final path = AppRoutes.router.routerDelegate.currentConfiguration.uri.path;

    final appStillStarting = path == AppRoutes.authGate;

    if (appStillStarting) {
      _pendingOrderId = orderId;
      return;
    }

    _goToTracking(orderId);
  }

  static void consumePendingOrder() {
    final id = _pendingOrderId;
    if (id == null) return;

    _pendingOrderId = null;
    _goToTracking(id);
  }

  static void _goToTracking(int orderId) {
    AppRoutes.router.pushNamed(
      AppRoutes.trackingOrderScreen,
      pathParameters: {'id': orderId.toString()},
    );
  }
}