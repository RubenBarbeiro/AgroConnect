import 'dart:convert';

import 'package:agroconnect/models/product_categories_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ProductModel  {
  final String productId;
  final String createdUserId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final ProductCategoriesEnum productCategory;

  ProductModel(
      String? productId,
      this.createdUserId,
      this.productName,
      this.unitPrice,
      this.quantity,
      this.totalPrice,
      this.productCategory
  ): productId = Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'createdUserId': createdUserId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'productCategoriesEnum': productCategory.toString(),
    };
  }

  static ProductModel fromJson(Map<String, dynamic> json) {
    return ProductModel(
      json['productId'],
      json['createdUserId'],
      json['productName'],
      json['unitPrice'].toDouble(),
      json['quantity'],
      json['totalPrice'].toDouble(),
      ProductCategoriesEnum.values.firstWhere(
            (e) => e.toString() == json['productCategory'],
      ),
    );
  }

  Future createProductDoc (String productId, String createdUserId,
      String productName, double unitPrice, int quantity, double totalPrice,
      ProductCategoriesEnum productCategory) async {

    final product = ProductModel(
        productId,
        createdUserId,
        productName,
        unitPrice,
        quantity,
        totalPrice,
        productCategory
    );

    await FirebaseFirestore.instance.collection('products').doc(productId)
      .set(product.toJson());
  }
}
