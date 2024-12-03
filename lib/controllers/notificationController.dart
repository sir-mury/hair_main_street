import 'package:get/get.dart';
import 'package:hair_main_street/models/notificationsModel.dart';
import 'package:hair_main_street/pages/homePage.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/services/notification.dart';

class NotificationController extends GetxController {
  var notifications = <Notifications>[].obs;

  void navigateToNotifications() {
    Get.offAll(() => const HomePage());
    Get.find<BottomNavController>().changeTabIndex(1);
  }

  void navigateBacktoHome() {
    Get.offAll(() => const HomePage());
    Get.find<BottomNavController>().changeTabIndex(0);
  }

  // @override
  // void onInit() {
  //   NotificationService().init();
  //   super.onInit();
  // }

  subscribeToTopics(String userType, String userID) {
    NotificationService().subscribeToTopics(userType, userID);
  }

  getNotifications() {
    notifications.bindStream(DataBaseService().getNotifications());
  }
}

class BottomNavController extends GetxController {
  var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}
