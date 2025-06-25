import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/referral_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/widgets/cards.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';

class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context) {
    UserController userController = Get.find<UserController>();
    ReferralController referralController = Get.find<ReferralController>();
    var myReferrals = referralController.myReferrals;
    var currentUser = userController.userState.value;
    referralController.myRewardPoints
        .bindStream(referralController.getRewardPoints());
    String message =
        "Hello there, I am on Hair Main Street, Use my referral link to register and enjoy awesome products:\n${currentUser!.referralLink}";
    //debugPrint(currentUser.referralLink);
    num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    Text? referralText = Text(
      "${currentUser.referralLink}",
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      maxLines: 3,
      overflow: TextOverflow.clip,
    );
    // Text? referralCode = Text(
    //   "${currentUser.referralCode}",
    //   style: const TextStyle(
    //     color: Colors.black,
    //     fontSize: 16,
    //   ),
    //   maxLines: 3,
    //   overflow: TextOverflow.clip,
    // );
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Symbols.arrow_back_ios_new_rounded,
                size: 24, color: Colors.black),
          ),
          title: const Text(
            'Referral',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: "Lato",
              color: Colors.black,
            ),
          ),
          elevation: 0,
          centerTitle: true,
          // flexibleSpace: Container(
          //   decoration: BoxDecoration(gradient: appBarGradient),
          // ),
          //backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            children: [
              const HeaderText(
                text: "Invite Your Friends",
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 1,
                      spreadRadius: 0,
                      color: const Color(0xFF673AB7).withValues(alpha: 0.10),
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Text(
                  "On Hair Main Street, you get 10 reward points by using your referral link to invite your friends.\nThese can be accumulated to be used to make purchases.\nFeature coming soon...",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              const HeaderText(
                text: "Referral Link",
              ),
              const SizedBox(
                height: 4,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 1,
                      spreadRadius: 0,
                      color: const Color(0xFF673AB7).withValues(alpha: 0.10),
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  children: [
                    referralText,
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextButton.icon(
                            icon: const Icon(
                              Icons.copy,
                              size: 24,
                              color: Colors.white,
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF673AB7),
                              padding: const EdgeInsets.all(6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  width: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onPressed: () {
                              FlutterClipboard.copy(referralText.data!);
                              Get.snackbar(
                                "Link Copied",
                                "Successful",
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(
                                    seconds: 1, milliseconds: 400),
                                forwardAnimationCurve: Curves.decelerate,
                                reverseAnimationCurve: Curves.easeOut,
                                backgroundColor:
                                    const Color.fromARGB(255, 200, 242, 237),
                                margin: EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  bottom: screenHeight * 0.16,
                                ),
                              );
                            },
                            label: const Text(
                              "Copy",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          flex: 1,
                          child: TextButton.icon(
                            icon: const Icon(
                              Icons.share,
                              size: 24,
                              color: Colors.white,
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF673AB7),
                              padding: const EdgeInsets.all(6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  width: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onPressed: () {
                              Share.share(message,
                                  subject: "Hair Main Street Referral Invite");
                            },
                            label: const Text(
                              "Share",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.grey[200],
              //     borderRadius: BorderRadius.circular(12),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Color(0xFF000000),
              //         blurStyle: BlurStyle.normal,
              //         offset: Offset.fromDirection(-4.0),
              //         blurRadius: 4,
              //       ),
              //     ],
              //   ),
              //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Expanded(
              //         flex: 3,
              //         child: referralCode,
              //       ),
              //       Expanded(
              //         flex: 1,
              //         child: TextButton(
              //           style: TextButton.styleFrom(
              //             backgroundColor: Colors.black,
              //             padding: EdgeInsets.all(4),
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(12),
              //               side: const BorderSide(
              //                 width: 1.5,
              //                 color: Colors.black,
              //               ),
              //             ),
              //           ),
              //           onPressed: () {
              //             FlutterClipboard.copy(referralText.data!);
              //             Get.snackbar(
              //               "Code Copied",
              //               "Successful",
              //               snackPosition: SnackPosition.BOTTOM,
              //               duration: Duration(seconds: 1, milliseconds: 400),
              //               forwardAnimationCurve: Curves.decelerate,
              //               reverseAnimationCurve: Curves.easeOut,
              //               backgroundColor: Color.fromARGB(255, 200, 242, 237),
              //               margin: EdgeInsets.only(
              //                 left: 12,
              //                 right: 12,
              //                 bottom: screenHeight * 0.16,
              //               ),
              //             );
              //           },
              //           child: const Text(
              //             "Copy",
              //             style: TextStyle(
              //               color: Colors.white,
              //               fontSize: 16,
              //             ),
              //             maxLines: 2,
              //           ),
              //         ),
              //       )
              //     ],
              //   ),
              // ),
              // const SizedBox(
              //   height: 12,
              // ),
              const HeaderText(
                text: "Statistics",
              ),
              const SizedBox(
                height: 8,
              ),
              ReferralCard(
                title: "My Referrals",
                text: "${myReferrals.length}",
              ),
              const SizedBox(
                height: 12,
              ),
              ReferralCard(
                title: "Reward Points",
                text: "${referralController.myRewardPoints.value}",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderText extends StatelessWidget {
  final String? text;
  const HeaderText({
    this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
      ),
      child: Text(
        text!,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          fontFamily: "Raleway",
        ),
      ),
    );
  }
}
