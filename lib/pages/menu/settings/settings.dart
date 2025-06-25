import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/pages/menu/settings/email_notifications.dart';
import 'package:hair_main_street/pages/menu/settings/push_notifications.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.black),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lato',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        // flexibleSpace: Container(
        //   decoration: BoxDecoration(gradient: appBarGradient),
        // ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          InkWell(
            onTap: () {
              Get.to(() => const PushNotifications());
            },
            child: Container(
              height: 60,
              alignment: Alignment.centerLeft,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Push Notifications",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Lato",
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            color: Colors.black12,
            height: 2,
          ),
          InkWell(
            onTap: () {
              Get.to(() => const EmailNotifications());
            },
            child: Container(
              height: 60,
              alignment: Alignment.centerLeft,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Email Notifications",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Lato",
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            color: Colors.black12,
            height: 2,
          ),
        ],
      ),
    );
  }
}
