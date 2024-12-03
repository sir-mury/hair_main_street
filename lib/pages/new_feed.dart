import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/productController.dart';
import 'package:hair_main_street/controllers/review_controller.dart';
import 'package:hair_main_street/controllers/userController.dart';
import 'package:hair_main_street/extras/delegate.dart';
import 'package:hair_main_street/pages/notifcation.dart';
import 'package:hair_main_street/widgets/cards.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ion.dart';

class NewFeedPage extends StatefulWidget {
  const NewFeedPage({super.key});

  @override
  State<NewFeedPage> createState() => _NewFeedPageState();
}

class _NewFeedPageState extends State<NewFeedPage>
    with TickerProviderStateMixin {
  int? itemCount;
  ProductController productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    Get.find<UserController>();
    Get.put(ReviewController());
    //VendorController vendorController = Get.find<VendorController>();
    num screenHeight = MediaQuery.of(context).size.height;
    num screenWidth = MediaQuery.of(context).size.width;
    List<Map<String, num>> categories = [
      {
        "All": 4,
      },
      {"Natural Hair": 1},
      {"Wigs": 1},
      {"Accessories": 1},
      {"Lashes": 1},
    ];
    TabController tabController =
        TabController(length: categories.length, vsync: this);
    // if (userController.userState.value != null) {
    //   WishListController wishListController = Get.find<WishListController>();
    //   wishListController.fetchWishList();
    // }

    return Scaffold(
      appBar: AppBar(
        // bottom: PreferredSize(
        //     preferredSize: Size.fromHeight(screenHeight * 0.04),
        //     child: Form(child: child)),
        title: const Padding(
          padding: EdgeInsets.only(bottom: 16, top: 15),
          child: Text(
            'Explore Our Collection',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF673AB7),
              fontFamily: "Lato",
            ),
          ),
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () => Get.to(() => NotificationsPage()),
            icon: const Iconify(
              Ion.md_notifications_outline,
              color: Colors.black,
              size: 24,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        "assets/Icons/search-normal-1.svg",
                        color: Colors.black54.withOpacity(0.50),
                        height: 18,
                        width: 18,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Search",
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.45),
                          fontFamily: 'Raleway',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth * 1,
                child: TabBar(
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    controller: tabController,
                    indicatorWeight: 5,
                    indicatorColor: const Color(0xFF673AB7),
                    tabs: categories
                        .map((e) => Text(
                              e.keys.first,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ))
                        .toList()),
              ),
            ],
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      extendBody: true,
      body: GetX<ProductController>(builder: (controller) {
        return controller.products.isEmpty
            ? const LoadingWidget()
            : TabBarView(
                controller: tabController,
                children: [
                  Obx(
                    () {
                      var products = productController.productMap["All"];
                      return products!.isEmpty
                          ? const Center(
                              child: Text(
                                "Nothing Here",
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : SafeArea(
                              child: SingleChildScrollView(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  // shrinkWrap: false,
                                  children: [
                                    MasonryGridView.count(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 4,
                                        mainAxisSpacing: 8,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shrinkWrap: true,
                                        itemCount: productController
                                            .productMap["All"]?.length,
                                        itemBuilder: (context, index) {
                                          return ProductCard(
                                            mapKey: "All",
                                            index: index,
                                            id: productController
                                                .productMap["All"]![index]!
                                                .productID,
                                          );
                                        }),
                                    SizedBox(
                                      width: screenWidth * 0.40,
                                      child: TextButton(
                                        onPressed: () {
                                          productController.showMyToast(
                                              "More products Loading...");
                                          // setState(() {
                                          //   // Assuming productController.productMap["All"] is your list
                                          //   int listLength = productController
                                          //       .productMap["All"]!.length;

                                          //   // Check if the list length is greater than itemCount
                                          //   if (itemCount! < listLength) {
                                          //     // Calculate the difference between listLength and current item count
                                          //     final difference =
                                          //         listLength - itemCount!;

                                          //     if (difference > 1) {
                                          //       itemCount = itemCount! + 2;
                                          //     } else {
                                          //       itemCount = itemCount! + 1;
                                          //     }
                                          //   } else {
                                          //     // List is already full, return it without changes
                                          //     itemCount;
                                          //     productController.showMyToast(
                                          //         "More products coming soon...");
                                          //   }
                                          //   // Check if itemCount has reached a value that makes the button unresponsive
                                          //   // if (itemCount! >= listLength) {}
                                          // });
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF673AB7)
                                                  .withOpacity(0.70),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          //   side: const BorderSide(
                                          //     width: 2,
                                          //     color: Colors.black,
                                          //   ),
                                          // ),
                                        ),
                                        child: const Text(
                                          "Load More >>>",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    // const Align(
                                    //   alignment: Alignment.centerLeft,
                                    //   child: Text(
                                    //     "Vendor Highlights",
                                    //     textAlign: TextAlign.left,
                                    //     style: TextStyle(
                                    //       fontSize: 24,
                                    //       fontWeight: FontWeight.w600,
                                    //       fontFamily: 'Lato',
                                    //     ),
                                    //   ),
                                    // ),
                                    // const SizedBox(
                                    //   height: 4,
                                    // ),
                                    // MasonryGridView.count(
                                    //   crossAxisSpacing: 4,
                                    //   mainAxisSpacing: 8,
                                    //   crossAxisCount: 2,
                                    //   physics:
                                    //       const NeverScrollableScrollPhysics(),
                                    //   padding: const EdgeInsets.symmetric(
                                    //       vertical: 8),
                                    //   shrinkWrap: true,
                                    //   itemCount: controller.vendorsList.length,
                                    //   // gridDelegate:
                                    //   //     SliverGridDelegateWithFixedCrossAxisCount(
                                    //   //   crossAxisCount: 2,
                                    //   //   crossAxisSpacing: 4,
                                    //   //   mainAxisExtent: screenHeight * 0.27,
                                    //   //   mainAxisSpacing: 8,
                                    //   // ),
                                    //   itemBuilder: (context, index) =>
                                    //       VendorHighlightsCard(
                                    //     index: index,
                                    //     // id: productController
                                    //     //     .products.value[index]!.productID,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            );
                    },
                  ),
                  // Repeat the above pattern for other TabBarView children
                  Obx(() {
                    var product = productController.productMap["Natural Hairs"];

                    return product!.isEmpty
                        ? const Center(
                            child: Text(
                              "Nothing Here",
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.black,
                              ),
                            ),
                          )
                        : ListView.builder(
                            // padding:
                            //     const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MasonryGridView.count(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 8,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shrinkWrap: true,
                                      itemCount: productController
                                          .productMap["Natural Hairs"]!.length,
                                      // gridDelegate:
                                      //     SliverGridDelegateWithFixedCrossAxisCount(
                                      //   crossAxisCount: 2,
                                      //   crossAxisSpacing: 12,
                                      //   mainAxisExtent:
                                      //       mainAxisExtent as double,
                                      //   mainAxisSpacing: 12,
                                      // ),
                                      itemBuilder: (context, index) =>
                                          ProductCard(
                                        mapKey: "Natural Hairs",
                                        index: index,
                                        id: productController
                                            .productMap["Natural Hairs"]![
                                                index]!
                                            .productID,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            itemCount: 1);
                  }),
                  Obx(() {
                    var product = productController.productMap["Wigs"];

                    return product!.isEmpty
                        ? const Center(
                            child: Text(
                              "Nothing Here",
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.black,
                              ),
                            ),
                          )
                        : ListView.builder(
                            // padding:
                            //     const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MasonryGridView.count(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 8,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shrinkWrap: true,
                                      itemCount: productController
                                          .productMap["Wigs"]!.length,
                                      // gridDelegate:
                                      //     SliverGridDelegateWithFixedCrossAxisCount(
                                      //   crossAxisCount: 2,
                                      //   crossAxisSpacing: 12,
                                      //   mainAxisExtent:
                                      //       mainAxisExtent as double,
                                      //   mainAxisSpacing: 12,
                                      // ),
                                      itemBuilder: (context, index) =>
                                          ProductCard(
                                        mapKey: "Wigs",
                                        index: index,
                                        id: productController
                                            .productMap["Wigs"]![index]!
                                            .productID,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            itemCount: 1,
                          );
                  }),

                  Obx(() {
                    var product = productController.productMap["Accessories"];

                    return product!.isEmpty
                        ? const Center(
                            child: Text(
                              "Nothing Here",
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.black,
                              ),
                            ),
                          )
                        : ListView.builder(
                            // padding:
                            //     const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MasonryGridView.count(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 8,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shrinkWrap: true,
                                      itemCount: productController
                                          .productMap["Accessories"]!.length,
                                      // gridDelegate:
                                      //     SliverGridDelegateWithFixedCrossAxisCount(
                                      //   crossAxisCount: 2,
                                      //   crossAxisSpacing: 12,
                                      //   mainAxisExtent:
                                      //       mainAxisExtent as double,
                                      //   mainAxisSpacing: 12,
                                      // ),
                                      itemBuilder: (context, index) =>
                                          ProductCard(
                                        mapKey: "Accessories",
                                        index: index,
                                        id: productController
                                            .productMap["Accessories"]![index]!
                                            .productID,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            itemCount: 1,
                          );
                  }),
                  Obx(() {
                    var product = productController.productMap["Lashes"];

                    return product!.isEmpty
                        ? const Center(
                            child: Text(
                              "Nothing Here",
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.black,
                              ),
                            ),
                          )
                        : ListView.builder(
                            // padding:
                            //     const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MasonryGridView.count(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 8,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shrinkWrap: true,
                                      itemCount: productController
                                          .productMap["Lashes"]!.length,
                                      // gridDelegate:
                                      //     SliverGridDelegateWithFixedCrossAxisCount(
                                      //   crossAxisCount: 2,
                                      //   crossAxisSpacing: 12,
                                      //   mainAxisExtent:
                                      //       mainAxisExtent as double,
                                      //   mainAxisSpacing: 12,
                                      // ),
                                      itemBuilder: (context, index) =>
                                          ProductCard(
                                        mapKey: "Lashes",
                                        index: index,
                                        id: productController
                                            .productMap["Lashes"]![index]!
                                            .productID,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            itemCount: 1,
                          );
                  }),
                ],
              );
      }),
    );
  }
}
