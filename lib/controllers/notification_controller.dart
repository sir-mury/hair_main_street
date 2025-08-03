import 'package:get/get.dart';
import 'package:hair_main_street/models/notifications_model.dart';
import 'package:hair_main_street/pages/homepage.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/services/notification.dart';

class NotificationController extends GetxController {
  var notifications = <Notifications>[].obs;
  RxBool isLoading = false.obs;

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
  // }'

  //delete Token
  deleteToken() async {
    await NotificationService().deleteToken();
  }

  unsubscribeFromTopics(List<String> topics) {
    NotificationService().unsubscribeFromTopics(topics);
  }

  subscribeToTopics(String userType, String userID) {
    NotificationService().subscribeToTopics(userType, userID);
  }

  getNotifications() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoading.value = true;
    Stream stream = DataBaseService().getNotifications();
    stream.listen((data) {
      notifications.value = data;
      // prefs.setInt("notificationCount", value)
      isLoading.value = false;
      // debugPrint("isLoading: ${isLoading.value}");
    });
  }
}

class BottomNavController extends GetxController {
  var tabIndex = 0.obs;
  RxBool isConnected = false.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}
