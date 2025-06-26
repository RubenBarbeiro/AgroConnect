import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agroconnect/logic/cart_state.dart';
import 'package:agroconnect/models/orders.dart';
import 'package:agroconnect/models/product_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> createOrder({
    required List<CartItem> cartItems,
    required double subtotal,
    required double deliveryFee,
    required double total,
    required String deliveryAddress,
    required String paymentMethod,
    String? promoCode,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final orderItems = cartItems.map((item) => OrderItem(
        productId: item.product.productId,
        productName: item.product.productName,
        origin: item.product.origin,
        unitPrice: item.product.unitPrice,
        quantity: item.quantity,
        totalPrice: item.totalPrice,
        category: item.product.productCategory.name,
      )).toList();

      final order = Order(
        id: '',
        userId: user.uid,
        userEmail: user.email ?? '',
        items: orderItems,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        promoCode: promoCode,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        rating: null,
      );

      final docRef = await _firestore.collection('orders').add(order.toFirestore());
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<List<Order>> getUserOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      final orders = querySnapshot.docs
          .map((doc) => Order.fromQuerySnapshot(doc))
          .toList();

      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    } catch (e) {
      return [];
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) return Order.fromFirestore(doc);
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<Order?> getOrderStream(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) => doc.exists ? Order.fromFirestore(doc) : null);
  }

  Stream<List<Order>> getUserOrdersStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Order.fromQuerySnapshot(doc))
        .toList());
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateOrderStatusEnum(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateProductRatings(Order order, double newRating) async {
    try {
      final batch = _firestore.batch();
      final productIds = order.items.map((item) => item.productId).toSet();

      for (final productId in productIds) {
        if (productId.isEmpty) continue;

        final productDoc = await _firestore.collection('products').doc(productId).get();
        if (!productDoc.exists) continue;

        final productData = productDoc.data()!;
        final currentReviewCount = productData['reviewCount'] ?? 0;
        final currentTotalRatingValue = (productData['totalRatingValue'] ?? 0.0).toDouble();

        final newReviewCount = currentReviewCount + 1;
        final newTotalRatingValue = currentTotalRatingValue + newRating;
        final newAverageRating = newTotalRatingValue / newReviewCount;

        final productRef = _firestore.collection('products').doc(productId);
        batch.update(productRef, {
          'rating': newAverageRating,
          'reviewCount': newReviewCount,
          'totalRatingValue': newTotalRatingValue,
          'lastRatingUpdate': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addOrderRating(String orderId, double rating) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) return false;
      if (order.status != 'delivered') return false;
      if (order.rating != null) return false;

      final orderRating = OrderRating(
        rating: rating,
        ratedAt: DateTime.now(),
      );

      await _firestore.collection('orders').doc(orderId).update({
        'rating': orderRating.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updateSuccess = await _updateProductRatings(order, rating);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) return false;

      if (!['pending', 'confirmed'].contains(order.status)) return false;

      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserOrderStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      final orders = querySnapshot.docs
          .map((doc) => Order.fromQuerySnapshot(doc))
          .toList();

      final ratedOrders = orders.where((o) => o.rating != null).toList();

      double avgRating = 0;
      if (ratedOrders.isNotEmpty) {
        avgRating = ratedOrders.fold<double>(
            0, (sum, order) => sum + order.rating!.rating
        ) / ratedOrders.length;
      }

      return {
        'totalOrders': orders.length,
        'totalSpent': orders.fold<double>(0, (sum, order) => sum + order.total),
        'completedOrders': orders.where((o) => o.status == 'delivered').length,
        'pendingOrders': orders.where((o) => o.status == 'pending').length,
        'ratedOrders': ratedOrders.length,
        'avgRating': avgRating,
      };
    } catch (e) {
      return {};
    }
  }

  Future<double> getServiceAverageRating() async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('rating', isNotEqualTo: null)
          .get();

      final ratedOrders = querySnapshot.docs
          .map((doc) => Order.fromQuerySnapshot(doc))
          .where((order) => order.rating != null)
          .toList();

      if (ratedOrders.isEmpty) return 0.0;

      final totalRating = ratedOrders.fold<double>(
          0, (sum, order) => sum + order.rating!.rating
      );

      return totalRating / ratedOrders.length;
    } catch (e) {
      return 0.0;
    }
  }
}