import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
// import 'package:hair_main_street/models/order_model.dart';
// import 'package:hair_main_street/pages/menu/order_detail.dart';

class PaymentSuccessfulPage extends StatelessWidget {
  const PaymentSuccessfulPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {},
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Color(0xFF673AB7).withValues(alpha: 0.40),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    height: 175,
                    width: 175,
                    decoration: BoxDecoration(
                      color: Color(0xFF673AB7),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      "assets/Icons/charm-tick.svg",
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      height: 75,
                      width: 75,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Payment Successful",
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: BottomAppBar(
            elevation: 0,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            height: kToolbarHeight * 1.2,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  Get.offAllNamed("/");
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InstallmentPaymentSuccessfulPage extends StatelessWidget {
  final String? orderID;
  final int installmentRemaining;
  const InstallmentPaymentSuccessfulPage({
    super.key,
    required this.installmentRemaining,
    required this.orderID,
  });

  @override
  Widget build(BuildContext context) {
    CheckOutController checkOutController = Get.find<CheckOutController>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // await checkOutController.getSingleOrder(orderID!);
        // //Get.close(2);
        // Get.close(3);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Color(0xFF673AB7).withValues(alpha: 0.40),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    height: 175,
                    width: 175,
                    decoration: BoxDecoration(
                      color: Color(0xFF673AB7),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      "assets/Icons/charm-tick.svg",
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      height: 75,
                      width: 75,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              installmentRemaining == 0
                  ? Column(
                      children: [
                        const Text(
                          "Payment Successful",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text(
                          "You have completed the payment of all your installments",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text(
                          "Payment Successful",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          "You have $installmentRemaining installment payment left to complete",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: BottomAppBar(
            elevation: 0,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            height: kToolbarHeight,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  await checkOutController.getSingleOrder(orderID!);
                  Get.close(3);
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductCreationSuccessfulPage extends StatelessWidget {
  const ProductCreationSuccessfulPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Color(0xFF673AB7).withValues(alpha: 0.40),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    height: 175,
                    width: 175,
                    decoration: BoxDecoration(
                      color: Color(0xFF673AB7),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      "assets/Icons/charm-tick.svg",
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      height: 75,
                      width: 75,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Congratulations",
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              const Text(
                "Product creation was successful",
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {},
                  child: const Text(
                    "Add Another Product",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              InkWell(
                onTap: () {},
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Done",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      // bottomNavigationBar: SafeArea(
      //   child: BottomAppBar(
      //     elevation: 0,
      //     color: Colors.white,
      //     padding: const EdgeInsets.symmetric(horizontal: 12),
      //     height: kToolbarHeight,
      //     child: SizedBox(
      //       width: double.infinity,
      //       child: ElevatedButton(
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: const Color(0xFF673AB7),
      //           padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(10),
      //           ),
      //         ),
      //         onPressed: () async {},
      //         child: const Text(
      //           "Continue",
      //           style: TextStyle(
      //             fontFamily: 'Lato',
      //             fontSize: 16,
      //             color: Colors.white,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}

class WithdrawalSuccessPage extends StatelessWidget {
  const WithdrawalSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Color(0xFF673AB7).withValues(alpha: 0.40),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    height: 175,
                    width: 175,
                    decoration: BoxDecoration(
                      color: Color(0xFF673AB7),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      "assets/Icons/charm-tick.svg",
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      height: 75,
                      width: 75,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Successful",
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              const Text(
                "Your withdrawal request was submitted successfully",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              Text(
                "Your request will be reviewed within 24hours and you should\nreceive an email notification once this is done.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          height: kToolbarHeight * 1.2,
          elevation: 0,
          color: Colors.white,
          child: SizedBox(
            width: double.maxFinite,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Get.close(1);
              },
              child: const Text(
                "Done",
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RequestProcessingPage extends StatelessWidget {
  final String? thingBeingProcessed;
  final VoidCallback? getTo;
  const RequestProcessingPage({
    this.thingBeingProcessed,
    this.getTo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 40,
        backgroundColor: Colors.white,
        leading: InkWell(
          onTap: () => Get.back(),
          radius: 12,
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black,
          ),
        ),
        scrolledUnderElevation: 0,
        title: Text(
          '$thingBeingProcessed Request',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            fontFamily: 'Lato',
          ),
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                    color: const Color(0xFF673AB7).withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  "Your Request is being processed",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              const Expanded(
                child: SizedBox(
                  height: 30,
                  width: double.infinity,
                  child: Text(
                    "You'll receive a notification once your request has been processed",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          elevation: 0,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          height: kToolbarHeight,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: getTo,
              child: const Text(
                "Continue",
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
