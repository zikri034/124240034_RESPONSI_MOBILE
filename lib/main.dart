import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/data/services/hive_cart_service.dart';
import 'app/data/services/session_service.dart';
import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/modules/auth/views/login_view.dart';
import 'app/modules/cart/controllers/cart_controller.dart';
import 'app/modules/cart/views/cart_view.dart';
import 'app/modules/detail/views/detail_view.dart';
import 'app/modules/main/views/main_view.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local database
  await HiveCartService.init();

  // Initialize Session Service
  final sessionService = await SessionService.init();

  // Put Global Controllers into GetX dependency graph
  Get.put<AuthController>(AuthController(sessionService), permanent: true);
  Get.put<CartController>(CartController(), permanent: true);

  // Check Session for Initial Route
  final String initialRoute =
      sessionService.isLoggedIn() ? AppRoutes.main : AppRoutes.login;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Toko Awikwok',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      getPages: [
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginView(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: AppRoutes.main,
          page: () => const MainView(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: AppRoutes.detail,
          page: () => const DetailView(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: AppRoutes.cart,
          page: () => const CartView(),
          transition: Transition.rightToLeft,
        ),
      ],
    );
  }
}
