import 'dart:convert';
import 'dart:ui';
import 'package:agroconnect/models/product_categories_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ProductModel {
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
  final int reviewCount;
  final double totalRatingValue;
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
      this.reviewCount,
      this.totalRatingValue,
      this.productCategory,
      DateTime? productExpirationDate,
      ) : productId = productId ?? const Uuid().v4(),
        productExpirationDate = productExpirationDate ??
            DateTime(DateTime.now().year, DateTime.now().month + 1, DateTime.now().day);

  double get averageRating {
    if (reviewCount == 0) return 0.0;
    return totalRatingValue / reviewCount;
  }

  ProductModel addRating(double newRating) {
    final newReviewCount = reviewCount + 1;
    final newTotalRatingValue = totalRatingValue + newRating;
    final newAverageRating = newTotalRatingValue / newReviewCount;

    return ProductModel(
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
      newAverageRating,
      productRadius,
      newReviewCount,
      newTotalRatingValue,
      productCategory,
      productExpirationDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'createdUserId': createdUserId,
      'productName': productName,
      'productImage': productImage,
      'description': description,
      'origin': origin,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'deliveryTime': deliveryTime,
      'rating': rating,
      'productRadius': productRadius,
      'reviewCount': reviewCount,
      'totalRatingValue': totalRatingValue,
      'productCategory': productCategory.toString(),
      'productExpirationDate': productExpirationDate.toIso8601String(),
    };
  }

  static ProductModel fromJson(Map<String, dynamic> json) {
    return ProductModel(
      json['productId'],
      json['createdUserId'],
      json['productName'],
      json['productImage'],
      json['description'],
      json['origin'],
      (json['unitPrice'] is int) ? (json['unitPrice'] as int).toDouble() : json['unitPrice']?.toDouble() ?? 0.0,
      json['quantity'] ?? 0,
      (json['totalPrice'] is int) ? (json['totalPrice'] as int).toDouble() : json['totalPrice']?.toDouble() ?? 0.0,
      json['deliveryTime'] ?? 0,
      (json['rating'] is int) ? (json['rating'] as int).toDouble() : json['rating']?.toDouble() ?? 0.0,
      (json['productRadius'] is int) ? (json['productRadius'] as int).toDouble() : json['productRadius']?.toDouble() ?? 0.0,
      json['reviewCount'] ?? 0,
      (json['totalRatingValue'] is int) ? (json['totalRatingValue'] as int).toDouble() : json['totalRatingValue']?.toDouble() ?? 0.0,
      ProductCategoriesEnum.values.firstWhere(
            (e) => e.toString() == json['productCategory'],
        orElse: () => ProductCategoriesEnum.values.first, // Fallback para evitar erro
      ),
      json['productExpirationDate'] != null
          ? DateTime.parse(json['productExpirationDate'])
          : null,
    );
  }

  DateTime getExpirationDate() {
    return productExpirationDate;
  }

  void updateExpirationDate() {
    productExpirationDate = DateTime(
      DateTime.now().year,
      DateTime.now().month + 1,
      DateTime.now().day,
    );
  }

  void setProductRadius(double radius) {
    productRadius = radius;
  }

  Future<void> createProductDoc(
      String productId,
      String createdUserId,
      String productName,
      String productImage,
      String description,
      String origin,
      double unitPrice,
      int quantity,
      double totalPrice,
      int deliveryTime,
      double rating,
      double productRadius,
      ProductCategoriesEnum productCategory,
      DateTime productExpirationDate,
      ) async {
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
      0,
      0.0,
      productCategory,
      productExpirationDate,
    );

    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .set(product.toJson());
  }

  // Método copyWith para facilitar atualizações imutáveis
  ProductModel copyWith({
    String? productId,
    String? createdUserId,
    String? productName,
    String? productImage,
    String? description,
    String? origin,
    double? unitPrice,
    int? quantity,
    double? totalPrice,
    int? deliveryTime,
    double? rating,
    double? productRadius,
    int? reviewCount,
    double? totalRatingValue,
    ProductCategoriesEnum? productCategory,
    DateTime? productExpirationDate,
  }) {
    return ProductModel(
      productId ?? this.productId,
      createdUserId ?? this.createdUserId,
      productName ?? this.productName,
      productImage ?? this.productImage,
      description ?? this.description,
      origin ?? this.origin,
      unitPrice ?? this.unitPrice,
      quantity ?? this.quantity,
      totalPrice ?? this.totalPrice,
      deliveryTime ?? this.deliveryTime,
      rating ?? this.rating,
      productRadius ?? this.productRadius,
      reviewCount ?? this.reviewCount,
      totalRatingValue ?? this.totalRatingValue,
      productCategory ?? this.productCategory,
      productExpirationDate ?? this.productExpirationDate,
    );
  }

  @override
  String toString() {
    return 'ProductModel{productId: $productId, productName: $productName, unitPrice: $unitPrice, quantity: $quantity}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ProductModel &&
              runtimeType == other.runtimeType &&
              productId == other.productId;

  @override
  int get hashCode => productId.hashCode;
}