import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/extras/delegate.dart';
import 'package:hair_main_street/pages/notifcation.dart';
import 'package:hair_main_street/widgets/cards.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // ProductController productController = Get.find<ProductController>();
    //VendorController vendorController = Get.find<VendorController>();
    // GlobalKey<FormState> formKey = GlobalKey();
    num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    List<Map> categories = [
      {
        "Natural Hair":
            "assets/images/DALL·E 2024-02-13 10.22.29 - an image i can use as the category image for  natural hair on an app.png"
      },
      {"Wigs": "assets/images/wigs.jpeg"},
      {"Accessories": "assets/images/accessories.jpeg"},
      {"Lashes": "assets/images/DIY lash extensions.jpeg"},
    ];
    TabController tabController =
        TabController(length: categories.length, vsync: this);

    // CarouselController carouselController = CarouselController();
    return Scaffold(
      appBar: AppBar(
        // bottom: PreferredSize(
        //     preferredSize: Size.fromHeight(screenHeight * 0.04),
        //     child: Form(child: child)),
        title: const Text(
          'Home',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.09),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    backgroundColor: Colors.grey.shade50,
                    //elevation: 2,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.grey.shade500,
                        width: 0.5,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                  onPressed: () => showSearch(
                      context: context, delegate: MySearchDelegate()),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.black54,
                        size: 24,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        "Search for hairs, shops and more",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              TabBar(
                  controller: tabController,
                  indicatorColor: Colors.black,
                  tabs: categories
                      .map((e) => Text(
                            e.keys.first,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ))
                      .toList()),
            ],
          ),
        ),

        actions: [
          // IconButton(
          //   onPressed: () {
          //     showSearch(context: context, delegate: MySearchDelegate());
          //   },
          //   icon: const Icon(
          //     Icons.search,
          //     color: Colors.black,
          //     size: 28,
          //   ),
          // ),
          Transform.rotate(
            angle: 0.3490659,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                onPressed: () {
                  Get.to(() => NotificationsPage());
                },
                icon: const Icon(
                  Icons.notifications_active_rounded,
                  size: 28,
                  color: Colors.black,
                ),
              ),
            ),
          )
        ],
        centerTitle: true,
        //backgroundColor: const Color(0xFF0E4D92),

        //backgroundColor: Colors.transparent,
      ),
      extendBody: true,
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.grey[100],
      //extendBody: false,
      body: Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        //decoration: BoxDecoration(gradient: myGradient),
        child: CustomScrollView(
          slivers: [
            GetX<ProductController>(
              builder: (controller) {
                return controller.products.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => ProductCard(
                              // id: productController
                              //     .products.value[index]!.productID,
                              index: index,
                            ),
                            childCount: 2,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisExtent: screenHeight * 0.28,
                            mainAxisSpacing: 12,
                          ),
                        ),
                      );
              },
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const HeaderText(text: "Hot Deals"),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: categories
                            .map((val) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 4),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage:
                                            AssetImage("${val.values.first}"),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Text(val.keys.first),
                                    ],
                                  ),
                                ))
                            .toList()),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  const HeaderText(text: "Shops"),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     // IconButton(
                  //     //   //color: Color(0xFFF4D06F),
                  //     //   onPressed: () => carouselController.previousPage(
                  //     //     duration: const Duration(milliseconds: 200),
                  //     //     curve: Curves.easeIn,
                  //     //   ),
                  //     //   icon: Icon(
                  //     //     Icons.arrow_back_ios_new_rounded,
                  //     //     size: 20,
                  //     //     color: Colors.black,
                  //     //   ),
                  //     // ),
                  //     Container(
                  //       width: screenWidth * 0.90,
                  //       child: CarouselSlider(
                  //         items: [
                  //           Container(
                  //             color: Colors.black,
                  //           ),
                  //           Container(
                  //             color: Colors.amber,
                  //           ),
                  //           Container(
                  //             color: Colors.blue,
                  //           ),
                  //         ],
                  //         carouselController: carouselController,
                  //         options: CarouselOptions(
                  //           enlargeFactor: 0.1,
                  //           height: screenHeight * 0.30,
                  //           autoPlay: true,
                  //           pauseAutoPlayOnManualNavigate: true,
                  //           enlargeCenterPage: true,
                  //           viewportFraction: 0.70,
                  //         ),
                  //       ),
                  //     ),
                  //     // IconButton(
                  //     //   //color: Colors.white,
                  //     //   onPressed: () => carouselController.nextPage(
                  //     //     duration: const Duration(milliseconds: 200),
                  //     //     curve: Curves.easeIn,
                  //     //   ),
                  //     //   icon: Icon(
                  //     //     Icons.arrow_forward_ios_rounded,
                  //     //     size: 20,
                  //     //     color: Colors.black,
                  //     //   ),
                  //     // ),
                  //   ],
                  // ),
                  const SizedBox(
                    height: 4,
                  ),
                  const HeaderText(text: "Products"),
                  const SizedBox(
                    height: 4,
                  ),
                  Center(
                    child: GetX<ProductController>(builder: (controller) {
                      return controller.products.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.black,
                                strokeWidth: 4,
                              ),
                            )
                          : GridView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent: screenHeight * 0.28,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                              itemBuilder: (_, index) => ProductCard(
                                // id: controller.products[index]!.productID,
                                index: index,
                              ),
                              itemCount: controller.products.length,
                            );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: Container(
      //   margin: EdgeInsets.only(bottom: screenHeight * .088),
      //   //color: Colors.black,
      //   child: IconButton(
      //     style: IconButton.styleFrom(
      //       backgroundColor: Color(0xFF392F5A),
      //       shape: const CircleBorder(
      //         side: BorderSide(width: 1.2, color: Colors.white),
      //       ),
      //     ),
      //     onPressed: () => Get.bottomSheet(
      //       Container(
      //         color: Colors.white,
      //         height: screenHeight * .5,
      //       ),
      //     ),
      //     icon: const Icon(
      //       MyFlutterApp.panel,
      //       color: Colors.white,
      //       size: 40,
      //     ),
      //   ),
      // ),
      // floatingActionButton: Container(
      //   //width: double.infinity,
      //   margin: EdgeInsets.only(bottom: screenHeight * .056),
      //   color: Colors.transparent,
      //   child: ElevatedButton(
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: const Color(0xFF392F5A),
      //       padding: EdgeInsets.symmetric(
      //           vertical: 8, horizontal: screenWidth * 0.12),
      //       //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
      //       shape: RoundedRectangleBorder(
      //         side: const BorderSide(
      //           width: 1.2,
      //           color: Colors.black,
      //         ),
      //         borderRadius: BorderRadius.circular(16),
      //       ),
      //     ),
      //     onPressed: () {
      //       DataBaseService().addProduct();
      //     },
      //     child: const Text(
      //       "Proceed",
      //       style: TextStyle(
      //         fontSize: 24,
      //         color: Colors.white,
      //       ),
      //     ),
      //   ),
      // ),
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
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
      ),
      child: Text(
        text!,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
