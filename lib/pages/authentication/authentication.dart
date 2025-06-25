// ignore: file_names
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/referral_controller.dart';
import 'package:hair_main_street/pages/authentication/forgot_password.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:string_validator/string_validator.dart' as validator;
import 'package:string_validator/string_validator.dart';

class SignInUpPage extends StatefulWidget {
  final String? referralCode;
  const SignInUpPage({super.key, this.referralCode});
  @override
  State<SignInUpPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInUpPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  UserController userController = Get.find<UserController>();
  ReferralController referralController = Get.find<ReferralController>();

  String? referralCode;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  GlobalKey<FormState> formKey = GlobalKey();
  String? email, password;

  @override
  Widget build(BuildContext context) {
    referralCode = widget.referralCode;
    debugPrint(referralCode);
    dismissKeyBoard() {
      FocusScope.of(context).requestFocus(FocusNode());
    }

    num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmpasswordController = TextEditingController();
    return GestureDetector(
      onTap: dismissKeyBoard,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Symbols.arrow_back_ios_new_rounded,
                size: 24, color: Colors.black),
          ),
          title: Text(
            'Sign Up/In',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          // flexibleSpace: Container(
          //   decoration: BoxDecoration(gradient: appBarGradient),
          // ),
          bottom: TabBar(
            controller: tabController,
            //padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            // indicator: BoxDecoration(
            //   color: Color(0xFF392F5A),
            //   borderRadius: BorderRadius.circular(12),
            // ),
            labelColor: Colors.black,
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Sign Up",
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Sign In",
                ),
              ),
            ],
            indicatorColor: Colors.black,
            indicatorWeight: 6,
          ),
          //backgroundColor: Colors.transparent,
        ),
        body: ListView(
          children: [
            Form(
              key: formKey,
              child: Container(
                padding: EdgeInsets.only(top: 20, left: 12, right: 12),
                height: screenHeight * 1,
                //decoration: BoxDecoration(gradient: myGradient),
                child: TabBarView(
                  controller: tabController,
                  children: [
                    // Sign up screen
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextInputWidget(
                          controller: emailController,
                          labelText: "Email",
                          hintText: "hello@gmail.com",
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (val) {
                            if (!validator.isEmail(val!)) {
                              return "Enter a valid Email";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              email = value!;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        GetX<UserController>(builder: (controller) {
                          return TextInputWidget(
                              controller: passwordController,
                              obscureText: controller.isObscure.value,
                              visibilityIcon: IconButton(
                                onPressed: () => controller.toggle(),
                                icon: controller.isObscure.value
                                    ? Icon(
                                        Icons.visibility_off_rounded,
                                        size: 20,
                                      )
                                    : Icon(
                                        Icons.visibility_rounded,
                                        size: 20,
                                      ),
                              ),
                              labelText: "Password",
                              hintText:
                                  "Password must be at least 6 characters long",
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password cannot be empty';
                                }

                                // Check if password length is greater than 6
                                if (!isLength(value, 6)) {
                                  return 'Password must be at least 6 characters long';
                                }

                                // Check if password contains at least one uppercase letter
                                if (!validator.isUppercase(value)) {
                                  return 'Password must contain at least one uppercase letter';
                                }

                                // Check if password contains at least one lowercase letter
                                if (!validator.isLowercase(value)) {
                                  return 'Password must contain at least one lowercase letter';
                                }

                                // Check if password contains at least one digit
                                if (!validator.isNumeric(value)) {
                                  return 'Password must contain at least one digit';
                                }

                                // Check if password contains at least one special character
                                if (!validator.isIn(value, [
                                  r'!',
                                  r'@',
                                  r'#',
                                  r'$',
                                  r'%',
                                  r'^',
                                  r'&',
                                  r'*',
                                  r'(',
                                  r')',
                                  r'-',
                                  r'_',
                                  r'+',
                                  r'=',
                                  r'{',
                                  r'}',
                                  r'[',
                                  r']',
                                  r'|',
                                  r'\',
                                  r';',
                                  r':',
                                  r'<',
                                  r'>',
                                  r',',
                                  r'.',
                                  r'?',
                                  r'/'
                                ])) {
                                  return 'Password must contain at least one special character';
                                }

                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  password = value!;
                                  //return null;
                                });
                              });
                        }),
                        const SizedBox(
                          height: 20,
                        ),
                        GetX<UserController>(builder: (controller) {
                          return TextInputWidget(
                            controller: confirmpasswordController,
                            obscureText: true,
                            labelText: "Confirm Password",
                            visibilityIcon: IconButton(
                              onPressed: () => controller.toggle1(),
                              icon: controller.isObscure1.value
                                  ? Icon(
                                      Icons.visibility_off_rounded,
                                      size: 20,
                                    )
                                  : Icon(
                                      Icons.visibility_rounded,
                                      size: 20,
                                    ),
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            //hintText: "Password must be at least 6 characters long",
                            validator: (value) {
                              if (value != password) {
                                return "Password does not match";
                              }
                              return null;
                            },
                          );
                        }),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () async {
                              bool validated = formKey.currentState!.validate();
                              if (validated) {
                                formKey.currentState!.save();
                                userController.isLoading.value = true;
                                if (userController.isLoading.isTrue) {
                                  Get.dialog(const LoadingWidget(),
                                      barrierDismissible: false);
                                }
                                var usercreation = await userController
                                    .createUser(email, password);
                                if (usercreation == "success" &&
                                    referralCode != null) {
                                  referralController.handleReferrals(
                                      referralCode!,
                                      userController.myUser.value.uid!);
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(10),
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(fontSize: 16),
                            ),
                            TextButton(
                              onPressed: () {
                                tabController.animateTo(1);
                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    //signIn Screen
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextInputWidget(
                          controller: emailController,
                          labelText: "Email",
                          hintText: "hello@gmail.com",
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (val) {
                            if (!validator.isEmail(val!)) {
                              return "Enter a valid Email";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              email = value!;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        GetX<UserController>(builder: (controller) {
                          return TextInputWidget(
                            controller: passwordController,
                            labelText: "Password",
                            obscureText: controller.isObscure.value,
                            visibilityIcon: IconButton(
                              onPressed: () => controller.toggle(),
                              icon: controller.isObscure.value
                                  ? Icon(
                                      Icons.visibility_off_rounded,
                                      size: 20,
                                    )
                                  : Icon(
                                      Icons.visibility_rounded,
                                      size: 20,
                                    ),
                            ),
                            // hintText:
                            //     "Password must be at least 6 characters long",
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Enter Password";
                              } else if (val.length < 6) {
                                return "Password must be at least 6 characters long";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                password = value!;
                              });
                            },
                          );
                        }),
                        SizedBox(
                          height: 12,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Get.to(() => ForgotPasswordPage());
                              },
                              child: Text(
                                "Forgotten Password?",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () async {
                              bool validated = formKey.currentState!.validate();
                              if (validated) {
                                userController.isLoading.value = true;
                                if (userController.isLoading.isTrue) {
                                  Get.dialog(const LoadingWidget(),
                                      barrierDismissible: false);
                                } else {
                                  //debugPrint("${userController.isLoading.value}");
                                }
                                formKey.currentState!.save();
                                //debugPrint(email!);
                                await userController.signIn(email, password);
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(10),
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Dont Have an Account?",
                              style: TextStyle(fontSize: 16),
                            ),
                            TextButton(
                              onPressed: () {
                                tabController.animateTo(0);
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
