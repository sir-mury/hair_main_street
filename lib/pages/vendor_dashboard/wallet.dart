import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/controllers/vendor_controller.dart';
import 'package:hair_main_street/controllers/wallet_controller.dart';
import 'package:hair_main_street/pages/vendor_dashboard/withdrawal_page.dart';
import 'package:hair_main_street/pages/vendor_dashboard/withdrawal_requests.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/mingcute.dart';
import 'package:material_symbols_icons/symbols.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  UserController userController = Get.find<UserController>();
  WalletController walletController = Get.put(WalletController());
  VendorController vendorController = Get.find<VendorController>();

  @override
  Widget build(BuildContext context) {
    //print(vendorAccountDetails);

    walletController.id.value = userController.userState.value!.uid!;
    String? currentUserID = userController.userState.value!.uid!;
    // num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;

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

    // void showBottomSheet(BuildContext context) {
    //   showModalBottomSheet<void>(
    //     context: context,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(12),
    //       side: const BorderSide(
    //         width: 2,
    //         color: Colors.black,
    //       ),
    //     ),
    //     builder: (BuildContext context) {
    //       return ListView.builder(
    //         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    //         //shrinkWrap: true,
    //         itemCount: walletController.transactions.length,
    //         itemBuilder: (context, index) => Container(
    //           margin: const EdgeInsets.symmetric(vertical: 4),
    //           child: ListTile(
    //             style: ListTileStyle.drawer,
    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(12),
    //               side: const BorderSide(
    //                 width: 2,
    //                 color: Colors.black,
    //               ),
    //             ),
    //             contentPadding:
    //                 const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    //             title: Text(
    //               "${walletController.transactions[index].description}",
    //               style: const TextStyle(
    //                 color: Colors.black,
    //                 fontWeight: FontWeight.w800,
    //                 fontSize: 24,
    //               ),
    //             ),
    //             leading: walletController.transactions[index].type == 'credit'
    //                 ? Icon(
    //                     Icons.keyboard_double_arrow_down_rounded,
    //                     color: Colors.green[800],
    //                     size: 28,
    //                   )
    //                 : Icon(
    //                     Icons.keyboard_double_arrow_up_rounded,
    //                     color: Colors.red[800],
    //                     size: 28,
    //                   ),
    //             subtitle: Text(
    //               "${walletController.transactions[index].transactionId}",
    //               style: const TextStyle(
    //                 color: Colors.black,
    //                 fontWeight: FontWeight.w500,
    //                 fontSize: 16,
    //               ),
    //             ),
    //             trailing: Text(
    //               "₦${walletController.transactions[index].amount}",
    //               style: const TextStyle(
    //                 color: Colors.black,
    //                 fontWeight: FontWeight.w500,
    //                 fontSize: 16,
    //               ),
    //             ),
    //           ),
    //         ),
    //       );
    //     },
    //   );
    // }

    return StreamBuilder(
        stream: walletController.getWalletBalance(currentUserID),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white,
              child: const LoadingWidget(),
            );
          }
          return Scaffold(
            appBar: AppBar(
              //toolbarHeight: 100,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Symbols.arrow_back_ios_new_rounded,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: const Text(
                'Wallet',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Lato',
                  color: Color(0xFF673AB7),
                ),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(260),
                child: Container(
                  //height: 1000,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color:
                              const Color(0xFF673AB7).withValues(alpha: 0.30),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Balance",
                                    style: TextStyle(
                                      fontFamily: 'Ralaway',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Colors.black.withValues(alpha: 0.75),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "NGN${formatCurrency(walletController.wallet.value.balance.toString())}",
                                    style: const TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF673AB7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 100,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 1,
                              color: Colors.black.withValues(alpha: 0.75),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Available Balance",
                                    style: TextStyle(
                                      fontFamily: 'Ralaway',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Colors.black.withValues(alpha: 0.75),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "NGN${formatCurrency(walletController.wallet.value.withdrawableBalance.toString())}",
                                    style: const TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF673AB7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      vendorController.vendor.value!.secondVerification == true
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                // backgroundColor: Colors.white,
                                backgroundColor: const Color(0xFF673AB7)
                                    .withValues(alpha: 0.10),
                                padding: const EdgeInsets.all(6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: BorderSide(
                                    color: Colors.black.withValues(alpha: 0.10),
                                    width: 0.4,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Get.to(() => const WithdrawalPage());
                              },
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Make Withdrawal",
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF673AB7),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color(0xFF673AB7),
                                    size: 18,
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.30),
                                  width: 0.4,
                                ),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Text(
                                "Cannot make withdrawal until Verified",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Lato',
                                  color: Color(0xFF673AB7),
                                ),
                              ),
                            ),
                      const SizedBox(
                        height: 4,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          // backgroundColor: Colors.white,
                          backgroundColor:
                              const Color(0xFF673AB7).withValues(alpha: 0.10),
                          padding: const EdgeInsets.all(6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                              color: Colors.black.withValues(alpha: 0.10),
                              width: 0.4,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Get.to(
                            () => WithdrawalRequestsPage(
                              userID: vendorController.vendor.value!.userID,
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "See Withdrawal Requests",
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF673AB7),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFF673AB7),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      const Text(
                        "Transaction History",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: StreamBuilder(
                stream: walletController.getTransaction(currentUserID),
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      color: Colors.white,
                      child: const LoadingWidget(),
                    );
                  }
                  walletController
                      .getTransactionsByDate(walletController.transactions);
                  return Obx(
                    () => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const SizedBox(
                          //   height: 12,
                          // ),
                          if (walletController.transactions.isEmpty)
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Iconify(
                                  Mingcute.transfer_line,
                                  size: 78,
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  'You have no transactions yet',
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  'Transactions will show here when orders come in',
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: walletController
                                  .filteredTransactionMap.length,
                              itemBuilder: (context, index1) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Visibility(
                                    visible: walletController
                                        .filteredTransactionMap.values
                                        .elementAt(index1)
                                        .isNotEmpty,
                                    child: Text(
                                      walletController
                                          .filteredTransactionMap.keys
                                          .elementAt(index1),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'Raleway',
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black
                                            .withValues(alpha: 0.90),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  ...List.generate(
                                    walletController
                                        .filteredTransactionMap.values
                                        .elementAt(index1)
                                        .length,
                                    (index) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      child: ListTile(
                                        leading: Container(
                                          width: 35,
                                          height: 35,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF673AB7)
                                                .withValues(alpha: 0.20),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: walletController
                                                      .filteredTransactionMap
                                                      .values
                                                      .elementAt(index1)[index]
                                                      .type ==
                                                  'credit'
                                              ? const Icon(
                                                  Icons.arrow_upward_rounded,
                                                  size: 16,
                                                  color: Color(0xFF673AB7),
                                                )
                                              : const Icon(
                                                  Icons.arrow_downward_rounded,
                                                  size: 16,
                                                  color: Color(0xFF673AB7),
                                                ),
                                        ),
                                        titleAlignment:
                                            ListTileTitleAlignment.center,
                                        title: Text(
                                          walletController
                                                      .filteredTransactionMap
                                                      .values
                                                      .elementAt(index1)[index]
                                                      .type ==
                                                  'credit'
                                              ? "You just received a payment of"
                                              : "You just made a withdrawal of",
                                          style: const TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            walletController
                                                        .filteredTransactionMap
                                                        .values
                                                        .elementAt(
                                                            index1)[index]
                                                        .type ==
                                                    'credit'
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: const Color(
                                                              0xFF673AB7)
                                                          .withValues(
                                                              alpha: 0.10),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    child: const Text(
                                                      "Credit",
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        fontFamily: 'Raleway',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFF673AB7),
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: const Color(
                                                              0xFFEA4335)
                                                          .withValues(
                                                              alpha: 0.10),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    child: const Text(
                                                      "Debit",
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        fontFamily: 'Raleway',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFFEA4335),
                                                      ),
                                                    ),
                                                  ),
                                            walletController
                                                        .filteredTransactionMap
                                                        .values
                                                        .elementAt(
                                                            index1)[index]
                                                        .type ==
                                                    'credit'
                                                ? Text(
                                                    "+NGN${formatCurrency(walletController.transactions[index].amount.toString())}",
                                                    style: const TextStyle(
                                                      fontFamily: 'Lato',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF34A853),
                                                    ),
                                                    maxLines: 2,
                                                  )
                                                : Text(
                                                    "-NGN${formatCurrency(walletController.transactions[index].amount.toString())}",
                                                    style: const TextStyle(
                                                      fontFamily: 'Lato',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
          );
        });
  }
}


// Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 4),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 35,
//                                     height: 35,
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       color: const Color(0xFF673AB7)
//                                           .withValues(alpha: 0.20),
//                                     ),
//                                     padding: const EdgeInsets.all(8),
//                                     child: walletController
//                                                 .filteredTransactionMap.values
//                                                 .elementAt(index1)[index]
//                                                 .type ==
//                                             'credit'
//                                         ? const Icon(
//                                             Icons.arrow_upward_rounded,
//                                             size: 16,
//                                             color: Color(0xFF673AB7),
//                                           )
//                                         : const Icon(
//                                             Icons.arrow_downward_rounded,
//                                             size: 16,
//                                             color: Color(0xFF673AB7),
//                                           ),
//                                   ),
//                                   const SizedBox(
//                                     width: 6,
//                                   ),
//                                   Text(
//                                     walletController
//                                                 .filteredTransactionMap.values
//                                                 .elementAt(index1)[index]
//                                                 .type ==
//                                             'credit'
//                                         ? "You just received a payment of"
//                                         : "You just made a withdrawal of",
//                                     style: const TextStyle(
//                                       fontFamily: 'Lato',
//                                       fontSize: 17,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     width: 4,
//                                   ),
//                                   Expanded(
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         walletController.filteredTransactionMap
//                                                     .values
//                                                     .elementAt(index1)[index]
//                                                     .type ==
//                                                 'credit'
//                                             ? Container(
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(5),
//                                                   color: const Color(0xFF673AB7)
//                                                       .withValues(alpha: 0.10),
//                                                 ),
//                                                 padding:
//                                                     const EdgeInsets.all(6),
//                                                 child: const Text(
//                                                   "Credit",
//                                                   style: TextStyle(
//                                                     fontSize: 9,
//                                                     fontFamily: 'Raleway',
//                                                     fontWeight: FontWeight.w600,
//                                                     color: Color(0xFF673AB7),
//                                                   ),
//                                                 ),
//                                               )
//                                             : Container(
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(5),
//                                                   color: const Color(0xFFEA4335)
//                                                       .withValues(alpha: 0.10),
//                                                 ),
//                                                 padding:
//                                                     const EdgeInsets.all(6),
//                                                 child: const Text(
//                                                   "Debit",
//                                                   style: TextStyle(
//                                                     fontSize: 9,
//                                                     fontFamily: 'Raleway',
//                                                     fontWeight: FontWeight.w600,
//                                                     color: Color(0xFFEA4335),
//                                                   ),
//                                                 ),
//                                               ),
//                                         walletController.filteredTransactionMap
//                                                     .values
//                                                     .elementAt(index1)[index]
//                                                     .type ==
//                                                 'credit'
//                                             ? Text(
//                                                 "+${formatCurrency(walletController.transactions[index].amount.toString())}",
//                                                 style: const TextStyle(
//                                                   fontFamily: 'Lato',
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w600,
//                                                   color: Color(0xFF34A853),
//                                                 ),
//                                               )
//                                             : Text(
//                                                 "-${formatCurrency(walletController.transactions[index].amount.toString())}",
//                                                 style: const TextStyle(
//                                                   fontFamily: 'Lato',
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w600,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                       ],
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),