import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/services/notification.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference userProfileCollection =
      FirebaseFirestore.instance.collection("userProfile");
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  Future<MyUser?> convertToMyUserType(User? user) async {
    if (user == null) {
      return null;
    }
    var otherDetails = await userProfileCollection.doc(user.uid).get();
    if (otherDetails.exists) {
      var data = otherDetails.data() as Map<String, dynamic>;
      return MyUser.fromJson(data);
      // return MyUser(
      //   uid: user.uid,
      //   email: user.email,
      //   referralLink: data["referral link"],
      //   referralCode: data["referral code"],
      //   isBuyer: data["isBuyer"] ?? true, // Ensure isBuyer has a default value
      //   phoneNumber: data["phonenumber"],
      //   isVendor: data["isVendor"],
      //   isAdmin: data["isAdmin"],
      //   fullname: data["fullname"],
      //   address:
      //       data["address"] != null ? Address.fromJson(data["address"]) : null,
      //   profilePhoto: data["profile photo"],
      //   createdAt: data["created at"] != null
      //       ? Timestamp.fromMillisecondsSinceEpoch(data["created at"])
      //       : null,
      //   // Set other properties here if needed
      // );
    } else {
      return null; // Return null if user details don't exist
    }
  }

// Determine the auth state of the app
  Stream<MyUser?> get authState {
    return auth
        .authStateChanges()
        .asyncMap((user) => convertToMyUserType(user));
  }

// register with email and password
  Future createUserWithEmailandPassword(String? email, String? password) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: email!, password: password!);
      dynamic user = result.user;
      await DataBaseService(uid: user.uid).createUserProfile();
      var referralCode = DataBaseService().generateReferralCode();
      var referralLink = DataBaseService().generateReferralLink(referralCode);
      String? token = await NotificationService().getDeviceToken();
      await userProfileCollection.doc(user.uid).update({
        "token": token,
        "referral code": referralCode,
        "referral link": referralLink
      });
      return await convertToMyUserType(user);
    } on FirebaseAuthException catch (e) {
      //debugPrint(e.toString());
      return e;
    } catch (e) {
      //debugPrint(e.toString());
      return e;
    }
  }

  // sign in with email and password
  Future signInWithEmailandPassword(String? email, String? password) async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: email!, password: password!);
      User? user = result.user;
      String? token = await NotificationService().getDeviceToken();
      debugPrint("token: $token");
      var profile = await userProfileCollection.doc(user!.uid).get();
      var data = profile.data() as Map<String, dynamic>;
      if (data["referral code"] == null && data["referral link"] == null) {
        var referralCode = DataBaseService().generateReferralCode();
        var referralLink = DataBaseService().generateReferralLink(referralCode);
        await userProfileCollection.doc(user.uid).update(
            {"referral code": referralCode, "referral link": referralLink});
      }
      await userProfileCollection.doc(user.uid).set({
        "token": token,
      }, SetOptions(merge: true));
      return await convertToMyUserType(user);
    } on FirebaseAuthException catch (e) {
      //debugPrint(e.toString());
      return e;
    } catch (e) {
      return e;
    }
  }

  //sign out
  Future signOut() async {
    try {
      // Disconnect from Google Sign-In
      await googleSignIn.signOut();

      var userID = auth.currentUser?.uid;
      if (userID != null) {
        await auth.signOut();
        userProfileCollection.doc(userID).update({"token": null});
        return 'success';
      } else {
        // Handle the case where the user is not signed in
        debugPrint('User is not signed in.');
        return null;
      }
    } catch (e) {
      debugPrint('Failed to sign out: $e');
      return null;
    }
  }

  //delete account
  Future deleteAccount() async {
    try {
      var currentUser = auth.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
        await userProfileCollection.doc(currentUser.uid).delete();
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //change password
  Future changePassword(String oldPassword, String newPassword) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw Exception('No User Signed In');
      }
      final credential = EmailAuthProvider.credential(
          email: user.email!, password: oldPassword);

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return 'changed Password';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return 'wrong password';
      }
      debugPrint(e.toString());
      return 'an error occurred';
    }
  }

  final actionCodeSettings = ActionCodeSettings(
    handleCodeInApp: true,
    url: "https://app.hairmainstreet.com/reset-password",
    androidInstallApp: false,
    linkDomain: "app.hairmainstreet.com",
    // dynamicLinkDomain: "hairmainstreet.com",
    iOSBundleId: "app.secureglobal.hairmainstreet",
    androidPackageName: "app.secureglobal.hairmainstreet",
  );

  //experimental forgotten password
  experimentalPasswordResetSending(String email) async {
    try {
      await auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
      return 'success';
    } on FirebaseAuthException catch (e) {
      debugPrint('Error code: ${e.code}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Full error: $e');
      return e;
    } catch (e) {
      debugPrint("non firebase error:$e");
      return e;
    }
  }

  // In the part of your app that handles deep links

  Future handlePasswordResetLink(Uri deepLink) async {
    final oobCode = deepLink.queryParameters['oobCode'];

    if (oobCode != null) {
      try {
        // 1. Verify the code
        String email = await auth
            .checkActionCode(oobCode)
            .then((value) => value.data["email"]);

        return {"success": true, "oobCode": oobCode, "message": email};
        // Get.to(() => ResetPasswordPage(
        //       code: oobCode,
        //     ));
      } on FirebaseAuthException catch (e) {
        // Handle invalid code, expired code, etc.
        return {
          "success": false,
          "oobCode": oobCode,
          "message": e.code,
        };
      }
    } else {
      return {
        "success": false,
        "oobCode": "",
        "message": "no oob code provided",
      };
    }
  }

  //handle forgotten password
  Future resetPasswordEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return 'success';
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e;
    }
  }

  Future resetPasswordProper(String newPassword, code) async {
    try {
      await auth.confirmPasswordReset(code: code, newPassword: newPassword);
      return 'success';
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e;
    }
  }

  Future<Object?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser;
      List<String> scopes = [
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ];
      await googleSignIn.initialize();
      try {
        googleUser = await googleSignIn.authenticate();
      } on GoogleSignInException catch (e) {
        debugPrint(e.toString());
      }
      GoogleSignInClientAuthorization? authorization =
          await googleUser!.authorizationClient.authorizeScopes(scopes);

      debugPrint("Google User: ${googleUser.email}");

      googleSignIn.authenticationEvents.listen((event) {
        if (event.runtimeType == GoogleSignInAuthenticationEventSignIn) {
          googleUser = (event as GoogleSignInAuthenticationEventSignIn).user;
          debugPrint("User signed in with Google: ${googleUser?.email}");
        } else if (event.runtimeType ==
            GoogleSignInAuthenticationEventSignOut) {
          googleUser = null;
          debugPrint("User signed out from Google");
        }
      });
      final userCredentials =
          GoogleAuthProvider.credential(accessToken: authorization.accessToken);

      UserCredential result = await auth.signInWithCredential(userCredentials);
      User? user = result.user;
      String? token = await NotificationService().getDeviceToken();
      var profile = await userProfileCollection.doc(user!.uid).get();
      if (!profile.exists) {
        await DataBaseService(uid: user.uid).createUserProfile();
        var referralCode = DataBaseService().generateReferralCode();
        var referralLink = DataBaseService().generateReferralLink(referralCode);
        String? token = await NotificationService().getDeviceToken();
        await userProfileCollection.doc(user.uid).update({
          "fullname": user.displayName ?? "",
          "token": token,
          "referral code": referralCode,
          "referral link": referralLink
        });
        return await convertToMyUserType(user);
      } else {
        var data = profile.data() as Map<String, dynamic>;
        if (data["referral code"] == null && data["referral link"] == null) {
          var referralCode = DataBaseService().generateReferralCode();
          var referralLink =
              DataBaseService().generateReferralLink(referralCode);
          await userProfileCollection.doc(user.uid).update(
              {"referral code": referralCode, "referral link": referralLink});
        }
        await userProfileCollection.doc(user.uid).set({
          "token": token,
        }, SetOptions(merge: true));
        return await convertToMyUserType(user);
      }
    } on FirebaseAuthException catch (e) {
      return e;
    } on FirebaseException catch (e) {
      debugPrint("an error occured: ${e.code}");
    } catch (e) {
      debugPrint("the google sign in error: $e");
    }
    return null;
  }

  Future linkWithGoogle() async {
    try {
      // final googleUser = await GoogleSignIn().signIn();

      // final authenticatedUser = await googleUser?.authentication;

      // final userCredentials = GoogleAuthProvider.credential(
      //   accessToken: authenticatedUser?.accessToken,
      //   idToken: authenticatedUser?.idToken,
      // );

      // await auth.currentUser?.linkWithCredential(userCredentials);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          debugPrint("The provider has already been linked to the user.");
          break;
        case "invalid-credential":
          debugPrint("The provider's credential is not valid.");
          break;
        case "credential-already-in-use":
          debugPrint(
              "The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
        // See the API reference for the full list of error codes.
        default:
          debugPrint("Unknown error");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //sign in with apple
  Future signInWithApple() async {
    debugPrint("signing in with apple");
    try {
      final appleCredentials =
          await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);

      debugPrint("apple credentials: $appleCredentials");

      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredentials.identityToken,
        accessToken: appleCredentials.authorizationCode,
      );
      UserCredential result = await auth.signInWithCredential(oAuthCredential);
      User? user = result.user;
      String? token = await NotificationService().getDeviceToken();
      var profile = await userProfileCollection.doc(user!.uid).get();
      if (!profile.exists) {
        await DataBaseService(uid: user.uid).createUserProfile();
        var referralCode = DataBaseService().generateReferralCode();
        var referralLink = DataBaseService().generateReferralLink(referralCode);
        String? token = await NotificationService().getDeviceToken();
        await userProfileCollection.doc(user.uid).update({
          "fullname": user.displayName ?? "",
          "token": token,
          "referral code": referralCode,
          "referral link": referralLink
        });
        return await convertToMyUserType(user);
      } else {
        var data = profile.data() as Map<String, dynamic>;
        if (data["referral code"] == null && data["referral link"] == null) {
          var referralCode = DataBaseService().generateReferralCode();
          var referralLink =
              DataBaseService().generateReferralLink(referralCode);
          await userProfileCollection.doc(user.uid).update(
              {"referral code": referralCode, "referral link": referralLink});
        }
        await userProfileCollection.doc(user.uid).set({
          "token": token,
        }, SetOptions(merge: true));
        return await convertToMyUserType(user);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException: ${e.code}");
      return e;
    } on FirebaseException catch (e) {
      debugPrint("an error occured: ${e.code}");
    } catch (e) {
      debugPrint("the apple sign in error: ${e.toString()}");
    }
    return null;
  }
}
