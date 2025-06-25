import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/cart_controller.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/widgets/cards.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:material_symbols_icons/symbols.dart';

class WishListPage extends StatelessWidget {
  const WishListPage({super.key});

  @override
  Widget build(BuildContext context) {
    WishListController wishListController = Get.find<WishListController>();
    wishListController.fetchWishList();
    // num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          elevation: 0,
          leadingWidth: 40,
          backgroundColor: Colors.white,
          leading: InkWell(
            onTap: () => Get.back(),
            radius: 12,
            child: const Icon(
              Symbols.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.black,
            ),
          ),
          scrolledUnderElevation: 0,
          title: const Text(
            'Wishlist',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              fontFamily: 'Lato',
            ),
          ),
          centerTitle: false,
          actions: [
            !wishListController.isEditingMode.value
                ? Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: InkWell(
                      radius: 100,
                      onTap: () {
                        wishListController.isEditingMode.value = true;
                      },
                      child: SvgPicture.asset(
                        'assets/Icons/edit.svg',
                        colorFilter: ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                        height: 25,
                        width: 25,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: InkWell(
                      radius: 100,
                      onTap: () {
                        wishListController.isEditingMode.value = false;
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
          ],
          // flexibleSpace: Container(
          //   decoration: BoxDecoration(gradient: appBarGradient),
          // ),
          //backgroundColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: false,
        body: StreamBuilder(
            stream: DataBaseService().fetchWishListItems(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LoadingWidget();
              }
              return wishListController.wishListItems.isEmpty
                  ? Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No Items in your WishList",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "Add products to your wishlist",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 28,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.white,
                      //decoration: BoxDecoration(gradient: myGradient),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      //padding: EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) => WishListCard(
                                productID: wishListController
                                    .wishListItems[index].wishListItemID,
                              ),
                              itemCount:
                                  wishListController.wishListItems.length,
                              shrinkWrap: true,
                            ),
                          ],
                        ),
                      ),
                    );
            }),
        bottomNavigationBar: !wishListController.isEditingMode.value
            ? const SizedBox.shrink()
            : BottomAppBar(
                height: kToolbarHeight,
                elevation: 0,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: wishListController.masterCheckboxState.value,
                          onChanged: (val) {
                            wishListController.toggleMasterCheckbox();
                          },
                          shape: const CircleBorder(),
                        ),
                        const Text(
                          "All",
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 15,
                            color: Color(0xFF673AB7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (wishListController.deletableItems.isEmpty) {
                          wishListController.showMyToast("Select an Item");
                        } else {
                          Get.dialog(
                            AlertDialog(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              titlePadding:
                                  const EdgeInsets.fromLTRB(16, 10, 16, 4),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(16, 2, 16, 10),
                              title: const Text(
                                "Delete Item(s)?",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              content: Text(
                                "Are you sure you want to remove this item(s) from your wishlist?",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black.withValues(alpha: 0.65),
                                ),
                              ),
                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                              actionsPadding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 10),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 32),
                                    //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        width: 1,
                                        color: Colors.black,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF673AB7),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 32),
                                    //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        width: 1,
                                        color: Color(0xFF673AB7),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    wishListController.isLoading.value = true;
                                    if (wishListController.isLoading.value ==
                                        true) {
                                      Get.dialog(
                                        const LoadingWidget(),
                                        barrierDismissible: false,
                                      );
                                    }
                                    if (wishListController
                                        .deletableItems.isEmpty) {
                                      wishListController
                                          .showMyToast("Select an Item");
                                    } else {
                                      var value = await wishListController
                                          .deleteFromWishlist();
                                      if (value == "success") {
                                        Get.close(2);
                                      }
                                      wishListController.isEditingMode.value =
                                          false;
                                    }
                                  },
                                  child: const Text(
                                    "Confirm",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            barrierDismissible: true,
                          );
                        }
                      },
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
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
