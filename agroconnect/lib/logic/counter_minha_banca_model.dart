import 'package:agroconnect/models/product_model.dart';
import 'package:agroconnect/models/product_radius_model.dart';
import 'package:flutter/cupertino.dart';

class CounterMinhaBancaModel extends ChangeNotifier {
  final List<ProductRadiusModel> productsRadius = [];

  List<ProductRadiusModel> get items => productsRadius;

  void initializeFromProducts(List<ProductModel> products) {
    productsRadius.clear();
    for (var product in products) {
      productsRadius.add(ProductRadiusModel(
        productId: product.productId,
        productRadius: product.productRadius,
      ));
    }
    notifyListeners();
  }

  ProductRadiusModel? getItem(String productId){
    try{
      return productsRadius.firstWhere((item) => item.getProductId() == productId);
    } catch (e) {
      return null;
    }
  }

  void updateRadius (String productId, bool newRadiusFlag) {
    final item = getItem(productId);
    if (item != null ) {
      item.isChanged = true;
      if(newRadiusFlag) {
        item.productRadius += 0.5;
        item.productRadius = double.parse(item.productRadius.toStringAsFixed(2));
      } else if (item.productRadius > 0.5) {
        if(item.productRadius - 0.5 < 0.5) {
          item.productRadius = 0.5;
          return;
        }
        item.productRadius -= 0.5;
        item.productRadius = double.parse(item.productRadius.toStringAsFixed(2));
      }
      notifyListeners();
    }
  }

  List<ProductRadiusModel> get changedProducts {
    return productsRadius.where((item) => item.isChanged).toList();
  }

  void updateChangedRadius () {
    //todo atualizar produtos mudados de acordo com produtos associados ao utilizador
  }

}
