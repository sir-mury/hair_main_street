import 'package:contentsize_tabbarview/contentsize_tabbarview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/blankPage.dart';
import 'package:hair_main_street/controllers/userController.dart';
import 'package:hair_main_street/controllers/vendorController.dart';
import 'package:hair_main_street/extras/delegate.dart';
import 'package:hair_main_street/pages/authentication/sign_in.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/widgets/cards.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'messages.dart';

class ClientShopPage extends StatefulWidget {
  final String? vendorID;
  const ClientShopPage({this.vendorID, super.key});

  @override
  State<ClientShopPage> createState() => _ClientShopPageState();
}

class _ClientShopPageState extends State<ClientShopPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  UserController userController = Get.find<UserController>();
  VendorController vendorController = Get.find<VendorController>();
  int? itemCount = 6;

  @override
  void initState() {
    var vendorID = widget.vendorID ?? Get.arguments['vendorID'];
    super.initState();
    vendorController.getVendorDetails(vendorID);
    vendorController.getVendorsProducts(vendorID);
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    num screenHeight = MediaQuery.of(context).size.height;
    num screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder(
        stream: DataBaseService().getVendorDetails(userID: widget.vendorID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingWidget();
          }
          return StreamBuilder(
            stream: DataBaseService().getVendorProducts(widget.vendorID!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                );
              }
              vendorController.getProductsByAge(vendorController.productList);
              double storeRating =
                  vendorController.calculateOverallAverageReviewValue();
              return Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        scrolledUnderElevation: 0,
                        expandedHeight: 200,
                        centerTitle: false,
                        pinned: true,
                        floating: true,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        leading: IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Symbols.arrow_back_ios_new_rounded,
                              size: 24, color: Colors.black),
                        ),
                        title: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            backgroundColor: const Color(0xFFF5F5F5),
                            //elevation: 2,
                            shape: const RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.black,
                                width: 0.2,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                          onPressed: () => showSearch(
                              context: context,
                              delegate: VendorProductSearchDelegate()),
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
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            padding: const EdgeInsets.only(top: 30),
                            // color: Colors.orange,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ClipOval(
                                        child: vendorController.vendor.value!
                                                        .shopPicture !=
                                                    null &&
                                                vendorController.vendor.value!
                                                    .shopPicture!.isNotEmpty
                                            ? Image.network(
                                                vendorController
                                                    .vendor.value!.shopPicture!,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                color: const Color(0xFF703535),
                                                height: 60,
                                                width: 60,
                                                child: SvgPicture.asset(
                                                  "assets/Icons/user.svg",
                                                  height: 30,
                                                  width: 30,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${vendorController.vendor.value!.shopName}',
                                              maxLines: 2,
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Lato',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (userController.userState.value ==
                                              null) {
                                            Get.to(() => BlankPage(
                                                  haveAppBar: true,
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                  ),
                                                  buttonStyle:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF673AB7),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: const BorderSide(
                                                        width: 1.2,
                                                        color: Colors.black,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  pageIcon: const Icon(
                                                    Icons.person_off_outlined,
                                                    size: 48,
                                                  ),
                                                  text:
                                                      "Your are not Logged In",
                                                  interactionText:
                                                      "Sign In or Register",
                                                  interactionIcon: const Icon(
                                                    Icons.person_2_outlined,
                                                    size: 24,
                                                    color: Colors.white,
                                                  ),
                                                  interactionFunction: () =>
                                                      Get.to(
                                                          () => const SignIn()),
                                                ));
                                          } else {
                                            Get.to(
                                              () => MessagesPage(
                                                participant1: userController
                                                    .userState.value!.uid,
                                                participant2: vendorController
                                                    .vendor.value!.userID,
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF673AB7),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 18),
                                        ),
                                        child: const Text(
                                          'Message',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 25),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF673AB7)
                                        .withOpacity(0.70),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "$storeRating",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Lato',
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const Text(
                                              "Store Rating",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Raleway',
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1.5,
                                        height: 30,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${vendorController.productList.length}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Lato',
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const Text(
                                              "Products in Store",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Raleway',
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        floating: false,
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: tabController,
                            labelPadding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 12),
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            indicatorColor: const Color(0xFF673AB7),
                            indicatorWeight: 5,
                            indicatorPadding: const EdgeInsets.only(top: 2),
                            labelStyle: const TextStyle(
                              fontSize: 17,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF673AB7),
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 17,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            tabs: const [
                              Text(
                                "All Products",
                              ),
                              Text(
                                "New Arrivals",
                              ),
                              Text(
                                "Shop Details",
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: DefaultTabController(
                          length: 3,
                          child: ContentSizeTabBarView(
                            controller: tabController,
                            children: [
                              //vendor products page
                              Column(
                                children: [
                                  vendorController.productList.isNotEmpty
                                      ? MasonryGridView.count(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 4,
                                          mainAxisSpacing: 8,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 8),
                                          shrinkWrap: true,
                                          //itemCount: itemCount,
                                          itemBuilder: (_, index) =>
                                              ClientShopCard(
                                            index: index,
                                          ),
                                          itemCount: vendorController
                                              .productList.length,
                                        )
                                      : const SizedBox(
                                          height: 400,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.do_not_disturb,
                                                  size: 50,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(
                                                  height: 12,
                                                ),
                                                Text(
                                                  "No Products to display yet",
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                    fontFamily: "Lato",
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  // SizedBox(
                                  //   width: screenWidth * 0.40,
                                  //   child: TextButton(
                                  //     onPressed: () {
                                  //       setState(() {
                                  //         // Assuming productController.productMap["All"] is your list
                                  //         int listLength = vendorController
                                  //             .productList.length;

                                  //         // Check if the list length is greater than itemCount
                                  //         if (listLength > itemCount!) {
                                  //           // Increment itemCount by 2
                                  //           itemCount = itemCount! + 2;
                                  //         } else if (listLength ==
                                  //             itemCount! + 1) {
                                  //           // If the list length is equal to itemCount plus 1, increment itemCount by 1
                                  //           itemCount = itemCount! + 1;
                                  //         }

                                  //         // Check if itemCount has reached a value that makes the button unresponsive
                                  //         if (itemCount! >= listLength) {
                                  //           // Disable the button or set a flag to make it unresponsive
                                  //           // This is just an example. You'll need to implement the actual logic to disable the button.
                                  //           //isButtonDisabled = true;
                                  //         }
                                  //       });
                                  //     },
                                  //     style: TextButton.styleFrom(
                                  //       backgroundColor: const Color(0xFF673AB7)
                                  //           .withOpacity(0.70),
                                  //       shape: RoundedRectangleBorder(
                                  //         borderRadius:
                                  //             BorderRadius.circular(10),
                                  //       ),
                                  //       //   side: const BorderSide(
                                  //       //     width: 2,
                                  //       //     color: Colors.black,
                                  //       //   ),
                                  //       // ),
                                  //     ),
                                  //     child: const Text(
                                  //       "Load More >>>",
                                  //       style: TextStyle(
                                  //         color: Colors.white,
                                  //         fontSize: 14,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),

                              //new arrivals page
                              ListView(
                                shrinkWrap: true,
                                // ignore: prefer_const_constructors
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      vendorController.filteredVendorProductList
                                              .isNotEmpty
                                          ? ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: vendorController
                                                  .filteredVendorProductList
                                                  .length,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Visibility(
                                                      visible: vendorController
                                                          .filteredVendorProductList
                                                          .values
                                                          .elementAt(index)
                                                          .isNotEmpty,
                                                      child: Text(
                                                        vendorController
                                                            .filteredVendorProductList
                                                            .keys
                                                            .elementAt(index),
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          fontFamily: 'Lato',
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    Column(
                                                      children: List.generate(
                                                        vendorController
                                                            .filteredVendorProductList
                                                            .values
                                                            .elementAt(index)
                                                            .length,
                                                        (index2) =>
                                                            VendorArrivalCard(
                                                          productID: vendorController
                                                              .filteredVendorProductList
                                                              .values
                                                              .elementAt(
                                                                  index)[index2]
                                                              .productID,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              })
                                          : const SizedBox(
                                              height: 400,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.do_not_disturb,
                                                      size: 50,
                                                      color: Colors.black,
                                                    ),
                                                    SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      "No Products to display yet",
                                                      style: TextStyle(
                                                        fontSize: 30,
                                                        fontFamily: "Lato",
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      // ListView.builder(
                                      //   physics:
                                      //       const NeverScrollableScrollPhysics(),
                                      //   shrinkWrap: true,
                                      //   itemCount: vendorController
                                      //       .filteredVendorProductList.values
                                      //       .elementAt(index)
                                      //       .length,
                                      //   itemBuilder: (context, index2) {
                                      //     return VendorArrivalCard(
                                      //       productID: vendorController
                                      //           .filteredVendorProductList
                                      //           .values
                                      //           .elementAt(index)[index]
                                      //           .productID,
                                      //     );
                                      //   },
                                      // ),
                                    ],
                                  ),
                                ],
                              ),

                              //vendor info page
                              SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 4,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Card(
                                      elevation: 0,
                                      color: const Color(0xFF673AB7)
                                          .withOpacity(0.20),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Shop Name",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Raleway",
                                                color: Colors.black,
                                              ),
                                            ),
                                            SelectableText(
                                              vendorController
                                                  .vendor.value!.shopName!,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontFamily: "Lato",
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              minLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Card(
                                      elevation: 0,
                                      color: const Color(0xFF673AB7)
                                          .withOpacity(0.20),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Shop Address",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Raleway",
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SelectableText(
                                                "${vendorController.vendor.value!.contactInfo!['street address']}\n${vendorController.vendor.value!.contactInfo!['local government']} LGA\n${vendorController.vendor.value!.contactInfo!['state']}\n${vendorController.vendor.value!.contactInfo!['country']}",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: "Lato",
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                                minLines: 1,
                                                //overflow: TextOverflow.ellipsis,
                                              ),
                                            ]),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Card(
                                      elevation: 0,
                                      color: const Color(0xFF673AB7)
                                          .withOpacity(0.20),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Phone Number",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Raleway",
                                                color: Colors.black,
                                              ),
                                            ),
                                            SelectableText(
                                                "${vendorController.vendor.value!.contactInfo!['phone number']}",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: "Lato",
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                                minLines: 1
                                                //overflow: TextOverflow.ellipsis,
                                                ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  // Calculate the actual size of the TabBar
  double get tabBarActualHeight {
    // Example calculation - adjust according to your TabBar's actual size
    return _tabBar.preferredSize.height + 10; // Add extra space if needed
  }

  @override
  double get minExtent => 31;
  @override
  double get maxExtent => 31;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
