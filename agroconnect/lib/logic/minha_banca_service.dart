import 'package:agroconnect/models/client_model.dart';
import 'package:agroconnect/models/product_model.dart';
import 'package:agroconnect/models/product_radius_model.dart';
import 'package:agroconnect/models/supplier_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class MinhaBancaService extends ChangeNotifier {
  final List<ProductRadiusModel> productsRadius = [];
  final List<ProductModel> userProducts = [];
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ProductRadiusModel> get items => productsRadius;
  List<ProductModel> get products => userProducts;
  bool get isLoading => _isLoading;

  // Inicializar com produtos do usuário logado
  Future<void> initializeUserProducts() async {
    if (_auth.currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final products = await fetchUserProducts(_auth.currentUser!.uid);
      userProducts.clear();
      userProducts.addAll(products);

      // Inicializar os radius com os produtos carregados
      initializeFromProducts(products);
    } catch (e) {
      print('Erro ao carregar produtos do usuário: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buscar produtos do usuário logado
  Future<List<ProductModel>> fetchUserProducts(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('createdUserId', isEqualTo: userId)
          .get();

      List<ProductModel> products = [];
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          products.add(ProductModel.fromJson(data));
        } catch (e) {
          print('Erro ao converter produto: $e');
          continue;
        }
      }

      return products;
    } catch (e) {
      print('Erro ao buscar produtos: $e');
      return [];
    }
  }

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

  Future<SupplierModel?> fetchSupplierById(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('suppliers')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return SupplierModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar supplier: $e');
      return null;
    }
  }

  ProductRadiusModel? getItem(String productId) {
    try {
      return productsRadius.firstWhere((item) => item.getProductId() == productId);
    } catch (e) {
      return null;
    }
  }

  void updateRadius(String productId, bool newRadiusFlag) {
    final item = getItem(productId);
    if (item != null) {
      item.isChanged = true;
      if (newRadiusFlag) {
        item.productRadius += 0.5;
        item.productRadius = double.parse(item.productRadius.toStringAsFixed(2));
      } else if (item.productRadius > 0.5) {
        if (item.productRadius - 0.5 < 0.5) {
          item.productRadius = 0.5;
        } else {
          item.productRadius -= 0.5;
          item.productRadius = double.parse(item.productRadius.toStringAsFixed(2));
        }
      }
      notifyListeners();
    }
  }

  List<ProductRadiusModel> get changedProducts {
    return productsRadius.where((item) => item.isChanged).toList();
  }

  // Atualizar produtos com radius alterados no Firebase
  Future<void> updateChangedRadius() async {
    if (_auth.currentUser == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final changedItems = changedProducts;

      for (var item in changedItems) {
        final productRef = FirebaseFirestore.instance
            .collection('products')
            .doc(item.productId);

        batch.update(productRef, {
          'productRadius': item.productRadius,
        });

        // Marcar como não alterado após atualizar
        item.isChanged = false;
      }

      await batch.commit();

      // Atualizar produtos locais também
      for (var product in userProducts) {
        final changedItem = changedItems.firstWhere(
              (item) => item.productId == product.productId,
          orElse: () => null as ProductRadiusModel,
        );
        if (changedItem != null) {
          product.setProductRadius(changedItem.productRadius);
        }
      }

      notifyListeners();
      print('Radius dos produtos atualizados com sucesso!');
    } catch (e) {
      print('Erro ao atualizar radius dos produtos: $e');
      // Reativar o flag de alteração em caso de erro
      for (var item in changedProducts) {
        item.isChanged = true;
      }
    }
  }

  // Adicionar um novo produto
  Future<bool> addProduct(ProductModel product) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.productId)
          .set(product.toJson());

      userProducts.add(product);
      productsRadius.add(ProductRadiusModel(
        productId: product.productId,
        productRadius: product.productRadius,
      ));

      notifyListeners();
      return true;
    } catch (e) {
      print('Erro ao adicionar produto: $e');
      return false;
    }
  }

  // Remover um produto
  Future<bool> removeProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();

      userProducts.removeWhere((product) => product.productId == productId);
      productsRadius.removeWhere((item) => item.productId == productId);

      notifyListeners();
      return true;
    } catch (e) {
      print('Erro ao remover produto: $e');
      return false;
    }
  }

  // Recarregar produtos
  Future<void> refreshProducts() async {
    await initializeUserProducts();
  }
}