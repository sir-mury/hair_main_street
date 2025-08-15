import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/admin_controller.dart';
import 'package:hair_main_street/models/admin_variable_model.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatesServiceController extends GetxController {
  AdminController adminController = Get.find<AdminController>();
  RxBool isLoading = false.obs;
  RxBool isUpdateAvailable = false.obs;
  RxBool isUpdateMandatory = false.obs;
  RxString latestVersion = ''.obs;
  RxString currentVersion = ''.obs;
  RxString updateMessage = ''.obs;
  RxString updateUrl = ''.obs;
  RxString updateTitle = ''.obs;
  late SharedPreferencesAsync prefs;
  Rx<AdminVariablesUpdates?> updates = Rx<AdminVariablesUpdates?>(null);

  @override
  void onInit() async {
    updates.value = adminController.adminSettings.value?.updates;

    prefs = SharedPreferencesAsync();

    ever(adminController.adminSettings, (settings) {
      if (settings != null) {
        updates.value = settings.updates;
        checkForUpdates();
        calculateNextToShowUpdateDialog();
      } else {
        debugPrint("Admin settings is null");
      }
    });

    super.onInit();
  }

  checkForUpdates() async {
    debugPrint("Checking for updates...");

    isUpdateAvailable.value = updates.value!.isUpdateAvailable == true;
    isUpdateMandatory.value = updates.value!.isUpdateMandatory == true;
    latestVersion.value = updates.value!.latestVersion ?? '';
    // Assuming currentVersion is set somewhere in the app, e.g., from package_info
    final packageInfo = await PackageInfo.fromPlatform();
    currentVersion.value = packageInfo.version;
    updateMessage.value = 'A new version of the app is available.';
    updateUrl.value = await getStoreUrl() ?? "";
    updateTitle.value = 'Update Available';

    if (isUpdateAvailable.value &&
        isVersionOutdated(currentVersion.value, latestVersion.value) &&
        await prefs.getBool('hasShownUpdateDialog') == false) {
      showUpdateDialog(isUpdateMandatory.value);
      await prefs.setBool('hasShownUpdateDialog', true);
    }
  }

  bool isVersionOutdated(String current, String latest) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || currentParts[i] < latestParts[i]) {
        return true;
      }
      if (currentParts[i] > latestParts[i]) return false;
    }
    return false;
  }

  calculateNextToShowUpdateDialog() {
    Future.delayed(Duration(days: 3), () async {
      await prefs.setBool("hasShownUpdateDialog", false);
    });
  }

  Future<String?> getStoreUrl() async {
    await dotenv.load(fileName: ".env");

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String packageName = packageInfo.packageName;
    // String appName = packageInfo.appName;

    // NOTE: You'll need to manually get and store your Apple App ID.
    // It's not available through package_info_plus.
    String appleAppId = dotenv.env["APPLE_APP_ID"] ?? "";

    if (kIsWeb) {
      return null; // Not applicable for web
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return adminController.adminSettings.value?.playStore ??
          'https://play.google.com/store/apps/details?id=$packageName';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return adminController.adminSettings.value?.appStore ??
          'https://apps.apple.com/app/id$appleAppId';
    }
    return null;
  }

  showUpdateDialog(bool isMandatory) {
    Get.defaultDialog(
      titleStyle: TextStyle(
        fontFamily: "Lato",
        fontSize: 20,
        color: AppColors.main,
        fontWeight: FontWeight.w700,
      ),
      title: updateTitle.value,
      content: Text(
        updateMessage.value,
        style: TextStyle(
          fontFamily: "Lato",
          fontSize: 15,
          color: AppColors.main,
        ),
      ),
      cancel: isMandatory
          ? null // No cancel button if mandatory
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Get.back();
              },
              child: const Text(
                "Later",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF673AB7),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 32),
          //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFF673AB7),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          final uri = Uri.parse(updateUrl.value);
          await launchUrl(uri);
          // await userController.deleteAccount();
        },
        child: const Text(
          "Update Now",
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      barrierDismissible: false,
      onWillPop: isMandatory
          ? () async =>
              false // Prevent dialog from being dismissed if mandatory
          : null,
    );
  }
}
