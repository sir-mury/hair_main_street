import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/admin_controller.dart';
import 'package:hair_main_street/controllers/cart_controller.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/extras/delegate.dart';
import 'package:hair_main_street/pages/notifcation.dart';
import 'package:hair_main_street/utils/screen_sizes.dart';
import 'package:hair_main_street/widgets/cards.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ion.dart';
import 'package:recase/recase.dart';

class NewFeedPage extends StatefulWidget {
  const NewFeedPage({super.key});

  @override
  State<NewFeedPage> createState() => _NewFeedPageState();
}

class _NewFeedPageState extends State<NewFeedPage>
    with TickerProviderStateMixin {
  ProductController productController = Get.find<ProductController>();
  UserController userController = Get.find<UserController>();
  WishListController wishlistController = Get.find<WishListController>();
  TabController? tabController;

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetX<AdminController>(
      builder: (adminController) {
        // RxBool isUserLoggedIn = (userController.userState.value != null).obs;

        // if (isUserLoggedIn.value) {
        //   wishlistController.fetchWishList();
        // }
        // Build categories list reactively
        List<String> categories = [
          "All",
          ...adminController.adminSettings.value?.categories ?? []
        ];

        // Only create TabController if categories are loaded and not empty
        if (tabController == null ||
            tabController!.length != categories.length) {
          tabController?.dispose();
          tabController = TabController(length: categories.length, vsync: this);
        }

        // Now you can safely use tabController and categories
        return Scaffold(
          appBar: AppBar(
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
              Stack(
                children: [
                  IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () => Get.to(() => NotificationsPage()),
                    icon: const Iconify(
                      Ion.md_notifications_outline,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  // Positioned(
                  //   right: 12,
                  //   top: 1,
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       color: Colors.red,
                  //     ),
                  //     width: 8,
                  //     height: 8,
                  //   ),
                  // )
                ],
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
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
                            colorFilter: ColorFilter.mode(
                              Colors.black54.withValues(alpha: 0.50),
                              BlendMode.srcIn,
                            ),
                            height: 18,
                            width: 18,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            "Search",
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.45),
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
                    width: MediaQuery.of(context).size.width,
                    child: TabBar(
                        isScrollable: true,
                        controller: tabController,
                        tabAlignment: TabAlignment.start,
                        indicatorWeight: 5,
                        indicatorColor: const Color(0xFF673AB7),
                        tabs: categories
                            .map((e) => Text(
                                  e.titleCase,
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
            if (controller.isLoading.isTrue) {
              return const LoadingWidget();
            } else {
              return productController.productMap.length == categories.length
                  ? TabBarView(
                      controller: tabController,
                      children: List.generate(
                          productController.productMap.length, (index) {
                        return Obx(
                          () {
                            var products =
                                productController.productMap[categories[index]];
                            return products!.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No Products Yet",
                                      style: TextStyle(
                                        fontSize: 40,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                : SafeArea(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Column(
                                        // shrinkWrap: false,
                                        children: [
                                          MasonryGridView.count(
                                              crossAxisCount:
                                                  !Responsive.isMobile(context)
                                                      ? 3
                                                      : 2,
                                              crossAxisSpacing: 4,
                                              mainAxisSpacing: 8,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shrinkWrap: true,
                                              itemCount: productController
                                                  .productMap[categories[index]]
                                                  ?.length,
                                              itemBuilder: (context, index1) {
                                                return ProductCard(
                                                  mapKey: categories[index],
                                                  index: index1,
                                                  id: productController
                                                      .productMap[categories[
                                                          index]]![index1]!
                                                      .productID,
                                                );
                                              }),
                                          const SizedBox(
                                            height: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                          },
                        );
                      }),
                    )
                  : const Center(
                      child: Text(
                        "Loading Products...",
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.black,
                        ),
                      ),
                    );
            }
          }),
        );
      },
    );
  }
}
