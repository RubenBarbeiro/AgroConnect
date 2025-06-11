import 'dart:convert';

import 'package:agroconnect/models/product_categories_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ProductModel  {
  final String productId;
  final String createdUserId;
  final String productName;
  final String description;
  final String origin;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final int deliveryTime;
  final double rating;
  final ProductCategoriesEnum productCategory;

  ProductModel(
      String? productId,
      this.createdUserId,
      this.productName,
      this.description,
      this.origin,
      this.unitPrice,
      this.quantity,
      this.totalPrice,
      this.deliveryTime,
      this.rating,
      this.productCategory
      ): productId = productId ?? Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'createdUserId': createdUserId,
      'productName': productName,
      'description': description,
      'origin': origin,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'deliveryTime': deliveryTime,
      'rating': rating,
      'productCategory': productCategory.toString(),
    };
  }

  static ProductModel fromJson(Map<String, dynamic> json) {
    return ProductModel(
      json['productId'],
      json['createdUserId'],
      json['productName'],
      json['description'],
      json['origin'],
      json['unitPrice'].toDouble(),
      json['quantity'],
      json['totalPrice'].toDouble(),
      json['deliveryTime'],
      json['rating'].toDouble(),
      ProductCategoriesEnum.values.firstWhere(
            (e) => e.toString() == json['productCategory'],
      ),
    );
  }

  Future createProductDoc (String productId, String createdUserId,
      String productName, String description, String origin, double unitPrice,
      int quantity, int stock, double totalPrice, int deliveryTime, double rating,
      ProductCategoriesEnum productCategory) async {

    final product = ProductModel(
        productId,
        createdUserId,
        productName,
        description,
        origin,
        unitPrice,
        quantity,
        totalPrice,
        deliveryTime,
        rating,
        productCategory
    );

    await FirebaseFirestore.instance.collection('products').doc(productId)
        .set(product.toJson());
  }
}