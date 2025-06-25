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
    if (item != null) {
      if(newRadiusFlag) {
        item.productRadius += 1;
      } else {
        item.productRadius -= 1;
      }
      item.isChanged = true;
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
