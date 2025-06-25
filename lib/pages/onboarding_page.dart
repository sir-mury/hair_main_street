import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/pages/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  var screenHeight = Get.height;
  var screenWidth = Get.width;
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    var pageHeight = screenHeight - kToolbarHeight;
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: pageHeight,
          child: PageView(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
              });
            },
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(0),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(15),
                            ),
                            child: Transform.rotate(
                              angle: -pi / 0.5,
                              child: Container(
                                height: screenHeight * 0.31,
                                width: screenWidth * 0.65,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                      "assets/images/Frame 53image 1.png",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(0),
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(0),
                            ),
                            child: Container(
                              height: screenHeight * 0.31,
                              width: screenWidth * 0.30,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                    "assets/images/Frame 542nd image.png",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(0),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(15),
                            ),
                            child: Container(
                              height: screenHeight * 0.32,
                              width: screenWidth * 0.35,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                    "assets/images/Frame 56image 3 .png",
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(0),
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(0),
                            ),
                            child: Container(
                              height: screenHeight * 0.32,
                              width: screenWidth * 0.60,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                    "assets/images/Frame 55image 4.png",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Welcome to ",
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "Hair Main Street",
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF673AB7),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Your ultimate Hair market place that lets you pay in installments.",
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          "Discover a world of beautiful wigs, stylish hair accessories, and more. Enhance your look or start selling with just a few taps!",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    height: screenHeight * 0.65,
                    width: screenWidth,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image:
                            AssetImage('assets/images/Frame 62next page.png'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Easy Shopping ",
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF673AB7),
                              ),
                            ),
                            Text(
                              "Experience",
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          "Convenient & Secure",
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          "Enjoy a seamless shopping experience with our user-friendly interface and secure checkout process. Shop with confidence",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    height: screenHeight * 0.65,
                    width: screenWidth,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image:
                            AssetImage('assets/images/Frame 65next page 2.png'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Become a ",
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "Vendor",
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF673AB7),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          "Start selling with ease",
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          "Have hair accesories or wigs to sell? Join our platform as a vendor and reach thousands of customers. It's simple and profitable!",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isLastPage
          ? SafeArea(
              maintainBottomViewPadding: true,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: SizedBox(
                  height: kToolbarHeight * 0.75,
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF673AB7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool("showHome", true);
                      Get.off(() => const HomePage());
                    },
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : SafeArea(
              child: Container(
                height: kToolbarHeight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.30,
                      child: ElevatedButton(
                        onPressed: () {
                          pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.linear);
                        },
                        //tooltip: "Back",
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(14),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                                color: Color(0xFF673AB7), width: 1.5),
                          ),
                        ),
                        child: const Text(
                          "Previous",
                          style: TextStyle(
                            color: Color(0xFF673AB7),
                            fontFamily: 'Lato',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SmoothPageIndicator(
                          controller: pageController,
                          count: 3,
                          effect: WormEffect(
                            dotColor: Colors.grey.shade300,
                            dotHeight: 6,
                            spacing: 8,
                            activeDotColor: const Color(0xFF673AB7),
                          ),
                          onDotClicked: (index) {
                            pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.bounceIn,
                            );
                          },
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            pageController.jumpToPage(2);
                          },
                          // customBorder: const RoundedRectangleBorder(
                          //   side: BorderSide(color: Colors.grey, width: 15),
                          // ),
                          child: Card(
                            color: Colors.grey.shade200,
                            elevation: 0,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 20),
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Lato',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: screenWidth * 0.30,
                      child: ElevatedButton(
                        onPressed: () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.linear,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(14),
                          backgroundColor: const Color(0xFF673AB7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                                color: Color(0xFF673AB7), width: 1.5),
                          ),
                        ),
                        //tooltip: "Next",
                        child: const Text(
                          "Next",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Lato',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
