import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityController extends GetxController
    with WidgetsBindingObserver {
  RxBool isConnected = false.obs;
  RxBool firstRun = true.obs;
  Rx<AppLifecycleState> appState = AppLifecycleState.resumed.obs;
  late StreamSubscription<InternetStatus> subscription;

  @override
  void onInit() {
    debugPrint("connectivity controller innit");
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    subscription = InternetConnection().onStatusChange.listen((status) {
      if (status == InternetStatus.disconnected) {
        isConnected.value = false;
        isConnected.isFalse && firstRun.isFalse
            ? showMyToast(
                "You are Offline, some features may not work properly...")
            : null;
      } else if (status == InternetStatus.connected) {
        firstRun.isFalse ? showMyToast("Hurray... you are back online") : null;
        isConnected.value = true;
      }
    });
  }

  @override
  void onReady() {
    resetFirstRun();
  }

  //function to reset first run to false
  resetFirstRun() {
    Future.delayed(Duration(seconds: 1, milliseconds: 500), () {
      firstRun.value = false;
      debugPrint("running this, first value ${firstRun.value}");
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    subscription.cancel();
    super.onClose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   appState.value = state;
  //   debugPrint("App state: $state");
  //   if (state == AppLifecycleState.hidden) {
  //     firstRun.value = true;
  //   } else {
  //     firstRun.value = false;
  //   }
  //   super.didChangeAppLifecycleState(state);
  // }

  void showMyToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT, // 3 seconds by default, adjust if needed
      gravity: ToastGravity.CENTER, // Position at the bottom of the screen
      //timeInSec: 0.3, // Display for 0.3 seconds (300 milliseconds)
      backgroundColor: AppColors.shade2, // Optional: Set background color
      textColor: Colors.black, // Optional: Set text color
      fontSize: 14.0, // Optional: Set font size
    );
  }
}
