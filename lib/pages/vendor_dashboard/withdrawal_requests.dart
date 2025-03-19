import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/blankPage.dart';
import 'package:hair_main_street/controllers/walletController.dart';
import 'package:material_symbols_icons/symbols.dart';

class WithdrawalRequestsPage extends StatelessWidget {
  String? userID;
  WithdrawalRequestsPage({super.key, this.userID});

  WalletController walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    walletController.withdrawalRequests
        .bindStream(walletController.getWithdrawalRequests(userID!));

    DateTime resolveTimestampWithoutAdding(Timestamp timestamp) {
      DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime

      // Add days to the DateTime
      //DateTime newDateTime = dateTime.add(Duration(days: daysToAdd));

      return dateTime;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Symbols.arrow_back_ios_new_rounded,
              size: 24, color: Colors.black),
        ),
        title: const Text(
          'Withdrawal Requests',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        centerTitle: true,

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
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
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
                            "${walletController.withdrawalRequests[index].withdrawalAmount}",
                            style: const TextStyle(
                              fontSize: 16,
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
                            style: const TextStyle(
                              fontSize: 16,
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
                            "${resolveTimestampWithoutAdding(walletController.withdrawalRequests[index].createdAt!)}",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
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
