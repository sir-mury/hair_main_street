import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:string_validator/string_validator.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? code;
  const ResetPasswordPage({this.code, super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  GlobalKey<FormState>? formKey = GlobalKey();
  UserController userController = Get.find<UserController>();

  TextEditingController? passwordController = TextEditingController();
  TextEditingController? confirmPasswordController = TextEditingController();
  String? newPassword;

  bool hasUppercaseLetter(String value) {
    RegExp regex = RegExp(r'[A-Z]');
    return regex.hasMatch(value);
  }

  bool hasLowercaseLetter(String value) {
    RegExp regex = RegExp(r'[a-z]');
    return regex.hasMatch(value);
  }

  bool hasNumber(String value) {
    RegExp regex = RegExp(r'[0-9]');
    return regex.hasMatch(value);
  }

  bool hasSpecialCharacters(String value) {
    // Define a regular expression for common special characters
    final regexp = RegExp(r'[!@#$%^&*(),.?\":{}|<>]');
    return regexp.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    // num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    debugPrint("code: ${widget.code}");
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
          'Reset Password',
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
                  color: const Color(0xFFf5f5f5),
                ),
                child: const Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    text:
                        "Reset your password by entering your new password and confirming it",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w500,
                      leadingDistribution: TextLeadingDistribution.proportional,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Form(
                key: formKey,
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GetX<UserController>(builder: (controller) {
                      return TextInputWidget(
                          controller: passwordController,
                          obscureText: controller.isObscure.value,
                          fontSize: 15,
                          visibilityIcon: IconButton(
                            onPressed: () => controller.toggle(),
                            icon: controller.isObscure.value
                                ? const Icon(
                                    Icons.visibility_off_rounded,
                                    size: 20,
                                  )
                                : const Icon(
                                    Icons.visibility_rounded,
                                    size: 20,
                                  ),
                          ),
                          labelText: "New Password",
                          hintText: "Enter new password",
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password cannot be empty';
                            }

                            // Check if password length is greater than 6
                            if (!isLength(value, 6)) {
                              return 'Password must be at least 6 characters long';
                            }

                            // Check if password contains at least one uppercase letter
                            if (hasUppercaseLetter(value) == false) {
                              return 'Password must contain at least one uppercase letter';
                            }

                            // Check if password contains at least one lowercase letter
                            if (!hasLowercaseLetter(value)) {
                              return 'Password must contain at least one lowercase letter';
                            }

                            // Check if password contains at least one digit
                            if (!hasNumber(value)) {
                              return 'Password must contain at least one digit';
                            }

                            // Check if password contains at least one special character
                            if (!hasSpecialCharacters(value)) {
                              return 'Password must contain at least one special character\n!@#\$%^&*(),.?\\":{}|<>';
                            }

                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              passwordController!.text = value!;
                              newPassword = passwordController!.text;
                            });
                          });
                    }),
                    const SizedBox(
                      height: 20,
                    ),
                    GetX<UserController>(builder: (controller) {
                      return TextInputWidget(
                        controller: confirmPasswordController,
                        fontSize: 15,
                        obscureText: controller.isObscure1.value,
                        labelText: "Confirm New Password",
                        hintText: "Confirm new password",
                        visibilityIcon: IconButton(
                          onPressed: () => controller.toggle1(),
                          icon: controller.isObscure1.value
                              ? const Icon(
                                  Icons.visibility_off_rounded,
                                  size: 20,
                                )
                              : const Icon(
                                  Icons.visibility_rounded,
                                  size: 20,
                                ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        //hintText: "Password must be at least 6 characters long",
                        validator: (value) {
                          if (value != newPassword) {
                            return "Password does not match";
                          }
                          return null;
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        height: kToolbarHeight * 1.2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: SizedBox(
            width: double.maxFinite,
            child: TextButton(
              onPressed: () async {
                bool? validate = formKey!.currentState!.validate();
                if (validate) {
                  userController.isLoading.value = true;
                  if (userController.isLoading.isTrue) {
                    Get.dialog(const LoadingWidget());
                  }
                  formKey!.currentState!.save();
                  await userController.passwordReset(
                      newPassword!, widget.code!);
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
                "Reset Password",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
