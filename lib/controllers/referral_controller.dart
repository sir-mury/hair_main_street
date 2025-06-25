import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/services/database.dart';

class ReferralController extends GetxController {
  var myReferrals = [].obs;
  var myRewardPoints = 0.obs;

  // @override
  // onInit() {
  //   //myRewardPoints.bindStream(getRewardPoints());
  //   myReferrals.bindStream(getReferrals());
  //   super.onInit();
  // }

  getReferrals() {
    myReferrals.bindStream(DataBaseService().getReferrals());
  }

  getRewardPoints() {
    return DataBaseService().getRewardPoints();
  }

  handleReferrals(String referralCode, String referredID) async {
    var result = await DataBaseService().confirmRefCodeAndRewardRef(
        referralCode: referralCode, referredID: referredID);
    if (result == "success") {
      debugPrint("Success");
    }
  }
}
