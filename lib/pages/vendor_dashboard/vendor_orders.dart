import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/blank_page.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:hair_main_street/widgets/cards.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:material_symbols_icons/symbols.dart';

class VendorOrdersPage extends StatefulWidget {
  const VendorOrdersPage({super.key});

  @override
  State<VendorOrdersPage> createState() => _VendorOrdersPageState();
}

class _VendorOrdersPageState extends State<VendorOrdersPage>
    with TickerProviderStateMixin {
  UserController userController = Get.find<UserController>();

  CheckOutController checkOutController = Get.find<CheckOutController>();
  bool showContent = false;

  @override
  void initState() {
    super.initState();
    checkOutController.getSellerOrders(userController.userState.value!.uid!);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showContent = true;
      });
    });
    // checkOutController
    //     .filterTheBuyerOrderList(checkOutController.buyerOrderList);
  }

  @override
  Widget build(BuildContext context) {
    List categories = [
      "All",
      "Active",
      "Expired",
      "Completed",
      "Cancelled",
    ];
    TabController tabController =
        TabController(length: categories.length, vsync: this);
    //s checkOutController.userUID.value = userController.userState.value!.uid!;
    debugPrint("debugPrint:${checkOutController.userUID.value}");
    // num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    checkOutController.getSellerOrders(userController.userState.value!.uid!);
    // debugPrint(
    //     "value: ${checkOutController.getBuyerOrders(checkOutController.userUID.value).first}");
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
          title: const Text(
            'Orders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: 'Lato',
            ),
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight / 2),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TabBar(
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  controller: tabController,
                  indicatorWeight: 5,
                  unselectedLabelColor: Colors.black,
                  labelColor: const Color(0xFF673AB7),
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  indicatorColor: const Color(0xFF673AB7),
                  tabs: categories
                      .map((e) => Text(
                            e,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            // style: const TextStyle(
                            //   fontSize: 15,
                            //   fontFamily: 'Raleway',
                            //   fontWeight: FontWeight.w400,
                            //   //color: Color(0xFF673AB7),
                            // ),
                          ))
                      .toList()),
            ),
          ),
        ),
        body: SafeArea(
          child: StreamBuilder(
            stream: DataBaseService()
                .getVendorsOrders(userController.userState.value!.uid!),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (!showContent) {
                  return const SizedBox();
                }
                return checkOutController.vendorOrderList.isEmpty
                    ? BlankPage(
                        text: "You have no Orders yet",
                        textStyle: const TextStyle(
                          fontSize: 40,
                          color: Colors.black,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                        ),
                        pageIcon: SvgPicture.asset(
                            "assets/Icons/solar--cart-cross-bold.svg",
                            colorFilter: ColorFilter.mode(
                              AppColors.main.withValues(alpha: 0.65),
                              BlendMode.srcIn,
                            ),
                            height: 40,
                            width: 40),
                      )
                    : TabBarView(
                        controller: tabController,
                        children: [
                          _buildTabContent("All"),
                          _buildTabContent("Active"),
                          _buildTabContent("Expired"),
                          _buildTabContent("Completed"),
                          _buildTabContent("Cancelled"),
                        ],
                      );
              } else {
                return const LoadingWidget();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(String tabName) {
    return Obx(() {
      final orders = checkOutController.vendorOrdersMap[tabName]!;
      return orders.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                itemBuilder: (context, index) =>
                    VendorOrderCard(mapKey: tabName, index: index),
                itemCount: orders.length,
              ),
            )
          : Center(
              child: Text(
                "No $tabName orders yet",
                style: const TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
    });
  }
}
