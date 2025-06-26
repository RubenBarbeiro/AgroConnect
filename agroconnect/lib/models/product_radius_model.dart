class ProductRadiusModel {
  final String productId;
  double productRadius;
  bool isChanged;

  ProductRadiusModel({
    required this.productId,
    required this.productRadius,
    this.isChanged = false
  });

  String getProductId() {
    return productId;
  }
}