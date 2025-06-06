import 'package:agroconnect/models/product_model.dart';
import 'package:agroconnect/models/transaction_status_enum.dart';
import 'package:uuid/uuid.dart';

class TransactionModel {

  final String id;
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
  ): id = Uuid().v4(),
    createdAt = DateTime.now();


}
