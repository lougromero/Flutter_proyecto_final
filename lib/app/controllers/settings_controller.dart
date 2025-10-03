import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

class SettingsController extends GetxController {
  final ThemeController _themeController = Get.find<ThemeController>();

  bool get isDarkMode => _themeController.isDarkMode;

  void toggleTheme(bool value) {
    _themeController.setDarkMode(value);
  }
}