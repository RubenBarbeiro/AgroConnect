import 'package:agroconnect/models/product_model.dart';
import 'package:agroconnect/models/transaction_status_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class TransactionModel {

  final String transactionId;
  final String clientId;
  final String supplierId;
  final List<ProductModel> products;
  final double totalAmount;
  final DateTime? deliveredDate;
  final DateTime? completedDate;
  final TransactionStatusEnum status;
  final String? deliveryAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionModel(
      this.clientId,
      this.supplierId,
      this.products,
      this.totalAmount,
      this.deliveredDate,
      this.completedDate,
      this.status,
      this.deliveryAddress,
      this.updatedAt,
  ): transactionId = Uuid().v4(),
    createdAt = DateTime.now();

  Map<String, dynamic> toJson() {
    return{
      'transactionId': transactionId,
      'clientId': clientId,
      'supplierId': supplierId,
      'products': products.map((product) => product.toJson()).toList(),
      'totalAmount': totalAmount,
      'deliveredDate' : deliveredDate,
      'completedDate': completedDate,
      'status': status.toString(),
      'deliveryAddress': deliveryAddress,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static TransactionModel fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      json['clientId'],
      json['supplierId'],
      (json['products'] as List)
          .map((productJson) => ProductModel.fromJson(productJson))
          .toList(), // Fixed products parsing
      json['totalAmount'].toDouble(),
      json['deliveredDate'] != null
          ? DateTime.parse(json['deliveredDate'])
          : null,
      json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      TransactionStatusEnum.values.firstWhere(
            (e) => e.toString() == json['status'],
      ), // Fixed enum parsing
      json['deliveryAddress'],
      json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Future createTransactionDoc (String transactionId, String clientId,
      String supplierId, List<ProductModel> products, double totalAmount,
      DateTime? deliveredDate, DateTime? completedDate, TransactionStatusEnum status,
      String? deliveryAddress, DateTime createdAt, DateTime? updatedAt) async {


    final transaction = TransactionModel(
        clientId,
        supplierId,
        products,
        totalAmount,
        deliveredDate,
        completedDate,
        status,
        deliveryAddress,
        updatedAt
    );

    await FirebaseFirestore.instance.collection('transactions')
        .doc(transactionId).set(transaction.toJson());

  }
}
