import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  dynamic productID;
  bool? allowInstallment;
  Timestamp? createdAt;
  String? description;
  String? category;
  bool? isDeleted;
  bool? isAvailable;
  bool? hasOptions; // Renamed from hasOption
  List<dynamic>? image;
  String? name;
  int? price;
  int? quantity;
  Timestamp? updatedAt;
  dynamic vendorId;
  List<ProductSpecification>? specifications;
  List<ProductOption>? options; // New field for options

  Product({
    this.productID,
    this.allowInstallment,
    this.createdAt,
    this.description,
    this.hasOptions,
    this.category,
    this.image,
    this.name,
    this.specifications,
    this.isAvailable,
    this.isDeleted,
    this.price,
    this.quantity,
    this.updatedAt,
    this.vendorId,
    this.options, // New parameter for options
  });

  factory Product.fromData(Map<String, dynamic> data) {
    final List<dynamic>? images = data["image"];
    final List<dynamic>? optionsData = data["options"]; // Get options data
    final List<dynamic>? specifications = data["specifications"];

    return Product(
      productID: data["productID"],
      allowInstallment: data["allowInstallment"],
      category: data["category"],
      createdAt: data["createdAt"],
      description: data["description"],
      hasOptions: data["hasOption"],
      image: images != null ? List<dynamic>.from(images.map((x) => x)) : [],
      name: data["name"],
      isAvailable: data["isAvailable"],
      isDeleted: data["isDeleted"],
      specifications: specifications
          ?.map((spec) => ProductSpecification.fromJson(spec))
          .toList(),
      price: data["price"],
      quantity: data["quantity"],
      updatedAt: data["updatedAt"],
      vendorId: data["vendorID"],
      options: optionsData
          ?.map((option) => ProductOption.fromData(option))
          .toList(), // Convert options data to ProductOption instances
    );
  }

  Map<String, dynamic> toData() {
    return {
      "allowInstallment": allowInstallment,
      "createdAt": createdAt,
      "description": description,
      "category": category,
      "hasOption": hasOptions,
      "specifications": specifications?.map((spec) => spec.toData()).toList(),
      "image": List<dynamic>.from(image!.map((x) => x)),
      "name": name,
      "price": price,
      "isDeleted": isDeleted,
      "isAvailable": isAvailable,
      "quantity": quantity,
      "updatedAt": updatedAt,
      "vendorID": vendorId,
      "options": options
          ?.map((option) => option.toData())
          .toList(), // Convert ProductOption instances to data
    };
  }
}

class ProductOption {
  String? length;
  String? color;
  num? price;
  int? stockAvailable;
  // Add any other fields related to options here

  ProductOption({
    this.length,
    this.color,
    this.price,
    this.stockAvailable,
  });

  factory ProductOption.fromData(Map<String, dynamic> data) {
    return ProductOption(
        length: data["length"],
        price: data["price"],
        color: data["color"],
        stockAvailable: data['stock available']
        // Initialize other fields from data
        );
  }

  Map<String, dynamic> toData() {
    return {
      "length": length,
      "color": color,
      "price": price,
      "stock available": stockAvailable,
      // Add other fields to map
    };
  }
}

class ProductSpecification {
  String? title;
  String? specification;

  ProductSpecification({this.title, this.specification});

  factory ProductSpecification.fromJson(Map<String, dynamic> json) =>
      ProductSpecification(
        title: json["title"],
        specification: json["specification"],
      );

  Map<String, dynamic> toData() {
    return {
      "title": title,
      "specification": specification,
    };
  }
}
