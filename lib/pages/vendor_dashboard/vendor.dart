import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/controllers/vendor_controller.dart';
import 'package:hair_main_street/pages/orders_stuff/payment_successful_page.dart';
import 'package:hair_main_street/pages/vendor_dashboard/shop_page.dart';
import 'package:hair_main_street/pages/vendor_dashboard/inventory.dart';
import 'package:hair_main_street/pages/vendor_dashboard/add_product.dart';
import 'package:hair_main_street/pages/vendor_dashboard/analytics_page.dart';
import 'package:hair_main_street/pages/vendor_dashboard/request_cancellation_page.dart';
import 'package:hair_main_street/pages/vendor_dashboard/vendor_orders.dart';
import 'package:hair_main_street/pages/vendor_dashboard/wallet.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/carbon.dart';
import 'package:iconify_flutter_plus/icons/material_symbols.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:recase/recase.dart';

class VendorPage extends StatefulWidget {
  const VendorPage({super.key});

  @override
  State<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  final UserController userController = Get.find<UserController>();

  final VendorController vendorController = Get.find<VendorController>();

  final CheckOutController checkOutController = Get.find<CheckOutController>();
  Map<String, num> totalSaleValue = {};

  @override
  void initState() {
    vendorController.vendorUID.value = userController.userState.value!.uid!;
    checkOutController.userUID.value = userController.userState.value!.uid!;
    vendorController.getVendorDetails(userController.userState.value!.uid!);
    vendorController.getVendorsProducts(userController.userState.value!.uid!);
    checkOutController.getSellerOrders(userController.userState.value!.uid!);

    super.initState();
  }

  String initialValue = "this week";

  @override
  Widget build(BuildContext context) {
    // print("totalSales: $totalSaleValue");
    //print(vendorController.vendorUID.value);
    List<String> vendorButtonsText = [
      "Shop Setup",
      "Inventory",
      "Add Product",
      "Orders",
      "Analytics",
      "Wallet",
      "Refunds/Cancellation Requests"
    ];

    // List<String> totalSalesValues = [
    //   "This Week",
    //   "Last Week",
    //   "This Month",
    //   "Older",
    // ];

    List? vl = [
      const ShopSetupPage(),
      const InventoryPage(),
      const AddproductPage(),
      const VendorOrdersPage(),
      const AnalyticsPage(),
      const WalletPage(),
      const RequestCancellationPage(),
    ];

    double screenWidth = Get.width;

    List<Widget> vendorButtonsIcons = [
      SvgPicture.asset(
        "assets/Icons/shop.svg",
        colorFilter: ColorFilter.mode(
          Colors.black,
          BlendMode.srcIn,
        ),
        width: 40,
        height: 40,
      ),
      const Iconify(
        MaterialSymbols.inventory_rounded,
        size: 40,
        color: Colors.black,
      ),
      const Iconify(
        MaterialSymbols.add_circle_outline_rounded,
        size: 40,
        color: Colors.black,
      ),
      SvgPicture.asset(
        "assets/Icons/clarity_list_line.svg",
        colorFilter: ColorFilter.mode(
          Colors.black,
          BlendMode.srcIn,
        ),
        width: 40,
        height: 40,
      ),
      const Iconify(
        Carbon.analytics,
        size: 40,
        color: Colors.black,
      ),
      SvgPicture.asset(
        "assets/Icons/ion_wallet.svg",
        colorFilter: ColorFilter.mode(
          Colors.black,
          BlendMode.srcIn,
        ),
        width: 40,
        height: 40,
      ),
    ];

    String formatCurrency(String numberString) {
      final number =
          double.tryParse(numberString) ?? 0.0; // Handle non-numeric input
      final formattedNumber =
          number.toStringAsFixed(2); // Format with 2 decimals

      // Split the number into integer and decimal parts
      final parts = formattedNumber.split('.');
      final intPart = parts[0];
      final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

      // Format the integer part with commas for every 3 digits
      final formattedIntPart = intPart.replaceAllMapped(
        RegExp(r'\d{1,3}(?=(\d{3})+(?!\d))'),
        (match) => '${match.group(0)},',
      );

      // Combine the formatted integer and decimal parts
      final formattedResult = formattedIntPart + decimalPart;

      return formattedResult;
    }

    return StreamBuilder(
      stream: DataBaseService()
          .getVendorDetails(userID: userController.userState.value!.uid!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Obx(
            () => vendorController.vendor.value!.secondVerification == false
                ? RequestProcessingPage(
                    thingBeingProcessed: 'Vendor',
                    getTo: () => Get.back(),
                  )
                : Scaffold(
                    appBar: AppBar(
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      leading: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Symbols.arrow_back_ios_new_rounded,
                            size: 24, color: Colors.black),
                      ),
                      title: const Text(
                        'Vendor Dashboard',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontFamily: 'Lato',
                        ),
                      ),
                      centerTitle: false,
                      // flexibleSpace: Container(
                      //   decoration: BoxDecoration(gradient: appBarGradient),
                      // ),
                      //backgroundColor: Colors.transparent,
                    ),
                    body: GetX<CheckOutController>(builder: (controller) {
                      int productSold = checkOutController.vendorOrderList
                          .where((test) => test.orderStatus == 'confirmed')
                          .length;

                      int orders = checkOutController.vendorOrderList.length;
                      return controller.vendorOrdersMap["Completed"] == null
                          ? const LoadingWidget()
                          : Builder(builder: (context) {
                              totalSaleValue =
                                  checkOutController.getTotalSales();
                              return SafeArea(
                                child: SingleChildScrollView(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                  //decoration: BoxDecoration(gradient: myGradient),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Total Sales",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Raleway',
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                "NGN${formatCurrency(totalSaleValue[initialValue].toString())}",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Lato',
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          PopupMenuButton<String>(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              side: const BorderSide(
                                                color: Color(0xFF673AB7),
                                                width: 0.3,
                                              ),
                                            ),
                                            initialValue: initialValue,
                                            color: Colors.white,
                                            elevation: 0,
                                            itemBuilder:
                                                (BuildContext context) {
                                              return <PopupMenuEntry<String>>[
                                                const PopupMenuItem<String>(
                                                  value: "this week",
                                                  child: Text(
                                                    'This Week',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black,
                                                      fontFamily: 'Lato',
                                                    ),
                                                  ),
                                                ),
                                                const PopupMenuItem<String>(
                                                  value: "last week",
                                                  child: Text(
                                                    'Last Week',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black,
                                                      fontFamily: 'Lato',
                                                    ),
                                                  ),
                                                ),
                                                const PopupMenuItem<String>(
                                                  value: "this month",
                                                  child: Text(
                                                    'This Month',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black,
                                                      fontFamily: 'Lato',
                                                    ),
                                                  ),
                                                ),
                                                const PopupMenuItem<String>(
                                                  value: 'older',
                                                  child: Text(
                                                    'Older',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black,
                                                      fontFamily: 'Lato',
                                                    ),
                                                  ),
                                                ),
                                              ];
                                            },
                                            onSelected: (String value) {
                                              setState(() {
                                                initialValue = value;
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: const Color(0xFF673AB7)
                                                    .withValues(alpha: 0.10),
                                              ),
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      6, 4, 6, 4),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    initialValue.titleCase,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF673AB7),
                                                      fontFamily: 'Raleway',
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 20,
                                                    color: Color(0xFF673AB7),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: screenWidth * 0.45,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: const Color(0xFF673AB7)
                                                  .withValues(alpha: 0.10),
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "$orders",
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'Lato',
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const Text(
                                                  "Orders",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Raleway',
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: screenWidth * 0.45,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: const Color(0xFFE91E63)
                                                  .withValues(alpha: 0.10),
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "$productSold",
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'Lato',
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const Text(
                                                  "Products sold",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Raleway',
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 24,
                                      ),
                                      MasonryGridView(
                                        shrinkWrap: true,
                                        crossAxisSpacing: 16,
                                        // mainAxisExtent: 40,
                                        mainAxisSpacing: 16,
                                        gridDelegate:
                                            const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                        ),
                                        children: List.generate(
                                          vendorButtonsText.length,
                                          (index) => DashboardButton(
                                            icon: vendorButtonsIcons[index],
                                            page: vl[index],
                                            text: vendorButtonsText[index],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                    }),
                  ),
          );
        } else {
          return Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(
                //backgroundColor: Colors.white,
                color: Color(0xFF392F5A),
                strokeWidth: 4,
              ),
            ),
          );
        }
      },
    );
  }
}

class DashboardButton extends StatelessWidget {
  final Widget? page;
  final String? text;
  final Widget? icon;
  const DashboardButton({this.icon, this.page, this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.45),
            width: 1.5,
          ),
        ),
      ),
      onPressed: () => Get.to(() => page!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const Divider(
            height: 20,
            color: Colors.black,
            thickness: 1,
          ),
          Text(
            text!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black87,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
