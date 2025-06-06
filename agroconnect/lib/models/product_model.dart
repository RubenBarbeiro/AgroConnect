import 'package:agroconnect/models/product_categories_enum.dart';
import 'package:uuid/uuid.dart';

class ProductModel  {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final ProductCategoriesEnum productCategory;

  ProductModel(
      this.productName,
      this.unitPrice,
      this.quantity,
      this.totalPrice,
      this.productCategory
  ): productId = Uuid().v4();

}
