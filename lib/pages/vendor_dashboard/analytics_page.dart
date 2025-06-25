import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/blank_page.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

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
          'Analytics',
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
      body: BlankPage(
        text: "This page is under construction",
        haveAppBar: true,
        appBarText: "Analytics Page",
        pageIcon: const Icon(
          Icons.construction_rounded,
          color: Color(0xFF673AB7),
          size: 40,
        ),
      ),
    );
  }
}
