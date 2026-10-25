import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wilson_crepe/core/notifications/notifications_service.dart';
import 'package:wilson_crepe/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wilson_crepe/features/auth/data/repositories/auth_repository.dart';
import 'package:wilson_crepe/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:wilson_crepe/features/auth/domain/usecases/auth_use_case.dart';
import 'package:wilson_crepe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wilson_crepe/features/home/data/datasources/favorite_remote_data_source.dart';
import 'package:wilson_crepe/features/home/data/datasources/favorite_remote_data_source_impl.dart';
import 'package:wilson_crepe/features/home/data/datasources/home_remote_data_source_impl.dart';
import 'package:wilson_crepe/features/home/data/datasources/home_remote_data_source.dart';
import 'package:wilson_crepe/features/home/data/repositories/home_repository_impl.dart';
import 'package:wilson_crepe/features/home/data/repositories/favorite_repository_impl.dart';
import 'package:wilson_crepe/features/home/domain/repositories/home_repository.dart';
import 'package:wilson_crepe/features/home/domain/repositories/favorite_repository.dart';
import 'package:wilson_crepe/features/home/domain/usecases/get_home_menu.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/home/home_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_cubit.dart';
import 'package:wilson_crepe/features/order/data/datasources/order_item_remote_data_source.dart';
import 'package:wilson_crepe/features/order/data/datasources/order_remote_data_source.dart';
import 'package:wilson_crepe/features/order/data/repositories/order_item_repository_impl.dart';
import 'package:wilson_crepe/features/order/data/repositories/order_repository_impl.dart';
import 'package:wilson_crepe/features/order/domain/repositories/order_item_repository.dart';
import 'package:wilson_crepe/features/order/domain/repositories/order_repository.dart';
import 'package:wilson_crepe/features/order/domain/usecases/order_use_case.dart';
import 'package:wilson_crepe/features/order/domain/usecases/oreder_item_use_case.dart';
import 'package:wilson_crepe/features/order/presentation/cubit/order_cubit.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // Supabase
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Notifications
  sl.registerLazySingleton<NotificationsService>(
    () => NotificationsService(sl<SupabaseClient>()),
  );

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton<SignIn>(() => SignIn(sl()));

  sl.registerLazySingleton<SignUp>(() => SignUp(sl()));

  sl.registerLazySingleton<SignInWithGoogle>(() => SignInWithGoogle(sl()));

  sl.registerLazySingleton<SignOut>(() => SignOut(sl()));

  sl.registerLazySingleton<DeleteAccountUseCase>(() => DeleteAccountUseCase(sl()));

  sl.registerLazySingleton<GetCurrentUser>(() => GetCurrentUser(sl()));

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      signIn: sl<SignIn>(),
      signUp: sl<SignUp>(),
      signInWithGoogle: sl<SignInWithGoogle>(),
      signOut: sl<SignOut>(),
      getCurrentUser: sl<GetCurrentUser>(),
      deleteAccountUseCase: sl<DeleteAccountUseCase>(),
      notificationsService: sl<NotificationsService>(),
    ),
  );

  // Home
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(supabase: sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl<HomeRemoteDataSource>()),
  );

  // Favorites
  sl.registerLazySingleton<FavoriteRemoteDataSource>(
    () => FavoriteRemoteDataSourceImpl(supabase: sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(
      remoteDataSource: sl<FavoriteRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetHomeMenu>(() => GetHomeMenu(sl()));

  sl.registerFactory<HomeCubit>(
    () => HomeCubit(
      homeRepository: sl<HomeRepository>(),
      favoritesRepository: sl<FavoriteRepository>(),
    ),
  );

  // Cart
  sl.registerFactory<CartCubit>(() => CartCubit());

  // Orders
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<OrderItemRemoteDataSource>(
    () => OrderItemRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      sl<OrderRemoteDataSource>(),
      sl<OrderItemRemoteDataSource>(),
    ),
  );

  // NEW: order items repository (needed by GetOrderItems)
  sl.registerLazySingleton<OrderItemRepository>(
    () => OrderItemRepositoryImpl(sl<OrderItemRemoteDataSource>()),
  );

  // Order UseCases
  sl.registerLazySingleton<CreateOrder>(
    () => CreateOrder(sl<OrderRepository>()),
  );

  sl.registerLazySingleton<GetOrders>(() => GetOrders(sl<OrderRepository>()));

  sl.registerLazySingleton<GetOrderById>(
    () => GetOrderById(sl<OrderRepository>()),
  );

  // NEW: this was missing -> GetIt would throw when creating OrderCubit
  sl.registerLazySingleton<GetOrderItems>(
    () => GetOrderItems(sl<OrderItemRepository>()),
  );

  // Order Cubit
  sl.registerFactory<OrderCubit>(
    () => OrderCubit(
      sl<OrderRepository>(),
      createOrderUseCase: sl<CreateOrder>(),
      getOrdersUseCase: sl<GetOrders>(),
      getOrderByIdUseCase: sl<GetOrderById>(),
      getOrderItemsUseCase: sl<GetOrderItems>(),
    ),
  );
}
