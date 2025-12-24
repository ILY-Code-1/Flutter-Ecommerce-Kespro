import 'package:get/get.dart';
import '../modules/landing/landing_binding.dart';
import '../modules/landing/landing_page.dart';
import '../modules/order/order_binding.dart';
import '../modules/order/order_page.dart';
import '../modules/success/success_page.dart';
import '../modules/admin/login/admin_login_binding.dart';
import '../modules/admin/login/admin_login_page.dart';
import '../modules/admin/dashboard/admin_dashboard_binding.dart';
import '../modules/admin/dashboard/admin_dashboard_page.dart';
import '../modules/admin/catalog/catalog_binding.dart';
import '../modules/admin/catalog/views/catalog_list_page.dart';
import '../modules/admin/catalog/views/catalog_detail_page.dart';
import '../modules/admin/catalog/views/catalog_add_page.dart';
import '../modules/admin/request_order/request_order_binding.dart';
import '../modules/admin/request_order/views/request_order_list_page.dart';
import '../modules/admin/request_order/views/request_order_detail_page.dart';
import '../modules/admin/invoice_ui/invoice_ui_binding.dart';
import '../modules/admin/invoice_ui/views/invoice_list_page.dart';
import '../modules/admin/invoice_ui/views/invoice_detail_page.dart';
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
    GetPage(
      name: AppRoutes.adminLogin,
      page: () => const AdminLoginPage(),
      binding: AdminLoginBinding(),
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardPage(),
      binding: AdminDashboardBinding(),
    ),
    // Catalog routes
    GetPage(
      name: AppRoutes.catalog,
      page: () => const CatalogListPage(),
      binding: CatalogBinding(),
    ),
    GetPage(
      name: AppRoutes.catalogDetail,
      page: () => const CatalogDetailPage(),
      binding: CatalogBinding(),
    ),
    GetPage(
      name: AppRoutes.catalogAdd,
      page: () => const CatalogAddPage(),
      binding: CatalogBinding(),
    ),
    // Request Order routes
    GetPage(
      name: AppRoutes.requestOrder,
      page: () => const RequestOrderListPage(),
      binding: RequestOrderBinding(),
    ),
    GetPage(
      name: AppRoutes.requestOrderDetail,
      page: () => const RequestOrderDetailPage(),
      binding: RequestOrderBinding(),
    ),
    // Invoice routes
    GetPage(
      name: AppRoutes.invoice,
      page: () => const InvoiceListPage(),
      binding: InvoiceUIBinding(),
    ),
    GetPage(
      name: AppRoutes.invoiceDetail,
      page: () => const InvoiceDetailPage(),
      binding: InvoiceUIBinding(),
    ),
  ];
}
