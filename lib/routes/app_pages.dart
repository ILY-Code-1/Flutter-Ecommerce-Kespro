import 'package:get/get.dart';
import '../modules/landing/landing_binding.dart';
import '../modules/landing/landing_page.dart';
import '../modules/order/order_binding.dart';
import '../modules/order/order_page.dart';
import '../modules/success/success_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.landing,
      page: () => const LandingPage(),
      binding: LandingBinding(),
    ),
    GetPage(
      name: AppRoutes.order,
      page: () => const OrderPage(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.success,
      page: () => const SuccessPage(),
    ),
  ];
}
