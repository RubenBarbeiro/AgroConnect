import 'package:flutter/material.dart';
import 'package:agroconnect/models/product_model.dart';

class CartItem {
  final String id;
  final ProductModel product;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.unitPrice * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  List<CartItem> get cartItems => _items.values.toList();

  int get itemCount => _items.length;

  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => subtotal >= 10.0 ? 0.0 : 2.5;

  double get total => subtotal + deliveryFee;

  bool get isEmpty => _items.isEmpty;

  void addItem(ProductModel product, int quantity) {
    // Use the actual product ID instead of concatenating name + origin
    final productId = product.productId;

    if (_items.containsKey(productId)) {
      // Update existing item quantity
      _items[productId]!.quantity += quantity;
    } else {
      // Add new item
      _items[productId] = CartItem(
        id: productId, // Use actual product ID
        product: product,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  void updateQuantity(String itemId, int newQuantity) {
    if (_items.containsKey(itemId)) {
      if (newQuantity <= 0) {
        _items.remove(itemId);
      } else {
        _items[itemId]!.quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _items.remove(itemId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(ProductModel product) {
    // Use actual product ID for checking
    final productId = product.productId;
    return _items.containsKey(productId);
  }

  int getQuantityInCart(ProductModel product) {
    // Use actual product ID for getting quantity
    final productId = product.productId;
    return _items[productId]?.quantity ?? 0;
  }
}