import 'package:go_router/go_router.dart';
import 'package:wilson_crepe/features/auth/presentation/pages/login_screen.dart';
import 'package:wilson_crepe/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:wilson_crepe/features/auth/presentation/widgets/auth_gate.dart';
import 'package:wilson_crepe/features/home/domain/entities/product_entity.dart';
import 'package:wilson_crepe/features/home/presentation/pages/cart_screen.dart';
import 'package:wilson_crepe/features/home/presentation/pages/favorites_screen.dart';
import 'package:wilson_crepe/features/home/presentation/pages/main_shell_screen.dart';
import 'package:wilson_crepe/features/home/presentation/pages/orders_history_screen.dart';
import 'package:wilson_crepe/features/home/presentation/pages/product_details_screen.dart';
import 'package:wilson_crepe/features/home/presentation/pages/profile_screen.dart';
import 'package:wilson_crepe/features/home/presentation/pages/search_screen.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_entity.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_item_entity.dart';
import 'package:wilson_crepe/features/order/presentation/pages/order_confirmed_screen.dart';
import 'package:wilson_crepe/features/order/presentation/pages/order_screen.dart';
import 'package:wilson_crepe/features/order/presentation/pages/tracking_order_screen.dart';
import 'package:wilson_crepe/features/splash/presentation/pages/splash_screen.dart';

class AppRoutes {
  static const String splashScreen = '/splashScreen';
  static const String authGate = '/authGate';
  static const String loginScreen = '/loginScreen';
  static const String signUpScreen = '/signUpScreen';
  static const String mainShell = '/mainShellScreen';
  static const String homeScreen = '/homeScreen';
  static const String profileScreen = '/profileScreen';
  static const String favoritesScreen = '/favoritesScreen';
  static const String productDetails = '/productDetailsScreen';
  static const String searchScreen = '/searchScreen';
  static const String cartScreen = '/cartScreen';
  static const String orderScreen = '/orderScreen';
  static const String orderConfirmedScreen = '/orderConfirmedScreen';
  static const String ordersHistoryScreen = '/ordersHistoryScreen';
  static const String trackingOrderScreen = '/trackingOrderScreen';

  static final GoRouter router = GoRouter(
    initialLocation: splashScreen,
    routes: [
      GoRoute(
        path: AppRoutes.splashScreen,
        name: AppRoutes.splashScreen,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.authGate,
        name: AppRoutes.authGate,
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: AppRoutes.loginScreen,
        name: AppRoutes.loginScreen,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUpScreen,
        name: AppRoutes.signUpScreen,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.mainShell,
        name: AppRoutes.mainShell,
        builder: (context, state) => const MainShellScreen(),
      ),
      GoRoute(
        path: AppRoutes.homeScreen,
        name: AppRoutes.homeScreen,
        builder: (context, state) => const MainShellScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileScreen,
        name: AppRoutes.profileScreen,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.favoritesScreen,
        name: AppRoutes.favoritesScreen,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AppRoutes.cartScreen,
        name: AppRoutes.cartScreen,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderScreen,
        name: AppRoutes.orderScreen,
        builder: (context, state) => const OrderScreen(),
      ),
      GoRoute(
        path: AppRoutes.ordersHistoryScreen,
        name: AppRoutes.ordersHistoryScreen,
        builder: (context, state) => const OrdersHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderConfirmedScreen,
        name: AppRoutes.orderConfirmedScreen,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return OrderConfirmedScreen(
            order: data['order'] as OrderEntity,
            items: data['items'] as List<OrderItemEntity>,
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.trackingOrderScreen}/:id',
        name: AppRoutes.trackingOrderScreen,
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['id']!);
          return TrackingOrderScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: AppRoutes.searchScreen,
        name: AppRoutes.searchScreen,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        name: AppRoutes.productDetails,
        builder: (context, state) {
          final product = state.extra as ProductEntity;
          return ProductDetailsScreen(product: product);
        },
      ),
    ],
  );
}
