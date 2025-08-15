import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hair_main_street/models/admin_variable_model.dart';
import 'package:hair_main_street/models/cart_item_model.dart';
import 'package:hair_main_street/models/message_model.dart';
import 'package:hair_main_street/models/notifications_model.dart';
import 'package:hair_main_street/models/order_model.dart';
import 'package:hair_main_street/models/referral_model.dart';
import 'package:hair_main_street/models/refund_request_model.dart';
import 'package:hair_main_street/models/review.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:hair_main_street/models/vendors_model.dart';
import 'package:hair_main_street/models/wallet_transaction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class DataBaseService {
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 50, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
  final String? uid;
  DataBaseService({this.uid});

  User? currentUser = FirebaseAuth.instance.currentUser;

  var auth = FirebaseAuth.instance;

  var fcm = FirebaseMessaging.instance;

  var db = FirebaseFirestore.instance;

  CollectionReference adminVariablesCollection =
      FirebaseFirestore.instance.collection("admin variables");

  CollectionReference userProfileCollection =
      FirebaseFirestore.instance.collection("userProfile");

  CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

  CollectionReference vendorsCollection =
      FirebaseFirestore.instance.collection('vendors');

  CollectionReference ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chat');

  CollectionReference walletCollection =
      FirebaseFirestore.instance.collection('wallet');

  CollectionReference notificationsCollection =
      FirebaseFirestore.instance.collection('notifications');

  CollectionReference referralsCollection =
      FirebaseFirestore.instance.collection('referrals');

  CollectionReference reviewsCollection =
      FirebaseFirestore.instance.collection('reviews');

  CollectionReference refundsCollection =
      FirebaseFirestore.instance.collection('refunds');

  CollectionReference cancellationCollection =
      FirebaseFirestore.instance.collection('cancellations');

  CollectionReference remindersCollection =
      FirebaseFirestore.instance.collection('reminders');

  CollectionReference withdrawalRequestCollection =
      FirebaseFirestore.instance.collection('withdrawals');

  //get admin variables
  Stream<AdminVariables?> getAdminVariables() {
    var result = adminVariablesCollection.doc("admin").snapshots();
    return result.map((snapshot) {
      if (snapshot.exists) {
        return AdminVariables.fromJson(snapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    });
  }

  //get the role dynamically
  Stream<DocumentSnapshot?> get getRoleDynamically {
    return userProfileCollection.doc(currentUser!.uid).snapshots();
  }

  // determine if a user is a vendor
  Stream<bool> determineIfVendor() {
    return userProfileCollection.doc(currentUser!.uid).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey("isVendor")) {
          return data["isVendor"] as bool? ?? false;
        }
      }
      return false; // Default to false if document doesn't exist or field is missing
    });
  }

  //verify role
  Future<Map<String, dynamic>?> verifyRole() async {
    try {
      DocumentSnapshot documentSnapshot =
          await userProfileCollection.doc(currentUser!.uid).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic>? user =
            documentSnapshot.data() as Map<String, dynamic>;
        //print(user);
        if (user["isVendor"] == true) {
          return {"Vendor": currentUser!.uid};
        } else if (user["isBuyer"] == true) {
          return {"Buyer": currentUser!.uid};
        } else if (user['isAdmin'] == true) {
          return {'Admin': currentUser!.uid};
        } else {
          throw Exception();
        }
      }
    } catch (e) {
      logger.e(e);
    }
    return null;
  }

  //create user profile and update profile
  Future createUserProfile() async {
    try {
      //create wishlist subcollection
      userProfileCollection.doc(uid).collection('wishlist');

      //create a cart subcollection
      userProfileCollection.doc(uid).collection('cart');

      // make the user profile
      return await userProfileCollection.doc(uid).set({
        "email": currentUser!.email,
        "uid": uid,
        'fullname': "",
        'phonenumber': "",
        'isVendor': false,
        'isBuyer': true,
        'isAdmin': false,
        "created at": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      return (e);
    }
  }

  Future<Map<String, dynamic>?> addressExists(String addressID) async {
    var addressSnapshot = await userProfileCollection
        .doc(currentUser!.uid)
        .collection("delivery addresses")
        .where("addressID", isEqualTo: addressID)
        .limit(1)
        .get();
    if (addressSnapshot.docs.isEmpty) {
      return null;
    } else if (addressSnapshot.docs.first.exists) {
      return {addressSnapshot.docs.first.id: true};
    }
    return {};
  }

  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> updatedFields) async {
    try {
      await userProfileCollection.doc(currentUser!.uid).update(updatedFields);

      var result = await userProfileCollection.doc(currentUser!.uid).get();
      var user = result.data() as Map<String, dynamic>;
      return {
        "result": "success",
        "fullname": user['fullname'],
        // "address": user['address'],
        "phoneNumber": user['phonenumber'],
        "profile photo": user['profile photo'],
      };
    } catch (e) {
      logger.e(e);
      return {
        "result": "error",
        "message": e.toString(),
      };
    }
  }

  //get delivery address
  Stream<List<Address>> getDeliveryAddresses(String userID) {
    return userProfileCollection
        .doc(userID)
        .collection('delivery addresses')
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        // Handle the case where the subcollection is empty
        return []; // Return an empty list
      } else {
        return querySnapshot.docs
            .map((doc) => Address.fromJson(doc.data()))
            .toList();
      }
    });
  }

  //add delivery address
  Future addDeliveryAddresses(String userID, Address address) async {
    try {
      var addressFields = address.toJson();
      addressFields["addressID"] = userProfileCollection
          .doc(userID)
          .collection('delivery addresses')
          .doc()
          .id;

      if (addressFields["isDefault"] == false) {
        await userProfileCollection
            .doc(userID)
            .collection('delivery addresses')
            .doc(addressFields["addressID"])
            .set(
              addressFields,
              SetOptions(merge: true),
            );
      } else {
        db.runTransaction((transaction) async {
          final docRef = db
              .collection('userProfile')
              .doc(userID)
              .collection("delivery addresses")
              .doc(addressFields["addressID"]);

          final querySnapshot = await db
              .collection("userProfile")
              .doc(userID)
              .collection("delivery addresses")
              .where('isDefault', isEqualTo: true)
              .get();

          // Update all currently default documents to false
          for (var doc in querySnapshot.docs) {
            if (doc.id != addressFields["addressID"]) {
              transaction.update(doc.reference, {'isDefault': false});
            }
          }

          // Set the specified document as default
          transaction.set(
            docRef,
            addressFields,
            SetOptions(merge: true),
          );
        });
      }

      return "success";
    } catch (e) {
      logger.e(e);
    }
  }

  //edit delivery address
  Future editDeliveryAddresses(String userID, Address address) async {
    try {
      var addressFields = address.toJson();
      if (addressFields["isDefault"] == true) {
        db.runTransaction((transaction) async {
          final docRef = db
              .collection('userProfile')
              .doc(userID)
              .collection("delivery addresses")
              .doc(addressFields["addressID"]);

          final querySnapshot = await db
              .collection("userProfile")
              .doc(userID)
              .collection("delivery addresses")
              .where('isDefault', isEqualTo: true)
              .get();

          // Update all currently default documents to false
          for (var doc in querySnapshot.docs) {
            if (doc.id != addressFields["addressID"]) {
              transaction.update(doc.reference, {'isDefault': false});
            }
          }

          // Set the specified document as default
          transaction.set(
            docRef,
            addressFields,
            SetOptions(merge: true),
          );
        });
        // await userProfileCollection
        //     .doc(userID)
        //     .set({"address": addressFields}, SetOptions(merge: true));
      } else {
        //add delivery address subcollection or add to it if doesnt exist
        await userProfileCollection
            .doc(userID)
            .collection('delivery addresses')
            .doc(addressFields["addressID"])
            .set(
              addressFields,
              SetOptions(
                merge: true,
              ),
            );
      }
      return "success";
    } catch (e) {
      logger.e(e);
    }
  }

  // //update delivery address
  // Future updateDeliveryAddresses(
  //     String userID, String addressID, String address) async {
  //   try {
  //     //create delivery address subcollection or add to it if doesnt exist
  //     await userProfileCollection
  //         .doc(userID)
  //         .collection('delivery addresses')
  //         .doc(addressID)
  //         .set(
  //       {"addressID": addressID, "address": address},
  //       SetOptions(merge: true),
  //     );
  //     return "success";
  //   } catch (e) {
  //     logger.e(e);
  //   }
  // }

  // delete delivery address
  Future deleteDeliveryAddresses(String userID, String addressID) async {
    try {
      //delete the delivery address
      await userProfileCollection
          .doc(userID)
          .collection('delivery addresses')
          .doc(addressID)
          .delete();

      return "success";
    } catch (e) {
      logger.e(e);
    }
  }

  Future<MyUser?> getBuyerDetails(String userID) async {
    try {
      var result = await userProfileCollection.doc(userID).get();
      if (result.exists) {
        var user = MyUser.fromJson(result.data() as Map<String, dynamic>);
        return user;
      } else {
        logger.i("Buyer does not exist");
      }
    } on FirebaseException catch (e) {
      logger.e(e);
    } catch (e) {
      logger.e(e);
    }
    return null;
  }

  //vendor stuff including vendor profile
  Future createVendor(Vendors vendor) async {
    try {
      var documentID = currentUser!.uid;
      await vendorsCollection.doc(documentID).set({
        "docID": documentID,
        "userID": currentUser!.uid,
        "shop name": vendor.shopName,
        "account info": vendor.accountInfo,
        "contact info": vendor.contactInfo,
        "first verification": vendor.firstVerification,
        "second verification": vendor.secondVerification,
        "createdAt": FieldValue.serverTimestamp(),
      });
      vendorsCollection.doc(documentID).collection("withdrawal requests");
      return "success";
    } on FirebaseException catch (e) {
      logger.e("Error: ${e.code} and ${e.message}");
    }
  }

  //update a vendor
  Future updateVendor(String fieldName, value) async {
    try {
      if (fieldName == "shop name") {
        String shopLink =
            generateShopLink(shopName: fieldName, vendorID: currentUser!.uid);
        await vendorsCollection.doc(currentUser!.uid).set({
          fieldName: value,
          "shop link": shopLink,
        }, SetOptions(merge: true));
      } else {
        await vendorsCollection
            .doc(currentUser!.uid)
            .set({fieldName: value}, SetOptions(merge: true));
      }
      return "success";
      // var result = await userProfileCollection.doc(currentUser!.uid).get();
      // //result.data() as Map<String, dynamic>;
      // var user = result.data() as Map<String, dynamic>;
      // return {
      //   "fullname": user['fullname'],
      //   "address": user['address'],
      //   "phoneNumber": user['phonenumber']
      // };
    } catch (e) {
      logger.e(e);
    }
  }

  //getVendors
  Stream<List<Vendors>> getVendors() {
    var response = vendorsCollection
        .where("first verification", isEqualTo: true)
        .snapshots();
    return response.map((event) => event.docs
        .map((doc) => Vendors.fromdata(doc.data() as Map<String, dynamic>))
        .toList());
  }

  //get vendor details from their name
  Future<Vendors?> getVendorFromVendorID(String vendorID) async {
    try {
      final querySnapshot = await vendorsCollection
          .where('userID', isEqualTo: vendorID)
          .where("isDeleted", isEqualTo: false)
          .where("second verification", isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final vendorData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        return Vendors.fromdata(vendorData);
      } else {
        return null; // No vendor found with the given shopName
      }
    } catch (e) {
      logger.e(e);
      return null; // Return null in case of an error
    }
  }

  //get vendor details
  Stream<Vendors?> getVendorDetails({String? userID}) {
    try {
      // if (currentUser == null) {
      //   return Stream.error("Current user is null");
      // }

      var response = vendorsCollection
          .where('userID', isEqualTo: userID ?? currentUser!.uid)
          .snapshots();

      return response.map((event) {
        if (event.docs.isNotEmpty) {
          var data = event.docs.first.data() as Map<String, dynamic>;
          //print(data);
          return Vendors.fromdata(data);
        } else {
          return null;
        }
      });
    } catch (e) {
      logger.e("Error in getVendorDetails: $e");
      return Stream.error(e);
    }
  }

  Future<Vendors?> getVendorDetailsFuture({String? userID}) async {
    try {
      // if (currentUser == null) {
      //   return Stream.error("Current user is null");
      // }

      var response = await vendorsCollection
          .where('userID', isEqualTo: userID ?? currentUser!.uid)
          .get();

      return Vendors.fromdata(
          response.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      logger.e("Error in getVendorDetails: $e");
      return Future.error(e);
    }
  }

  //approve vendor, an admin function
  Future approveVendor(String vendorID) async {
    try {
      var role = await verifyRole();
      if (role!.keys.contains('Admin')) {
        await vendorsCollection.doc(vendorID).update({"isVerified": true});
        await userProfileCollection.doc(vendorID).update({"isVendor": true});
        return 'success';
      } else {
        return 'Not Authorized';
      }
    } on FirebaseException catch (e) {
      logger.e("Error: ${e.code} and ${e.message}");
    }
  }

  //fetch cart products
  Stream<List<CartItem>> fetchCartItems() async* {
    try {
      var role = await verifyRole();
      // Check if the user has the "Buyer" role
      if (role != null && role.keys.contains("Buyer") ||
          role!.keys.contains("Vendor")) {
        var result = userProfileCollection
            .doc(currentUser!.uid)
            .collection("cart")
            .snapshots();

        // Yield the mapped data as a stream
        await for (var event in result) {
          if (event.docs.isEmpty) {
            yield <CartItem>[];
          } else {
            yield event.docs.map((data) {
              var doc = data.data();
              return CartItem(
                cartItemID: doc['cartItemID'],
                price: doc["price"],
                quantity: doc['quantity'],
                productID: doc['productID'],
                optionName: doc["option"],
              );
            }).toList();
          }
        }
      } else {
        logger.i("stuff");
      }
    } catch (e) {
      logger.e(e);
      throw Exception(e.toString());
    }
  }

  //helper function to check if a cart item exists
  Future<Map<dynamic, bool>?> itemExists(
      dynamic productID, userID, String pathName,
      {String? fieldName}) async {
    final querySnapshot = await userProfileCollection
        .doc(userID)
        .collection(pathName)
        .where(fieldName ?? 'productID', isEqualTo: productID)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    } else if (querySnapshot.docs.first.exists) {
      //print("pow");
      return {querySnapshot.docs.first.id: true};
    }
    return null;
    //return {querySnapshot.docs.firstOrNull!.id: querySnapshot.docs.isNotEmpty};
  }

  Future<Map<dynamic, bool>?> cartItemExists(String productID, userID,
      {String? fieldName, String? anotherFieldName, String? checkValue}) async {
    final querySnapshot = anotherFieldName == null
        ? await userProfileCollection
            .doc(userID)
            .collection("cart")
            .where(fieldName ?? 'productID', isEqualTo: productID)
            .get()
        : await userProfileCollection
            .doc(userID)
            .collection("cart")
            .where(fieldName ?? 'productID', isEqualTo: productID)
            .where(anotherFieldName, isEqualTo: checkValue)
            .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    } else if (querySnapshot.docs.first.exists) {
      //print("pow");
      return {querySnapshot.docs.first.id: true};
    }
    return null;
    //return {querySnapshot.docs.firstOrNull!.id: querySnapshot.docs.isNotEmpty};
  }

  //add to cart function
  Future addToCart(CartItem cartItem) async {
    try {
      var role = await verifyRole();
      if (role!.keys.contains("Buyer") || role.keys.contains("Vendor")) {
        //check if item already exists then add to quantity and calculate price
        var item = await cartItemExists(cartItem.productID, currentUser!.uid,
            anotherFieldName: "option", checkValue: cartItem.optionName);
        if (item != null) {
          var quantityIncrement = FieldValue.increment(cartItem.quantity!);
          await userProfileCollection
              .doc(currentUser!.uid)
              .collection('cart')
              .doc(item.keys.single)
              .update({
            "quantity": quantityIncrement,
          });
          await db.runTransaction((transaction) async {
            // Get the document
            DocumentSnapshot snapshot = await transaction.get(
                userProfileCollection
                    .doc(currentUser!.uid)
                    .collection('cart')
                    .doc(item.keys.single));

            // Calculate the new price
            //print(snapshot.get('quantity'));
            num newPrice = (cartItem.price! / cartItem.quantity!) *
                (snapshot.get('quantity'));

            // Update the quantity and price in the transaction
            transaction.update(
                userProfileCollection
                    .doc(currentUser!.uid)
                    .collection('cart')
                    .doc(item.keys.single),
                {
                  //"quantity": FieldValue.increment(cartItem.quantity!),
                  "price": newPrice
                });
          });

          // print("done");
        } else {
          //else just add product to cart
          //get cart reference and id
          var cartRef = userProfileCollection
              .doc(currentUser!.uid)
              .collection('cart')
              .doc();
          var cartItemId = cartRef.id;
          await userProfileCollection
              .doc(currentUser!.uid)
              .collection('cart')
              .doc(cartItemId)
              .set({
            "productID": cartItem.productID,
            "quantity": cartItem.quantity,
            "price": cartItem.price,
            "cartItemID": cartItemId,
            "option": cartItem.optionName,
          });
        }
        return "Success";
      } else {
        logger.i("Not Authorized");
      }
    } on FirebaseException catch (e) {
      logger.e("Error: ${e.code} and ${e.message}");
    }
  }

  //update cart item
  Future<String> updateCartItemQuantityandPrice(
      String cartItemID, int newQuantity) async {
    final userRef = userProfileCollection
        .doc(currentUser!.uid)
        .collection('cart')
        .doc(cartItemID);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);

        if (snapshot.exists) {
          final data = snapshot.data();
          final currentQuantity = data!['quantity'] ?? 0;
          final currentPrice = data['price'] ?? 0.0;

          // Calculate the new price based on the previous quantity and the new quantity
          final pricePerUnit = currentPrice / currentQuantity;
          final newPrice = pricePerUnit * (currentQuantity + newQuantity);

          transaction.update(userRef, {
            'quantity': currentQuantity + newQuantity,
            'price': newPrice,
          });
        } else {
          // Handle the case where the document doesn't exist
          throw Exception('Cart item not found');
        }
      });
      return "success";
    } catch (e) {
      logger.e('Error updating cart item: $e');
      rethrow;
    }
  }

  // remove from cart
  Future removeFromCart(List<String> cartItemID) async {
    try {
      final role = await verifyRole();
      if (role!.keys.contains("Buyer") || role.keys.contains("Vendor")) {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final WriteBatch batch = firestore.batch();

        for (String cartID in cartItemID) {
          DocumentReference productRef = userProfileCollection
              .doc(currentUser!.uid)
              .collection('cart')
              .doc(cartID);
          batch.delete(productRef);
        }

        // Commit the batch
        await batch.commit();
        return 'success';
      }
    } on FirebaseException catch (e) {
      logger.e("Error: ${e.code} and ${e.message}");
    }
  }

  //create order and update orders and get orders

  //get buyers orders
  Future<List<DatabaseOrderResponse>> getBuyerOrders(String? userID) async {
    try {
      final querySnapshot = await ordersCollection
          .where('buyerID', isEqualTo: userID)
          .where("isDeleted", isEqualTo: false)
          .orderBy('created at', descending: true)
          .get();

      List<DatabaseOrderResponse> orders = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final data = doc.data() as Map<String, dynamic>;
          data['orderID'] = doc.id;

          // Fetch order items
          final orderItemsSnapshot =
              await doc.reference.collection('order items').get();
          final orderItems = orderItemsSnapshot.docs.map((itemDoc) {
            return OrderItem.fromJson(itemDoc.data());
          }).toList();

          data['orderItems'] = orderItems;

          // Handle shipping address
          // if (data['shipping address'] != null &&
          //     data['shipping address'] is Map) {
          //   data['shipping address'] = Address.fromJson(
          //           data['shipping address'] as Map<String, dynamic>)
          //       .toJson();
          // } else {
          //   data['shipping address'] = null;
          // }

          return DatabaseOrderResponse.fromJson(data);
        }),
      );

      return orders;
    } catch (e) {
      logger.e('Error fetching buyer orders: $e');
      return [];
    }
  }

  Stream<List<DatabaseOrderResponse>> getBuyerOrdersStream(
      String? userID) async* {
    yield await getBuyerOrders(userID);
    yield* ordersCollection
        .where('buyerID', isEqualTo: userID)
        .where("isDeleted", isEqualTo: false)
        .orderBy('created at', descending: true)
        .snapshots()
        .asyncMap((_) => getBuyerOrders(userID));
  }

  // Stream<List<DatabaseOrderResponse>> getBuyerOrders(String? userID) async* {
  //   await for (var event in ordersCollection
  //       .where('buyerID', isEqualTo: userID)
  //       .orderBy('created at', descending: true)
  //       .snapshots()) {
  //     if (event.docs.isEmpty) {
  //       yield [];
  //     } else {
  //       var futures = event.docs.map((doc) async {
  //         var data = doc.data() as Map<String, dynamic>;
  //         var orderItemSnapshot =
  //             await doc.reference.collection('order items').get();
  //         var orderItems = orderItemSnapshot.docs.map((orderItemDoc) {
  //           var orderItemData = orderItemDoc.data();
  //           return OrderItem.fromJson(orderItemData);
  //         }).toList();
  //         data["orderItems"] = orderItems.map((item) => item.toJson()).toList();

  //         // No need to handle shipping address separately,
  //         // DatabaseOrderResponse.fromJson will handle it

  //         return DatabaseOrderResponse.fromJson(data);
  //       }).toList();
  //       yield await Future.wait(futures);
  //     }
  //   }
  // }

  //get vendors orders
  Stream<List<DatabaseOrderResponse>> getVendorsOrders(String? userID) async* {
    await for (var event in ordersCollection
        .where('vendorID', isEqualTo: userID)
        .where("isDeleted", isEqualTo: false)
        .orderBy('created at', descending: true)
        .snapshots()) {
      if (event.docs.isEmpty) {
        yield [];
      } else {
        var futures = event.docs.map((doc) async {
          var data = doc.data() as Map<String, dynamic>;
          var orderItemSnapshot =
              await doc.reference.collection('order items').get();
          var orderItems = orderItemSnapshot.docs.map((orderItemDoc) {
            var orderItemData = orderItemDoc.data();
            return OrderItem.fromJson(orderItemData);
          }).toList();
          data["orderItems"] = orderItems;
          // print(data['orderItems']);
          return DatabaseOrderResponse.fromJson(data);
        }).toList();

        var results = await Future.wait(futures);
        //print(results);
        yield results;
      }
    }
  }

  //create order
  Future createOrder(Orders order, OrderItem orderItem) async {
    try {
      var role = await verifyRole();
      if (role!.keys.contains("Buyer") || role.keys.contains("Vendor")) {
        if (order.buyerId == order.vendorId) {
          return {"Cannot Place order": order.buyerId};
        } else {
          var orderRef = ordersCollection.doc();
          var orderID = orderRef.id;

          Map<String, dynamic> orderMap = order.toJson();
          orderMap["orderID"] = orderID;
          orderMap["created at"] = FieldValue.serverTimestamp();
          orderMap["updated at"] = FieldValue.serverTimestamp();

          //get vendor id from product id provided
          // var result = await productsCollection.doc(orderItem.productId).get();
          // var product = Product.fromdata(result.data() as Map<String, dynamic>);
          // var vendorID = product.vendorId;

          await ordersCollection.doc(orderID).set(orderMap);

          await ordersCollection
              .doc(orderID)
              .collection('order items')
              .doc(orderID)
              .set({
            "productID": orderItem.productId,
            "quantity": orderItem.quantity,
            "price": orderItem.price,
          });

          if (order.paymentMethod == 'installment') {
            await remindersCollection.doc(orderID).set({
              'expirationReminderSent': false,
              'threeDayPaymentReminderSent': false,
              'oneDayPaymentReminderSent': false,
            });
          }

          // Start a transaction to delete the product from the user's cart
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            var cartCollectionRef =
                userProfileCollection.doc(order.buyerId).collection('cart');
            var querySnapshot = await cartCollectionRef
                .where('productID', isEqualTo: orderItem.productId)
                .get();

            // Iterate over the documents in the query snapshot
            for (var doc in querySnapshot.docs) {
              // Get the reference to the document and delete it
              var cartDocRef = doc.reference;
              transaction.delete(cartDocRef);
            }
          });

          return {'Order Created': orderID};
        }
      }
    } on FirebaseException catch (e) {
      logger.e(e);
    }
  }

//update orderStatus for vendors
  Future updateOrderStatus(String orderID, String orderStatus) async {
    try {
      var role = await verifyRole();
      if (role!.keys.contains("Vendor")) {
        await ordersCollection.doc(orderID).update({
          "order status": orderStatus,
          "updated at": FieldValue.serverTimestamp(),
        });
        return "success";
      }
    } on FirebaseAuthException catch (e) {
      logger.e(e);
    } catch (e) {
      logger.e(e);
    }
  }

  //update order
  Future updateOrder(Orders? order) async {
    try {
      debugPrint("order: ${order!.toJson()}");
      var role = await verifyRole();
      if (role!.keys.contains("Buyer")) {
        Timestamp createdAt = order!.createdAt!;
        Map<String, dynamic> updatedFields = order.toJson();
        updatedFields["updated at"] = FieldValue.serverTimestamp();
        updatedFields["created at"] = createdAt;
        await ordersCollection.doc(order.orderId).set(
              updatedFields,
              SetOptions(
                merge: true,
              ),
            );
        return "success";
      } else {
        logger.i("not authorized");
      }
    } on FirebaseException catch (e) {
      logger.e(e);
    }
  }

  //get single order
  Future<DatabaseOrderResponse?> getSingleOrder(String orderID) async {
    try {
      var orderResult = await ordersCollection.doc(orderID).get();
      var orderItem = await ordersCollection
          .doc(orderID)
          .collection("order items")
          .doc(orderID)
          .get();
      var orderResultData = orderResult.data() as Map<String, dynamic>;
      var orderItemData =
          OrderItem.fromJson(orderItem.data() as Map<String, dynamic>);
      orderResultData["orderItems"] = [orderItemData];
      // print("result: ${orderResultData}");
      // print("orderItem: ${orderItemData.productId}");
      return DatabaseOrderResponse.fromJson(orderResultData);
    } catch (e) {
      logger.e(e);
    }
    return null;
  }

  //buyer delete order
  Future<String?> deleteBuyerOrder(String orderID) async {
    try {
      var role = await verifyRole();
      if (role!.keys.contains("Buyer")) {
        await ordersCollection.doc(orderID).set({
          "buyerID": null,
        }, SetOptions(merge: true));

        return "Order deleted successfully";
      } else {
        return "Not authorized to delete this order";
      }
    } catch (e) {
      logger.e("Error deleting order: $e");
      return null;
    }
  }

  Future<String?> pickAndSaveImage(ImageSource source, String imagePath) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return null; // User canceled or no image selected

      final directory = await getApplicationDocumentsDirectory();
      final fileName = basename(image.path); // Extract filename
      final savePath = '$imagePath/$fileName';
      final fullPath = '${directory.path}/$savePath';

      // Ensure the directory exists
      final saveDir = Directory('${directory.path}/$imagePath');
      if (!await saveDir.exists()) {
        await saveDir.create(
            recursive: true); // Create the directory if it doesn't exist
      }

      final bytes = await File(image.path).readAsBytes();
      await File(fullPath).writeAsBytes(bytes);

      return fullPath; // Return the saved image path
    } on PlatformException catch (e) {
      logger.e("Error picking image: $e");
      return null;
    } catch (e) {
      logger.e("Error saving image: $e");
      return null;
    }
  }

  //create local image file first
  Future<List<File>> createLocalImages() async {
    try {
      List<File> compressedImages = [];
      var appDirectoryPath = await getApplicationDocumentsDirectory();

      //pickFiles
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ["png", "jpg", "jpeg"],
      );

      if (result != null) {
        logger.i("result ${result.paths}");
        for (var image in result.files) {
          var targetPath =
              "${appDirectoryPath.path}/compressed_image${Random().nextInt(1000) + 1}.jpg"; // Add closing parenthesis here
          logger.i("targetPath: $targetPath");
          logger.i("image ${image.path}");
          //compress image

          final compressedImage = await FlutterImageCompress.compressAndGetFile(
            image.path!,
            targetPath,
            quality: 85,
            format: CompressFormat.jpeg,
          );

          //convert to file
          final finalImage = File(compressedImage!.path);
          compressedImages.add(finalImage);
        }
      }
      logger.i("compressedImage: $compressedImages");
      return compressedImages;
    } catch (e) {
      logger.e(e);
      return []; // Return an empty list if an error occurs
    }
  }

  //other image uploads
  Future<List<String>> imageUpload(List<File>? images, String imagePath) async {
    List<String> imageUrls = [];

    if (images == null || images.isEmpty) {
      throw Exception('No images provided for upload.');
    }

    try {
      for (File image in images) {
        final storageReference = FirebaseStorage.instance.ref(imagePath);
        final imageReference = storageReference
            .child(currentUser!.uid)
            .child("compressed_image[${Random().nextInt(1000) + 1}].jpg");

        var uploadTask = imageReference.putFile(image);

        // Wait for the upload to complete
        await uploadTask;

        // Get download URL
        String downloadURL = await imageReference.getDownloadURL();

        // Add download URL to list
        imageUrls.add(downloadURL);
      }
      logger.i("image Urls: $imageUrls");
      return imageUrls;
    } catch (e) {
      logger.e(e.toString());
      throw Exception('Failed to upload images: $e');
    }
  }

  Future<String?> deleteImage(
      String downloadUrl, String collection, String id, String fieldName,
      {int? index}) async {
    try {
      String path = downloadUrl.split("o/")[1].split("?")[0];
      String decodedPath = Uri.decodeFull(path);

      // Create a reference to the file you want to delete
      Reference ref = FirebaseStorage.instance.ref().child(decodedPath);

      // Start a Firestore transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Delete the file from Firebase Storage
        await ref.delete();
        logger.i("Image deleted successfully");

        // Reference to the Firestore collection and document
        CollectionReference collectionRef =
            FirebaseFirestore.instance.collection(collection);
        DocumentReference docRef = collectionRef.doc(id);

        // If an index is specified and the collection is 'products',
        // we need to manually remove the element at the specified index
        if (collection == 'products' && index != null) {
          // Read the document to get the current array
          DocumentSnapshot docSnapshot = await docRef.get();
          List<dynamic>? currentArray = docSnapshot.get(fieldName);

          if (currentArray != null &&
              index >= 0 &&
              index < currentArray.length) {
            // Remove the element at the specified index
            currentArray.removeAt(index);

            // Update the document with the modified array
            transaction.update(docRef, {fieldName: currentArray});
            logger
                .i("Value removed from Firestore document at specified index");
          } else {
            logger.i("Index out of bounds or array is null");
          }
        } else if (fieldName == "profile photo") {
          transaction.update(docRef, {fieldName: null});
        } else {
          // Remove the download URL from the specified field
          transaction.update(docRef, {fieldName: FieldValue.delete()});
          logger.i("Download URL removed from Firestore document");
        }
      });
      return "success";
    } on FirebaseException catch (e) {
      // Handle any errors
      logger.e("Error deleting image or updating Firestore document: $e");
    }
    return null;
  }

  //image upload for products
  Future<List<String>> uploadProductImage(List<File>? images) async {
    List<String> imageUrls = [];

    if (images == null || images.isEmpty) {
      throw Exception('No images provided for upload.');
    }

    try {
      for (File image in images) {
        final storageReference = FirebaseStorage.instance.ref("productImage");
        final productImageReference = storageReference
            .child(currentUser!.uid)
            .child("compressed_image[${Random().nextInt(1000) + 1}].jpg");

        var uploadTask = productImageReference.putFile(image);

        // Wait for the upload to complete
        await uploadTask;

        // Get download URL
        String downloadURL = await productImageReference.getDownloadURL();

        // Add download URL to list
        imageUrls.add(downloadURL);
      }
      logger.i("image Urls: $imageUrls");
      return imageUrls;
    } catch (e) {
      logger.e(e.toString());
      throw Exception('Failed to upload images: $e');
    }
  }

  //create product
  Future addProduct({Product? product}) async {
    try {
      //ensure only user with appropriate role can add product
      //get the current user role
      var role = await verifyRole();
      if (role!.keys.contains("Vendor")) {
        //create doc reference
        var productRef = productsCollection.doc();
        String productID = productRef.id;
        //print(productID);
        var productFields = product!.toData();
        productFields["createdAt"] = FieldValue.serverTimestamp();
        productFields["updatedAt"] = FieldValue.serverTimestamp();
        productFields["vendorID"] = role["Vendor"];
        productFields["productID"] = productID;
        // //create a reviews subcollection
        // productsCollection
        //     .doc(productID)
        //     .collection('reviews')
        //     .doc(productID)
        //     .set({});

        //create the actual product
        await productsCollection.doc(productID).set(productFields);
        return "success";
      } else {
        logger.i("Not Authorized");
      }
    } on FirebaseException catch (e) {
      logger.i("Error: ${e.code} and ${e.message}");
    }
  }

  //update product
  Future updateProduct({Product? product}) async {
    try {
      //ensure only user with appropriate role can add product
      //get the current user role
      var role = await verifyRole();
      if (role!.keys.contains("Vendor")) {
        if (role["Vendor"] == product!.vendorId) {
          var updatedFields = {
            "options":
                product.options?.map((option) => option.toData()).toList(),
            "productID": product.productID,
            "name": product.name,
            "category": product.category,
            "specifications":
                product.specifications?.map((spec) => spec.toData()).toList(),
            "isAvailable": product.isAvailable,
            "isDeleted": product.isDeleted,
            "price": product.price,
            "image": List<dynamic>.from(product.image!.map((x) => x)),
            "hasOption": product.hasOptions,
            "allowInstallment": product.allowInstallment,
            "quantity": product.quantity,
            "description": product.description,
            "updatedAt": FieldValue.serverTimestamp(),
          };
          await productsCollection.doc(product.productID).update(updatedFields);
          return 'success';
        } else {
          logger.i('not your product');
        }
      } else {
        logger.i("Not Authorized");
      }
    } on FirebaseException catch (e) {
      logger.e("Error: ${e.code} and ${e.message}");
    }
  }

  //vendor side delete product
  Future vendorSideDeleteProduct(Product product) async {
    try {
      var role = await verifyRole();
      if (role!.keys.contains("Vendor") && role["Vendor"] == product.vendorId) {
        await productsCollection.doc(product.productID).set({
          "isDeleted": true,
        }, SetOptions(merge: true));
        return "success";
      } else {
        logger.i('not authorized');
        return 'not authorized';
      }
    } on FirebaseException catch (e) {
      logger.e("${e.message} ${e.code}");
    }
  }

  // admin delete product
  Future deleteProduct(Product product) async {
    try {
      var role = await verifyRole();
      if (role!.keys.contains("Vendor") && role["Vendor"] == product.vendorId) {
        await productsCollection.doc(product.productID).delete();
        return 'success';
      } else {
        logger.i('not authorized');
        return 'not authorized';
      }
    } on FirebaseException catch (e) {
      logger.e("${e.message} ${e.code}");
    }
  }

  // Convert to Product
  List<Product> convertToProduct(QuerySnapshot<Object?> products) {
    if (products.docs.isEmpty) {
      return [];
    }

    return products.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      //print("${Product.fromdata(data)}).toList()}");
      return Product.fromData(
          data); // Assuming a factory constructor named 'fromData'
    }).toList();
  }

// Fetch products
  Stream<List<Product>> fetchProducts() {
    var stuff = productsCollection.snapshots();
    //print('stuff: $stuff');
    return stuff.map((event) => convertToProduct(event));
  }

  Stream<List<Product>> fetchVerifiedProducts() {
    return vendorsCollection
        .where("isDeleted", isEqualTo: false)
        .where("second verification", isEqualTo: true)
        .snapshots()
        .switchMap((vendorsSnapshot) {
      final vendorIds = vendorsSnapshot.docs.map((doc) => doc.id).toList();

      if (vendorIds.isEmpty) {
        return Stream.value([]);
      }

      // New logic: Check if we need to batch the requests
      if (vendorIds.length <= 30) {
        // If 30 or fewer vendors, use the simple query.
        return productsCollection
            .where("vendorID", whereIn: vendorIds)
            .where("isDeleted", isEqualTo: false)
            .where("isAvailable", isEqualTo: true)
            .snapshots()
            .map(convertToProduct);
      } else {
        // If more than 30 vendors, partition the list and combine streams.

        // Step 1: Partition the IDs into chunks of 30.
        final List<Stream<List<Product>>> productStreams = [];
        for (var i = 0; i < vendorIds.length; i += 30) {
          final chunk = vendorIds.sublist(i, min(i + 30, vendorIds.length));

          // Step 2: Create a product stream for each chunk.
          productStreams.add(
            productsCollection
                .where("vendorID", whereIn: chunk)
                .where("isDeleted", isEqualTo: false)
                .where("isAvailable", isEqualTo: true)
                .snapshots()
                .map(convertToProduct),
          );
        }

        // Step 3: Combine all the product streams into one.
        return CombineLatestStream.list(productStreams)
            // Step 4: Flatten the list of lists into a single list.
            .map((listOfProductLists) {
          return listOfProductLists.expand((products) => products).toList();
        });
      }
    });
  }

  //fetch single product
  Future fetchSingleProduct(dynamic id) async {
    DocumentSnapshot snapshot = await productsCollection.doc(id).get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      Product product = Product.fromData(data);
      return product;
    }
  }

  // get a vendor's products
  Stream<List<Product>> getVendorProducts(String vendorID) async* {
    try {
      var response = productsCollection
          .where('vendorID', isEqualTo: vendorID)
          .orderBy('createdAt')
          .snapshots();

      await for (var event in response) {
        List<Product> products = [];
        for (var doc in event.docs) {
          var data = doc.data() as Map<String, dynamic>;
          products.add(Product.fromData(data));
        }
        yield products;
      }
    } on FirebaseException catch (e) {
      logger.e('FirebaseException: $e');
      rethrow; // Re-throwing the exception to propagate it further
    } catch (e) {
      logger.e('Exception: $e');
      rethrow; // Re-throwing the exception to propagate it further
    }
  }

  //get ,add, edit and delete reviews
  Stream<List<Review?>> getReviews(String productID) {
    try {
      return reviewsCollection
          .where('productID', isEqualTo: productID)
          .snapshots()
          .map((querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          return <Review>[];
        }
        return querySnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return Review.fromData(data);
        }).toList();
      });
    } catch (e) {
      logger.e(e.toString());
      throw Exception(e.toString());
    }
  }

  Stream<List<Review?>> getUserReviews(String userID) {
    // Fetch all products
    try {
      return reviewsCollection
          .where("userID", isEqualTo: userID)
          .snapshots()
          .map((querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          return <Review>[];
        }
        return querySnapshot.docs.map((data) {
          var doc = data.data() as Map<String, dynamic>;
          return Review.fromData(doc);
        }).toList();
      });
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw Exception(e.message);
    }
  }

  Future addAReview(Review review, String productID) async {
    try {
      // Product product = await fetchSingleProduct(productID);

      //create review ref and get its id before creating the review
      var reviewID = reviewsCollection.doc().id;
      await reviewsCollection.doc(reviewID).set({
        "review images": review.reviewImages,
        "display name": review.displayName,
        "userID": review.userID,
        "created at": FieldValue.serverTimestamp(),
        "comment": review.comment,
        "stars": review.stars,
        "reviewID": reviewID,
        "extra info": review.extraInfo,
        "productID": productID,
      });
      return "success";
    } on FirebaseException catch (e) {
      logger.e("Error: ${e.code} and ${e.message}");
    }
  }

  Future editReview(Review review) async {
    try {
      var updatedFields = review.toJson();
      //updatedFields["created at"] = FieldValue.serverTimestamp();
      await reviewsCollection
          .doc(review.reviewID)
          .set(updatedFields, SetOptions(merge: true));
      return "success";
    } on FirebaseException catch (e) {
      logger.e("Error: ${e.code} and ${e.message}");
    } catch (e) {
      logger.e("An unexpected error occurred: $e");
    }
  }

  Future deleteReview(String reviewID) async {
    try {
      final role = await verifyRole();
      if (role!.keys.contains("Buyer")) {
        await reviewsCollection.doc(reviewID).delete();
        return 'success';
      }
    } on FirebaseException catch (e) {
      logger.e("Error: ${e.code} and ${e.message}");
    }
  }

  //payment stuff

  //referral
  //generate referral code
  String generateReferralCode() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(
          random.nextInt(chars.length),
        ),
      ),
    );
  }

  //generate referral link
  String generateReferralLink(String referralCode) {
    // Replace 'your_domain.com' with your actual domain
    return 'https://app.hairmainstreet.com/register?referralCode=$referralCode';
  }

  //generate shop link
  String generateShopLink({
    required String shopName,
    required String vendorID,
  }) {
    // Replace 'your_domain.com' with your actual domain
    final formattedName = shopName.toLowerCase().replaceAll(' ', '_');
    return 'https://app.hairmainstreet.com/shops/$vendorID/$formattedName';
  }

  //confirm referral code and reward referrer
  Future<String> confirmRefCodeAndRewardRef({
    String? referralCode,
    String? referredID,
  }) async {
    try {
      int rewardPointToAdd = 10;
      // Query the userProfileCollection to find the user with the given referral code
      var userQuery = await userProfileCollection
          .where("referral code", isEqualTo: referralCode)
          .get();

      // If the user exists
      if (userQuery.docs.isNotEmpty) {
        var userData = userQuery.docs.first.data() as Map<String, dynamic>;
        String referralID = referralsCollection.doc().id;

        // Create a new referral document
        await referralsCollection
            .doc(userData["uid"])
            .collection("referrals")
            .doc(referralID)
            .set({
          "referralID": referralID,
          "referrerID": userData["uid"],
          "referredID": referredID,
          "timestamp": FieldValue.serverTimestamp(),
        });

        // Start a Firestore transaction to update the referrer's reward points
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentReference docRef = referralsCollection.doc(userData["uid"]);
          DocumentSnapshot snapshot = await transaction.get(docRef);

          int? currentValue =
              (snapshot.data() as Map<String, dynamic>?)?["reward point"] ?? 0;

          // If the current value is 0 or null, set the reward points to 10
          if (currentValue == 0) {
            transaction.set(docRef, {"reward point": 10});
          } else {
            // If the current value is greater than 0, update the reward points by adding 10
            transaction.update(docRef, {
              "reward point": FieldValue.increment(rewardPointToAdd),
            });
          }
        });

        return "success";
      } else {
        return "User not found for the given referral code";
      }
    } on FirebaseException catch (e) {
      // Handle Firebase errors more gracefully
      return "Firebase error: ${e.message}";
    } catch (e) {
      // Handle other errors
      return "Error: $e";
    }
  }

  //get referrals
  Stream<List<Referral>> getReferrals() {
    return referralsCollection
        .doc(currentUser!.uid)
        .collection("referrals")
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Referral.fromJson(doc.data()))
            .toList());
  }

  //get reward points
  Stream<int> getRewardPoints() {
    var snapshot = referralsCollection.doc(currentUser!.uid).snapshots();
    return snapshot.map((event) {
      final data = event.data();
      if (data != null && data is Map<String, dynamic>) {
        return (data["reward point"] as int?) ?? 0;
      } else {
        // Handle the case when data is null or not of the expected type
        return 0; // Or any default value you prefer
      }
    });
  }

  //chats
  Future<String> getOrCreateChat(
      {required String currentUserId, required String otherUserId}) async {
    // Create a sorted list of participant IDs to ensure consistency
    final sortedParticipants = [currentUserId, otherUserId]..sort();

    // Use a composite key approach
    final compositeId = sortedParticipants.join('_');

    // Check if conversation exists
    final conversationDoc = await chatCollection.doc(compositeId).get();

    // If conversation doesn't exist, create it
    if (!conversationDoc.exists) {
      await chatCollection.doc(compositeId).set({
        'participants': sortedParticipants,
        'chatID': compositeId,
      });
    }

    return compositeId;
  }

  Future<String> createChat({
    required List<String> participantIds,
  }) async {
    final conversationRef = chatCollection.doc();
    await conversationRef.set({
      'chatID': conversationRef.id,
      'participants': participantIds,
    });
    return conversationRef.id;
  }

  //get chats
  Stream<List<Chat?>> getAllUserChats(String userID) {
    try {
      var data = chatCollection
          .where('participants', arrayContains: userID)
          .orderBy('recent message sent at', descending: true)
          .snapshots();
      return data.map((doc) {
        var chat = doc.docs.map((chat) {
          if (chat.exists) {
            return Chat.fromJson(chat.data() as Map<String, dynamic>);
          } else {
            return null;
          }
        }).toList();
        return chat;
      });
    } catch (e) {
      logger.e(e);
      return Stream.empty();
    }
  }

  //get a single chat between 2 users
  Stream<List<ChatMessages>> getChatsBetween2Users({
    required String currentUserId,
    required String otherUserId,
  }) async* {
    final sortedParticipants = [currentUserId, otherUserId]..sort();
    final chatId = sortedParticipants.join('_');
    // First, find the existing conversation
    final conversationQuery =
        await chatCollection.where('chatID', isEqualTo: chatId).limit(1).get();

    if (conversationQuery.docs.isEmpty) {
      // No conversation exists, yield an empty list
      yield [];
      return;
    }

    // Get the conversation ID
    final chatID = conversationQuery.docs.first.id;

    // Yield stream of messages for this conversation
    yield* chatCollection
        .doc(chatID)
        .collection('messages')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((chat) {
              return ChatMessages.fromJson(chat.data());
            }).toList());
  }

  //send a message
  Future sendMessage(
      ChatMessages message, String currentUserId, String otherUserId) async {
    try {
      //get or create chat
      String chatID = await getOrCreateChat(
          currentUserId: currentUserId, otherUserId: otherUserId);

      Map<String, dynamic> messageFields = message.toJson();
      Map<String, dynamic> chatFields = {
        "recent message sent by": message.senderID,
        "recent message text": message.content,
        "recent message sent at": message.timestamp,
      };
      //add the message to the database and then update the chat collection
      WriteBatch batch = db.batch();

      DocumentReference chatRef = chatCollection.doc(chatID);
      DocumentReference messageRef = chatCollection
          .doc(chatID)
          .collection('messages')
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      batch.update(chatRef, chatFields);

      batch.set(messageRef, messageFields, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      logger.e(e);
    }
  }

  // //start chat
  // Future startChat(Chat chat, ChatMessages chatMessage) async {
  //   try {
  //     //first check if the chat record exists
  //     Future<Map<String, bool>> chatExists() async {
  //       var data = await chatCollection
  //           .where((Filter.or(
  //             Filter.and(
  //               Filter('member1', isEqualTo: chat.member1),
  //               Filter('member2', isEqualTo: chat.member2),
  //             ),
  //             Filter.and(
  //               Filter('member1', isEqualTo: chat.member2),
  //               Filter('member2', isEqualTo: chat.member1),
  //             ),
  //           )))
  //           .get();
  //       if (data.docs.isNotEmpty) {
  //         var result = data.docs.first.data() as Map<String, dynamic>;
  //         var existingChatID = result["chatID"];
  //         print(existingChatID);
  //         return {existingChatID: true};
  //       } else {
  //         return {"": false};
  //       }
  //     }

  //     var check = await chatExists();
  //     var fields = {
  //       "content": chatMessage.content,
  //       "id To": chatMessage.idTo,
  //       "id From": chatMessage.idFrom,
  //       "timestamp": FieldValue.serverTimestamp(),
  //     };
  //     if (check.values.contains(false)) {
  //       var chatID = chatCollection.doc().id;

  //       //create chat record first
  //       var chatFields = {
  //         "chatID": chatID,
  //         "member1": chat.member1,
  //         "member2": chat.member2,
  //         "recent message sent at": FieldValue.serverTimestamp(),
  //         "recent message sent by": chat.recentMessageSentBy,
  //         "recent message text": chat.recentMessageText,
  //         "read by": chat.readBy,
  //       };

  //       await chatCollection.doc(chatID).set(chatFields);
  //       //create message subcollection
  //       return await chatCollection
  //           .doc(chatID)
  //           .collection('messages')
  //           .doc(DateTime.now().millisecondsSinceEpoch.toString())
  //           .set(fields);
  //     } else {
  //       var chatFields = {
  //         "chatID": check.keys.first,
  //         "member1": chat.member1,
  //         "member2": chat.member2,
  //         "recent message sent at": FieldValue.serverTimestamp(),
  //         "recent message sent by": chat.recentMessageSentBy,
  //         "recent message text": chat.recentMessageText,
  //         "read by": chat.readBy,
  //       };

  //       await chatCollection
  //           .doc(check.keys.first)
  //           .set(chatFields, SetOptions(merge: true));
  //       return await chatCollection
  //           .doc(check.keys.first)
  //           .collection('messages')
  //           .doc(DateTime.now().millisecondsSinceEpoch.toString())
  //           .set(fields);
  //     }
  //   } on FirebaseException catch (e) {
  //     logger.e(e);
  //   }
  // }

  // //get chats
  // Stream<List<ChatMessages?>?> getChats(String member1, String member2) async* {
  //   Future<Map<String, bool>> chatExists() async {
  //     var data = await chatCollection
  //         .where((Filter.or(
  //           Filter.and(
  //             Filter('member1', isEqualTo: member1),
  //             Filter('member2', isEqualTo: member2),
  //           ),
  //           Filter.and(
  //             Filter('member1', isEqualTo: member2),
  //             Filter('member2', isEqualTo: member1),
  //           ),
  //         )))
  //         .get();

  //     if (data.docs.isNotEmpty) {
  //       var result = data.docs.first.data() as Map<String, dynamic>;
  //       var existingChatID = result["chatID"];
  //       return {existingChatID: true};
  //     } else {
  //       return {"": false};
  //     }
  //   }

  //   var check = await chatExists();
  //   if (check.values.contains(true)) {
  //     var result = chatCollection
  //         .doc(check.keys.first)
  //         .collection('messages')
  //         .orderBy('timestamp', descending: true)
  //         .snapshots();
  //     await for (var event in result) {
  //       //print(event.docs.map((e) => ChatMessages.fromJson(e.data())).toList());
  //       yield event.docs.map((e) => ChatMessages.fromJson(e.data())).toList();
  //     }
  //   } else {
  //     // Instead of yielding null, yield an empty list
  //     yield [];
  //   }
  // }

  // //get specific user chats
  // Stream<List<Chat>> getUserChats(String userID) {
  //   return chatCollection
  //       .where(Filter.or(
  //         Filter("member1", isEqualTo: userID),
  //         Filter("member2", isEqualTo: userID),
  //       ))
  //       .snapshots()
  //       .map(
  //         (querySnapshot) => querySnapshot.docs.map((doc) {
  //           // print(doc.data());
  //           return Chat.fromJson(doc.data() as Map<String, dynamic>);
  //         }).toList(),
  //       );
  // }

  // add and remove from wishlist and get wishList

  Stream<List<WishlistItem>> fetchWishListItems() async* {
    try {
      var role = await verifyRole();
      // Check if the user has the "Buyer" role
      if (role != null && role.keys.contains("Buyer") ||
          role!.keys.contains("Vendor")) {
        var result = userProfileCollection
            .doc(currentUser!.uid)
            .collection("wishlist")
            .snapshots();

        // Yield the mapped data as a stream
        await for (var event in result) {
          if (event.docs.isEmpty) {
            yield <WishlistItem>[];
          } else {
            yield event.docs.map((data) {
              var doc = data.data();
              return WishlistItem.fromJson(doc);
            }).toList();
          }
        }
      }
    } catch (e) {
      logger.e(e);
      throw Exception(e.toString());
    }
  }

  Future<bool> isProductInWishlist(String productID) async {
    if (currentUser != null) {
      var result = await userProfileCollection
          .doc(currentUser!.uid)
          .collection('wishlist')
          .doc(productID)
          .get();
      return result.exists;
    } else {
      return false;
    }
  }

  Future<String?> addToWishList(WishlistItem wishlistItem) async {
    try {
      var role = await verifyRole();
      if (role != null &&
          (role.keys.contains('Buyer') ||
              role.keys.contains(
                'Vendor',
              ))) {
        var item = await itemExists(
          wishlistItem.wishListItemID,
          currentUser!.uid,
          'wishlist',
          fieldName: 'wishListItemID',
        );
        if (item != null) {
          return 'exists';
        } else {
          await userProfileCollection
              .doc(currentUser!.uid)
              .collection("wishlist")
              .doc(wishlistItem.wishListItemID)
              .set({
            "wishListItemID": wishlistItem.wishListItemID,
            "createdAt": FieldValue.serverTimestamp(),
          });
          return 'new';
        }
      } else {
        return "not authorized"; // Or a specific value to indicate that the user doesn't have 'Buyer' role.
      }
    } on FirebaseException catch (e) {
      logger.e("Error: ${e.code} and ${e.message}");
      rethrow; // Re-throw the exception to inform the caller about the error.
    }
  }

  Future removeFromWishList(List<String> wishListItemIDs) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final WriteBatch batch = firestore.batch();

      for (String wishlistID in wishListItemIDs) {
        DocumentReference productRef = userProfileCollection
            .doc(currentUser!.uid)
            .collection('wishlist')
            .doc(wishlistID);
        batch.delete(productRef);
      }

      // Commit the batch
      await batch.commit();
      return 'success';
    } on FirebaseException catch (e) {
      logger.e("Error: ${e.code} and ${e.message}");
    }
  }

  //remove from wishlist with productID
  Future removeFromWishlistWithProductID(String productID) async {
    try {
      var role = await verifyRole();
      if (role != null && role.keys.contains('Buyer')) {
        await userProfileCollection
            .doc(currentUser!.uid)
            .collection("wishlist")
            .doc(productID)
            .delete();

        return "success";
      } else {
        return "not authorized"; // Or a specific value to indicate that the user doesn't have 'Buyer' role.
      }
    } on FirebaseException catch (e) {
      logger.e("Error: ${e.code} and ${e.message}");
    } catch (e) {
      logger.e(e);
    }
  }

  //become a seller
  Future becomeASeller(Vendors vendor) async {
    try {
      var result = await userProfileCollection.doc(vendor.userID).get();
      if (result.exists) {
        //create a vendor collection for them
        var resultSnapshot = result.data() as Map<String, dynamic>;
        var userID = resultSnapshot["uid"];
        var shopLink = generateShopLink(
          shopName: vendor.shopName!,
          vendorID: userID,
        );
        Map<String, dynamic> fields = vendor.todata();
        fields["shop link"] = shopLink;
        fields["created at"] = FieldValue.serverTimestamp();
        fields["userID"] = userID;
        fields["installment duration"] = null;
        fields["first verification"] = false;
        fields["second verification"] = false;
        await vendorsCollection.doc(userID).set(fields);

        // update their isVendor tag
        var data = result.data() as Map<String, dynamic>;
        if (data['isVendor'] == false) {
          await userProfileCollection
              .doc(currentUser!.uid)
              .update({"isVendor": true});
        }
        return 'success';
      }
    } on FirebaseException catch (e) {
      logger.e(e);
    }
  }

  //check if wallet exists
  Future<String?> checkIfWalletExists(String userID) async {
    var response = await walletCollection.doc(userID).get();
    if (response.exists) {
      return "exists";
    }
    return null;
  }

  //handle things wallet i.e create and update wallet and transactions
  void updateWalletAfterOrderPlacement(
      String userID, int amount, String description, String type) async {
    // Retrieve the user's wallet document reference
    DocumentReference walletRef = walletCollection.doc(userID);

    //check if wallet for user already exists
    if (await checkIfWalletExists(userID) != null) {
      if (type == 'credit') {
        // Update the wallet balance (assuming it's a credit)
        await walletRef.update({
          'userID': userID,
          'balance': FieldValue.increment(amount),
        });
      } else if (type == 'debit') {
        // Update the wallet balance (assuming it's a debit)
        await walletRef.update({
          'userID': userID,
          'balance': FieldValue.increment(-amount),
        });
      }
    } else {
      if (type == 'credit') {
        // Update the wallet balance (assuming it's a credit)
        await walletRef.set({
          'userID': userID,
          'balance': FieldValue.increment(amount),
          'withdrawable balance': "0",
        });
      } else if (type == 'debit') {
        // Update the wallet balance (assuming it's a debit)
        await walletRef.set({
          'userID': userID,
          'balance': FieldValue.increment(-amount),
        });
      }
    }

    // Add a transaction record
    var transactionID = walletRef.collection('transactions').doc().id;
    await walletRef.collection('transactions').doc(transactionID).set(
      {
        'transaction ID': transactionID,
        'amount': amount,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'description': description,
      },
    );
  }

  //get wallet balance and get transactions list
  //get wallet balance
  Stream<Wallet> getWalletBalance(String userID) {
    return walletCollection
        .doc(userID)
        .snapshots()
        .map((event) => Wallet.fromJson(event.data() as Map<String, dynamic>));
  }

  //get transactions list and details
  Stream<List<Transactions>> getTransactions(String userID) {
    return walletCollection
        .doc(userID)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((event) {
      if (event.docs.isEmpty) {
        return <Transactions>[];
      } else {
        return event.docs
            .map((doc) => Transactions.fromJson(doc.data()))
            .toList();
      }
    });
  }

  // request withdrawal
  Future requestWithdrawal(WithdrawalRequest withdrawalRequest) async {
    Map<String, dynamic> withdrawalRequestFields = withdrawalRequest.toJson();
    withdrawalRequestFields['created at'] = FieldValue.serverTimestamp();
    var requestID = withdrawalRequestCollection.doc().id;
    withdrawalRequestFields['requestID'] = requestID;
    try {
      await withdrawalRequestCollection
          .doc(requestID)
          .set(withdrawalRequestFields, SetOptions(merge: true));
      return "success";
    } on FirebaseException catch (e) {
      logger.e(e.message);
    } catch (e) {
      logger.e(e);
    }
  }

  //get vendor withdrawal requests
  Stream<List<WithdrawalRequest>> getWithdrawalRequests(String userId) {
    var result = withdrawalRequestCollection
        .where('userID', isEqualTo: userId)
        .snapshots();
    return result.map(
      (event) => event.docs
          .map(
            (doc) =>
                WithdrawalRequest.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  //verify transaction from paystack
  Future<bool> verifyTransaction({
    required String reference,
  }) async {
    String? secretKey = dotenv.env['PAYSTACK_SECRET_KEY'];
    final url = "https://api.paystack.co/transaction/verify/$reference";
    var response = await http
        .get(Uri.parse(url), headers: {"Authorization": "Bearer $secretKey"});

    if (response.statusCode == 200) {
      var body = response.body;
      if (body.isNotEmpty) {
        final data = jsonDecode(body);
        logger.i(data);
        return data["status"];
      } else {
        logger.i("Response body is empty");
        return false;
      }
    } else {
      logger.e("Request failed with status: ${response.statusCode}");
      return false;
    }
  }

  //get notifications
  Stream<List<Notifications>> getNotifications() {
    var result = notificationsCollection
        .doc(currentUser!.uid)
        .collection("notifications")
        .orderBy("time stamp", descending: true)
        .snapshots();
    return result.map((event) {
      return event.docs.map((doc) {
        return Notifications.fromJson(doc.data());
      }).toList();
    });
  }

  //refund and cancellation stuff
  //refund request
  Future submitRefundRequest(RefundRequest refundRequest) async {
    try {
      var role = await verifyRole();
      if (role != null && role.containsKey('Buyer')) {
        Map<String, dynamic> refundRequestFields = refundRequest.toJson();
        refundRequestFields['created at'] = FieldValue.serverTimestamp();
        refundRequestFields['refund status'] = "pending";
        String requestID = refundsCollection.doc().id;
        refundRequestFields['requestID'] = requestID;
        await refundsCollection.doc(requestID).set(refundRequestFields);
        return "success";
      } else {
        return "not authorized";
      }
    } on FirebaseException catch (e) {
      logger.e(e.message);
    } catch (e) {
      logger.e(e);
    }
  }

  //cancellation request
  Future submitOrderCancellationRequest(
      CancellationRequest cancellationRequest) async {
    try {
      var role = await verifyRole();
      if (role != null && role.containsKey("Buyer")) {
        Map<String, dynamic> cancellationFields = cancellationRequest.toJson();
        cancellationFields['created at'] = FieldValue.serverTimestamp();
        cancellationFields['cancellation status'] = "pending";
        String requestID = cancellationCollection.doc().id;
        cancellationFields['requestID'] = requestID;
        await cancellationCollection.doc(requestID).set(cancellationFields);
        // Optionally, you can also update the order status in the orders collection
        await ordersCollection.doc(cancellationRequest.orderID).update({
          'order status': 'cancelled',
        });
        return "success";
      } else {
        return "not authorized";
      }
    } on FirebaseException catch (e) {
      logger.e(e.message);
    } catch (e) {
      logger.e(e);
    }
  }

  //get refund requests

  //get cancellation requests

  //get categories from admin
  Stream<List<String>> getCategories() {
    return adminVariablesCollection
        .doc("admin")
        .snapshots()
        .map((DocumentSnapshot snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('categories')) {
        final categoryList = List<String>.from(data['categories']);
        return categoryList;
      }
      return [];
    });
  }

  Future<String?> initiateTransaction(
      num amount, String email, String reference,
      {required bool isLive}) async {
    final num resolvedAmount = amount;
    final String resolvedEmail = email;
    const String callbackUrl = "https://api-hhhpti4wta-uc.a.run.app/";

    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('initiateTransaction');
    try {
      final response = await callable.call(<String, dynamic>{
        'amount': resolvedAmount,
        'email': resolvedEmail,
        'callbackUrl': callbackUrl,
        'reference': reference,
        'isLive': isLive,
      });

      final String accessCode = response.data['accessCode'];
      logger.i('Access Code: $accessCode');
      // Use the access code for further processing
      return accessCode;
    } catch (e) {
      logger.e('Error: $e');
    }
    return null;
  }
}
