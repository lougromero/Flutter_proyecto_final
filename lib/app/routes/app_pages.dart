import 'package:get/get.dart';
import '../views/home_view.dart';
import '../views/shopping_list_view.dart';
import '../views/settings_view.dart';
import '../controllers/home_controller.dart';
import '../controllers/shopping_list_controller.dart';
import '../controllers/settings_controller.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.SHOPPING_LIST,
      page: () => ShoppingListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ShoppingListController>(() => ShoppingListController());
      }),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => SettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),
  ];
}