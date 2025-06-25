import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/controllers/vendor_controller.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:hair_main_street/models/vendors_model.dart';
import 'package:hair_main_street/pages/search_page.dart';

class MySearchDelegate extends SearchDelegate<String> {
  @override
  TextStyle? get searchFieldStyle => TextStyle(
        fontFamily: "Raleway",
        fontSize: 16,
        color: Colors.black.withValues(alpha: 0.60),
        fontWeight: FontWeight.w500,
      );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        color: Colors.black,
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 20,
      ),
      onPressed: () {
        close(context, "null");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchPage(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    ProductController productController = Get.find<ProductController>();
    List<dynamic> suggestions = [];

    if (query == '') {
      return const SizedBox.shrink();
    } else {
      var products = productController.products;
      var vendors = productController.vendorsList;

      // Filter products and vendors based on the query and create a list of suggestions
      List<Product?> productSuggestions = products
          .where((product) =>
              product!.name!.toLowerCase().contains(query.toLowerCase()))
          .toList();
      List<Vendors?> vendorSuggestions = vendors
          .where((vendor) =>
              vendor!.shopName!.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Flatten the list of lists into a single list of suggestions
      suggestions = [...productSuggestions, ...vendorSuggestions];

      if (suggestions.isEmpty) {
        return const SizedBox.shrink();
      }

      return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          String suggestionReturn() {
            if (suggestions[index] is Product) {
              return (suggestions[index] as Product).name!;
            } else {
              return (suggestions[index] as Vendors).shopName!;
            }
          }

          return ListTile(
            title: Text(suggestionReturn()),
            onTap: () {
              // When a suggestion is tapped, update the query and display the results.
              query = suggestionReturn();
              showResults(context);
            },
          );
        },
      );
    }
  }
}

class VendorProductSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        color: Colors.black,
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: () {
        close(context, "null");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchPage(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    VendorController vendorController = Get.find<VendorController>();
    List<dynamic> suggestions = [];

    if (query == '') {
      return const SizedBox.shrink();
    } else {
      var products = vendorController.productList;

      // Filter products and vendors based on the query and create a list of suggestions
      List<Product?> productSuggestions = products
          .where((product) =>
              product.name!.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Flatten the list of lists into a single list of suggestions
      suggestions = [...productSuggestions];

      if (suggestions.isEmpty) {
        return const SizedBox.shrink();
      }

      return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          String suggestionReturn() {
            if (suggestions[index] is Product) {
              return (suggestions[index] as Product).name!;
            } else {
              return (suggestions[index] as Vendors).shopName!;
            }
          }

          return ListTile(
            title: Text(suggestionReturn()),
            onTap: () {
              // When a suggestion is tapped, update the query and display the results.
              query = suggestionReturn();
              showResults(context);
            },
          );
        },
      );
    }
  }
}
