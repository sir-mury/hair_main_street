import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PushNotifications extends StatefulWidget {
  const PushNotifications({super.key});

  @override
  State<PushNotifications> createState() => _PushNotificationsState();
}

class _PushNotificationsState extends State<PushNotifications> {
  bool orderNotification = false;
  bool activityNotification = false;
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
          'Push Notifications',
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
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        children: [
          SwitchListTile(
            value: orderNotification,
            onChanged: (value) {
              setState(() {
                orderNotification = value;
              });
            },
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            //activeColor: const Color(0xFF673AB7).withOpacity(0.25),
            activeTrackColor: const Color(0xFF673AB7).withOpacity(0.73),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
            //materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            trackOutlineColor: const WidgetStatePropertyAll(Colors.white),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            title: Text(
              "Orders",
              style: TextStyle(
                color: Colors.black.withOpacity(0.80),
                fontSize: 16,
                fontFamily: "Lato",
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              "Order status, tracking updates, dispute progress and more...",
              style: TextStyle(
                color: Colors.black.withOpacity(0.80),
                fontSize: 14,
                fontFamily: "Raleway",
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Divider(
            height: 2,
            color: Colors.black12,
          ),
          SwitchListTile(
            value: activityNotification,
            onChanged: (value) {
              setState(() {
                activityNotification = value;
              });
            },
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            //activeColor: const Color(0xFF673AB7).withOpacity(0.25),
            activeTrackColor: const Color(0xFF673AB7).withOpacity(0.73),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
            //materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            trackOutlineColor: const WidgetStatePropertyAll(Colors.white),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            title: Text(
              "Activity",
              style: TextStyle(
                color: Colors.black.withOpacity(0.80),
                fontSize: 16,
                fontFamily: "Lato",
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              "Notifications related to your account activity",
              style: TextStyle(
                color: Colors.black.withOpacity(0.80),
                fontSize: 14,
                fontFamily: "Raleway",
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Divider(
            height: 2,
            color: Colors.black12,
          ),
        ],
      ),
    );
  }
}
