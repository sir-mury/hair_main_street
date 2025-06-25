import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/utils/app_colors.dart';

class RequestCancellationPage extends StatelessWidget {
  const RequestCancellationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 24, color: Colors.black),
        ),
        title: const Text(
          'Request/Cancellation Requests',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: AppColors.main,
            fontFamily: 'Lato',
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
