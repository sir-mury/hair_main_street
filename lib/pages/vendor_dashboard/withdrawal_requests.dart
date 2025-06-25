import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/blank_page.dart';
import 'package:hair_main_street/controllers/wallet_controller.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class WithdrawalRequestsPage extends StatelessWidget {
  final String? userID;
  const WithdrawalRequestsPage({super.key, this.userID});

  @override
  Widget build(BuildContext context) {
    WalletController walletController = Get.find<WalletController>();
    walletController.withdrawalRequests
        .bindStream(walletController.getWithdrawalRequests(userID!));

    String resolveTimestamp(Timestamp timestamp) {
      DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
      var newDate = DateFormat("dd-MM-yyyy:HH:MM").format(dateTime);

      return newDate;
    }

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

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Symbols.arrow_back_ios_new_rounded,
              size: 20, color: Colors.black),
        ),
        title: const Text(
          'Withdrawal Requests',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF673AB7),
            fontFamily: 'Lato',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

        //backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder(
        stream: walletController.getWithdrawalRequests(userID!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null ||
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          } else {
            // print(snapshot.data);
            if (snapshot.data!.isEmpty) {
              return BlankPage(
                text: "Your have no withdrawal Requests",
                pageIcon: const Icon(
                  Icons.money_off_csred_rounded,
                  size: 40,
                  color: Colors.black,
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: walletController.withdrawalRequests.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.shade2,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 1,
                        spreadRadius: 0,
                        color: AppColors.shade6,
                        offset: const Offset(0, 1),
                      )
                    ],
                  ),
                  child: Column(
                    //crossAxisAlignment:,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Withdrawal Amount:",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "NGN${formatCurrency(walletController.withdrawalRequests[index].withdrawalAmount.toString())}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Account Name:",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${walletController.withdrawalRequests[index].accountName}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Account Number:",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${walletController.withdrawalRequests[index].accountNumber}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Bank Name:",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${walletController.withdrawalRequests[index].bankName}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Status:",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${walletController.withdrawalRequests[index].status}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: walletController
                                          .withdrawalRequests[index].status!
                                          .toLowerCase() ==
                                      "approved"
                                  ? AppColors.done
                                  : AppColors.pending,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Timestamp:",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            resolveTimestamp(walletController
                                .withdrawalRequests[index].createdAt!),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
