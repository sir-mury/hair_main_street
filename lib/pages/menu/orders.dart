import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/blank_page.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/widgets/cards.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:material_symbols_icons/symbols.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  CheckOutController checkOutController = Get.find<CheckOutController>();

  UserController userController = Get.find<UserController>();
  bool showContent = false;

  @override
  void initState() {
    super.initState();
    checkOutController.getBuyerOrders(userController.userState.value!.uid!);
    Future.delayed(const Duration(milliseconds: 800), () {
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
      "Once",
      "Installment",
      "Confirmed",
      "Expired",
      "Cancelled",
    ];
    TabController tabController =
        TabController(length: categories.length, vsync: this);
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
          title: const Text(
            'Orders',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              fontFamily: 'Lato',
            ),
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight / 2),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TabBar(
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  controller: tabController,
                  indicatorWeight: 5,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF673AB7),
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  indicatorColor: const Color(0xFF673AB7),
                  tabs: categories
                      .map(
                        (e) => Text(
                          e,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      )
                      .toList()),
            ),
          ),
          // flexibleSpace: Container(
          //   decoration: BoxDecoration(gradient: appBarGradient),
          // ),
          //backgroundColor: Colors.transparent,
        ),
        body: StreamBuilder(
          stream: DataBaseService()
              .getBuyerOrdersStream(userController.userState.value!.uid!),
          builder: (context, snapshot) {
            // print(snapshot.data);
            if (snapshot.hasData) {
              // if (!showContent) {
              //   return const SizedBox(); // Return an empty SizedBox if content should not be displayed yet
              // }
              return checkOutController.buyerOrderList.isEmpty
                  ? BlankPage(
                      text: "No Orders Currently",
                      textStyle: const TextStyle(
                        fontSize: 40,
                        color: Colors.black,
                      ),
                      pageIcon: const Icon(
                        Icons.do_disturb_alt_rounded,
                        color: Colors.black,
                        size: 40,
                      ),
                    )
                  : TabBarView(
                      controller: tabController,
                      children: [
                        _buildTabContent("All"),
                        _buildTabContent("Once"),
                        _buildTabContent("Installment"),
                        _buildTabContent("Confirmed"),
                        _buildTabContent("Expired"),
                        _buildTabContent("Cancelled"),
                      ],
                    );
            } else {
              return const LoadingWidget();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTabContent(String tabName) {
    return Obx(() {
      final orders = checkOutController.buyerOrderMap[tabName]!;
      return orders.isNotEmpty
          ? RefreshIndicator.adaptive(
              color: Colors.white,
              backgroundColor: Color(0xFF673AB7),
              onRefresh: () {
                return Future.delayed(
                  Duration(milliseconds: 900),
                );
              },
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemBuilder: (context, index) =>
                    OrderCard(mapKey: tabName, index: index),
                itemCount: orders.length,
              ),
            )
          : Center(
              child: Text(
                "No $tabName Orders Yet",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontFamily: 'Lato',
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
    });
  }
}
