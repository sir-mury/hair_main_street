import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/productController.dart';
import 'package:hair_main_street/extras/delegate.dart';
import 'package:hair_main_street/widgets/cards.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:shimmer/shimmer.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    ProductController productController = Get.find<ProductController>();
    GlobalKey<FormState> formKey = GlobalKey();
    num screenHeight = MediaQuery.of(context).size.height;
    num screenWidth = MediaQuery.of(context).size.width;
    Gradient myGradient = const LinearGradient(
      colors: [
        Color.fromARGB(255, 255, 224, 139),
        Color.fromARGB(255, 200, 242, 237),
      ],
      stops: [
        0.05,
        0.99,
      ],
      end: Alignment.topCenter,
      begin: Alignment.bottomCenter,
      //transform: GradientRotation(math.pi / 4),
    );
    Gradient appBarGradient = const LinearGradient(
      colors: [
        Color.fromARGB(255, 200, 242, 237),
        Color.fromARGB(255, 255, 224, 139),
      ],
      stops: [
        0.05,
        0.99,
      ],
      end: Alignment.topCenter,
      begin: Alignment.bottomCenter,
      //transform: GradientRotation(math.pi / 4),
    );
    CarouselController carouselController = CarouselController();
    return Scaffold(
      appBar: AppBar(
        // bottom: PreferredSize(
        //     preferredSize: Size.fromHeight(screenHeight * 0.04),
        //     child: Form(child: child)),
        title: const Text(
          'Hair Main Street',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0E4D92),
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: MySearchDelegate());
            },
            icon: const Icon(
              Icons.search,
              color: Colors.black,
              size: 28,
            ),
          ),
        ],
        centerTitle: true,
        //backgroundColor: const Color(0xFF0E4D92),

        //backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[100],
      //extendBody: false,
      body: Container(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
        //decoration: BoxDecoration(gradient: myGradient),
        child: ListView(
          //shrinkWrap: true,
          children: [
            HeaderText(text: "Explore"),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // IconButton(
                //   //color: Color(0xFFF4D06F),
                //   onPressed: () => carouselController.previousPage(
                //     duration: const Duration(milliseconds: 200),
                //     curve: Curves.easeIn,
                //   ),
                //   icon: Icon(
                //     Icons.arrow_back_ios_new_rounded,
                //     size: 20,
                //     color: Colors.black,
                //   ),
                // ),
                Container(
                  width: screenWidth * 0.90,
                  child: CarouselSlider(
                    items: [
                      Container(
                        color: Colors.black,
                      ),
                      Container(
                        color: Colors.amber,
                      ),
                      Container(
                        color: Colors.blue,
                      ),
                    ],
                    carouselController: carouselController,
                    options: CarouselOptions(
                      enlargeFactor: 0.1,
                      height: screenHeight * 0.30,
                      autoPlay: true,
                      pauseAutoPlayOnManualNavigate: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.70,
                    ),
                  ),
                ),
                // IconButton(
                //   //color: Colors.white,
                //   onPressed: () => carouselController.nextPage(
                //     duration: const Duration(milliseconds: 200),
                //     curve: Curves.easeIn,
                //   ),
                //   icon: Icon(
                //     Icons.arrow_forward_ios_rounded,
                //     size: 20,
                //     color: Colors.black,
                //   ),
                // ),
              ],
            ),
            SizedBox(
              height: 4,
            ),
            HeaderText(text: "Products"),
            SizedBox(
              height: 4,
            ),
            Center(
              child: GetX<ProductController>(builder: (controller) {
                return controller.products.value.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Color(0xFF392F5A),
                          strokeWidth: 4,
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: screenHeight * 0.295,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 24,
                        ),
                        itemBuilder: (_, index) => ProductCard(
                          id: controller.products.value[index]!.productID,
                          index: index,
                        ),
                        itemCount: controller.products.value.length,
                      );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderText extends StatelessWidget {
  final String? text;
  const HeaderText({
    this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
      ),
      child: Text(
        text!,
        style: TextStyle(
          fontSize: 24,
        ),
      ),
    );
  }
}
