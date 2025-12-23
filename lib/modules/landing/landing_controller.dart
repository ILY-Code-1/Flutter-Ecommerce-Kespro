import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LandingController extends GetxController {
  final ScrollController scrollController = ScrollController();
  
  final heroKey = GlobalKey();
  final kategoriKey = GlobalKey();
  final caraSewaKey = GlobalKey();
  final tentangKey = GlobalKey();

  void scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
