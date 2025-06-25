import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/models/admin_variable_model.dart';
import 'package:hair_main_street/services/database.dart';

class AdminController extends GetxController {
  Rx<AdminVariables?> adminSettings = Rx<AdminVariables?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getAdminVariables();
  }

  getAdminVariables() {
    isLoading.value = true;
    Stream stream = DataBaseService().getAdminVariables();
    stream.listen((onData) {
      if (onData != null) {
        adminSettings.value = onData;
        isLoading.value = false;
      } else {
        isLoading.value = false;
        debugPrint("No admin variables found");
      }
    }, onError: (error) {
      isLoading.value = false;
      debugPrint("Error fetching admin variables: $error");
    });
  }
}
