import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/pages/orders_stuff/buyer_payment.dart';
import 'package:material_symbols_icons/symbols.dart';

class ConfirmOrderPage extends StatefulWidget {
  const ConfirmOrderPage({super.key});

  @override
  State<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  bool checkValue = true;
  @override
  Widget build(BuildContext context) {
    // num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    Gradient myGradient = const LinearGradient(
      colors: [
        Color.fromARGB(255, 255, 224, 139),
        Color.fromARGB(255, 200, 242, 237)
      ],
      stops: [
        0.05,
        0.99,
      ],
      end: Alignment.topCenter,
      begin: Alignment.bottomCenter,
      //transform: GradientRotation(math.pi / 4),
    );
    Gradient appBarGradient = const LinearGradient(
      colors: [
        Color.fromARGB(255, 200, 242, 237),
        Color.fromARGB(255, 255, 224, 139)
      ],
      stops: [
        0.05,
        0.99,
      ],
      end: Alignment.topCenter,
      begin: Alignment.bottomCenter,
      //transform: GradientRotation(math.pi / 4),
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Symbols.arrow_back_ios_new_rounded,
              size: 24, color: Colors.black),
        ),
        title: const Text(
          'Confirm Order',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(
              0xFFFF8811,
            ),
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appBarGradient),
        ),
        //backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
        decoration: BoxDecoration(gradient: myGradient),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: 2,
                  color: const Color(0xFF392F5A),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000000),
                    blurStyle: BlurStyle.normal,
                    offset: Offset.fromDirection(-4.0),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Shipping To:",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "No 224 Darmanawa Gabas Kano",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Full name: ",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Muhammad Murtala Abdullahi",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Delivery Date:",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "30/09/2023",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 8,
                    color: Colors.black,
                    thickness: 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        "Product Name:",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )),
                      Expanded(
                          child: Text(
                        "Price",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        "Delivery Fee:",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )),
                      Expanded(
                          child: Text(
                        "Price",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Tax:",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Price",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        "Order Total:",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )),
                      Expanded(
                          child: Text(
                        "Price",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: checkValue,
                  onChanged: (newV) {
                    setState(() {
                      checkValue = newV!;
                      // debugPrint("$checkValue");
                      // debugPrint("$newV");
                    });
                  },
                ),
                const Text(
                  "I agree with the",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "terms",
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                ),
                const Text(
                  "and",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "conditions",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            TextButton(
              style: TextButton.styleFrom(
                //alignment: Alignment.centerLeft,
                backgroundColor: const Color(0xFF392F5A),
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
              ),
              onPressed: () {
                Get.to(() => const BuyerPaymentPage());
              },
              child: const Text(
                "Proceed",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
