import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/monitoring/crashlytics_service.dart';
import 'package:wilson_crepe/core/notifications/notifications_service.dart';
import 'package:wilson_crepe/core/routes/app_routes.dart';
import 'package:wilson_crepe/core/routes/order_navigator.dart';
import 'package:wilson_crepe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/home/home_cubit.dart';
import 'package:wilson_crepe/features/order/presentation/cubit/order_cubit.dart';
import 'package:wilson_crepe/firebase_options.dart';
import 'package:wilson_crepe/injection_container.dart';

late final NotificationsService notificationsService;


Future<void> initializeErrorMonitoring() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    }

    CrashlyticsService.instance.recordError(
      details.exception,
      details.stack ?? StackTrace.current,
      reason: 'Uncaught Flutter framework error',
      fatal: true,
    );
  };

  PlatformDispatcher.instance.onError = (
    Object error,
    StackTrace stackTrace,
  ) {
    CrashlyticsService.instance.recordError(
      error,
      stackTrace,
      reason: 'Uncaught asynchronous error',
      fatal: true,
    );

    return true;
  };
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeErrorMonitoring();

  await Supabase.initialize(
    url: 'https://meaougigscgbjatdggal.supabase.co',
    publishableKey: 'sb_publishable_DTSn-EAoz0Nw8vtPz-jwvg_XagB30Wn',
  );

  setupDependencies();

  notificationsService = NotificationsService(
    Supabase.instance.client,
  )..onOrderTap = OrderNavigator.openOrder;

  if (Supabase.instance.client.auth.currentSession != null) {
    await notificationsService.initialize();
  }

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.signedIn &&
        data.session != null) {
      notificationsService.initialize();
    }
  });

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      path: 'assets/langs',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      saveLocale: true,
      child: const WilsonCrepeApp(),
    ),
  );
}

class WilsonCrepeApp extends StatelessWidget {
  const WilsonCrepeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()),
        BlocProvider(create: (_) => sl<HomeCubit>()..getHomeData()),
        BlocProvider(create: (_) => sl<CartCubit>()),
        BlocProvider(create: (_) => sl<OrderCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        child: MaterialApp.router(
          theme: ThemeData(
            primaryColor: AppColors.primaryBrown,
            scaffoldBackgroundColor: AppColors.white,
            canvasColor: AppColors.white,
            fontFamily: GoogleFonts.outfit().fontFamily,
          ),
          debugShowCheckedModeBanner: false,
          title: 'Wilson Crepe',
          routerConfig: AppRoutes.router,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
        ),
      ),
    );
  }
}
