import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agroconnect/logic/cart_state.dart';
import 'package:agroconnect/models/orders.dart';
import 'package:agroconnect/models/product_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new order in Firebase
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
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create order items from cart items
      final orderItems = cartItems.map((item) => OrderItem(
        productId: item.product.productId,
        productName: item.product.productName,
        origin: item.product.origin,
        unitPrice: item.product.unitPrice,
        quantity: item.quantity,
        totalPrice: item.totalPrice,
        category: item.product.productCategory.name,
      )).toList();

      // Create order
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
      print('Order created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
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
      print('Error fetching user orders: $e');
      return [];
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return Order.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  Stream<Order?> getOrderStream(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return Order.fromFirestore(doc);
      }
      return null;
    });
  }

  Stream<List<Order>> getUserOrdersStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

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
      print('Error updating order status: $e');
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
      print('Error updating order status: $e');
      return false;
    }
  }

  // NEW IMPROVED RATING SYSTEM
  Future<bool> _updateProductRatings(Order order, double newRating) async {
    try {
      final batch = _firestore.batch();
      final productIds = order.items.map((item) => item.productId).toSet();

      print('Updating ratings for products: $productIds with rating: $newRating');

      for (final productId in productIds) {
        if (productId.isEmpty) {
          print('Warning: Empty product ID found in order ${order.id}');
          continue;
        }

        // Get current product data
        final productDoc = await _firestore.collection('products').doc(productId).get();

        if (!productDoc.exists) {
          print('Warning: Product $productId not found');
          continue;
        }

        final productData = productDoc.data()!;
        final currentReviewCount = productData['reviewCount'] ?? 0;
        final currentTotalRatingValue = (productData['totalRatingValue'] ?? 0.0).toDouble();

        // Calculate new values
        final newReviewCount = currentReviewCount + 1;
        final newTotalRatingValue = currentTotalRatingValue + newRating;
        final newAverageRating = newTotalRatingValue / newReviewCount;

        print('Product $productId: Reviews: $currentReviewCount -> $newReviewCount, Total: $currentTotalRatingValue -> $newTotalRatingValue, Average: $newAverageRating');

        // Update product with new rating data
        final productRef = _firestore.collection('products').doc(productId);
        batch.update(productRef, {
          'rating': newAverageRating,
          'reviewCount': newReviewCount,
          'totalRatingValue': newTotalRatingValue,
          'lastRatingUpdate': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('Product ratings updated successfully');
      return true;
    } catch (e) {
      print('Error updating product ratings: $e');
      return false;
    }
  }

  Future<bool> addOrderRating(String orderId, double rating) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) {
        print('Order not found');
        return false;
      }

      if (order.status != 'delivered') {
        print('Order must be delivered to be rated');
        return false;
      }

      if (order.rating != null) {
        print('Order already has a rating');
        return false;
      }

      print('Adding rating $rating to order $orderId');

      final orderRating = OrderRating(
        rating: rating,
        ratedAt: DateTime.now(),
      );

      // Update order with rating
      await _firestore.collection('orders').doc(orderId).update({
        'rating': orderRating.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update product ratings using new system
      final updateSuccess = await _updateProductRatings(order, rating);

      if (updateSuccess) {
        print('Rating added successfully to order $orderId and product ratings updated');
      } else {
        print('Rating added to order $orderId but product rating update failed');
      }

      return true;
    } catch (e) {
      print('Error adding rating: $e');
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) {
        print('Order not found');
        return false;
      }

      if (!['pending', 'confirmed'].contains(order.status)) {
        print('Cannot cancel order. Order cannot be cancelled in current status: ${order.status}');
        return false;
      }

      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error cancelling order: $e');
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
      print('Error fetching user order stats: $e');
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
      print('Error calculating service average rating: $e');
      return 0.0;
    }
  }
}