import 'dart:convert';
import 'dart:ui';

import 'package:agroconnect/models/product_categories_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ProductModel  {
  final String productId;
  final String createdUserId;
  final String productName;
  final String productImage;
  final String description;
  final String origin;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final int deliveryTime;
  final double rating;
  double productRadius;
  final ProductCategoriesEnum productCategory;
  DateTime productExpirationDate;

  ProductModel(
      String? productId,
      this.createdUserId,
      this.productName,
      this.productImage,
      this.description,
      this.origin,
      this.unitPrice,
      this.quantity,
      this.totalPrice,
      this.deliveryTime,
      this.rating,
      this.productRadius,
      this.productCategory,
      DateTime? productExpirationDate,
      ): productId = productId ?? Uuid().v4(),
        productExpirationDate = productExpirationDate ?? DateTime(DateTime.now().year,(DateTime.now().month + 1), DateTime.now().day);

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'createdUserId': createdUserId,
      'productName': productName,
      'productImage' : productImage.toString(),
      'description': description,
      'origin': origin,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'deliveryTime': deliveryTime,
      'rating': rating,
      'productRadius': productRadius,
      'productCategory': productCategory.toString(),
      'productExpirationDate' : productExpirationDate.toString(),
    };
  }

  static ProductModel fromJson(Map<String, dynamic> json) {
    return ProductModel(
      json['productId'],
      json['createdUserId'],
      json['productName'],
      json['description'],
      json['productImage'],
      json['origin'],
      json['unitPrice'].toDouble(),
      json['quantity'],
      json['totalPrice'].toDouble(),
      json['deliveryTime'],
      json['rating'].toDouble(),
      json['productRadius'],
      ProductCategoriesEnum.values.firstWhere(
            (e) => e.toString() == json['productCategory'],
      ),
      json['productExpirationDate'],
    );
  }

  DateTime getExpirationDate () {
    return productExpirationDate;
  }

  void updateExpirationDate () {
    productExpirationDate = DateTime(
        DateTime.now().year,
        (DateTime.now().month + 1),
        DateTime.now().day
    );
  }

  void setProductRadius (double radius) {
    productRadius = radius;
  }

  Future createProductDoc (String productId, String createdUserId,
      String productName,String productImage, String description, String origin, double unitPrice,
      int quantity, int stock, double totalPrice, int deliveryTime, double rating,
      double productRadius, ProductCategoriesEnum productCategory,
      DateTime productExpirationDate) async {

    final product = ProductModel(
        productId,
        createdUserId,
        productName,
        productImage,
        description,
        origin,
        unitPrice,
        quantity,
        totalPrice,
        deliveryTime,
        rating,
        productRadius,
        productCategory,
        productExpirationDate,
    );

    await FirebaseFirestore.instance.collection('products').doc(productId)
        .set(product.toJson());
  }
}