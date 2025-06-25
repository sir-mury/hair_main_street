import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:string_validator/string_validator.dart' as validator;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  GlobalKey<FormState>? formKey = GlobalKey();
  UserController userController = Get.find<UserController>();

  TextEditingController? emailController = TextEditingController();
  String email = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Symbols.arrow_back_ios_new_rounded,
            size: 24,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Forgotten Password',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lato',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: const Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    text:
                        "You can request a password reset below. We will send a security code to the email address, make sure it is correct",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w500,
                      leadingDistribution: TextLeadingDistribution.proportional,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Form(
                key: formKey,
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextInputWidget(
                      textInputType: TextInputType.emailAddress,
                      controller: emailController,
                      autofillHints: [AutofillHints.email],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      labelText: "Email address",
                      hintText: "Enter the email you used to sign in",
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Please enter an email address";
                        } else if (!validator.isEmail(val)) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          if (val!.isNotEmpty) {
                            emailController!.text = val;
                            email = emailController!.text;
                          } else {}
                        });
                      },
                    ),
                    SizedBox(
                      height: screenHeight * .02,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              bool? validate =
                                  formKey!.currentState!.validate();
                              if (validate) {
                                userController.isLoading.value = true;
                                if (userController.isLoading.isTrue) {
                                  Get.dialog(LoadingWidget());
                                }
                                formKey!.currentState!.save();
                                await userController
                                    .sendResetPasswordEmail(email);
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              backgroundColor: const Color(0xFF673AB7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Send Reset Password Email",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
