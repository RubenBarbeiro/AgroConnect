import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agroconnect/logic/cart_state.dart';
import 'package:agroconnect/models/orders.dart';

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
      //final user = _auth.currentUser;
      final user = 'placeholder';
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create order items from cart items
      final orderItems = cartItems.map((item) => OrderItem(
        productId: item.id ?? '', // Handle null case
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
        //userId: user.uid,
        userId: 'placeholder',
        //userEmail: user.email ?? '',
        userEmail: 'email',
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
      );

      // Save to Firestore using the new toFirestore method
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
      final user = 'placeholder';
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: 'placeholder')
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

  // Get order by ID
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

  // Stream for real-time order updates
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

  // Stream for user's orders with real-time updates
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

  // Update order status (for admin/producer use)
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

  // Update order status using enum (type-safe version)
  Future<bool> updateOrderStatusEnum(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.name, // Uses the enum name (e.g., 'pending', 'confirmed')
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Get orders by status
  Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Order.fromQuerySnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching orders by status: $e');
      return [];
    }
  }

  // Get recent orders (within 24 hours)
  Future<List<Order>> getRecentOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final yesterday = DateTime.now().subtract(const Duration(hours: 24));

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(yesterday))
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Order.fromQuerySnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching recent orders: $e');
      return [];
    }
  }

  // Cancel order (if allowed)
  Future<bool> cancelOrder(String orderId) async {
    try {
      // Check if order can be cancelled (e.g., not yet shipped)
      final order = await getOrderById(orderId);
      if (order == null) return false;

      final currentStatus = OrderStatus.fromString(order.status);
      if (currentStatus == OrderStatus.shipping ||
          currentStatus == OrderStatus.delivered ||
          currentStatus == OrderStatus.cancelled) {
        print('Order cannot be cancelled in current status: ${order.status}');
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

  // Get order statistics for user
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

      return {
        'totalOrders': orders.length,
        'totalSpent': orders.fold<double>(0, (sum, order) => sum + order.total),
        'completedOrders': orders.where((o) => o.status == 'delivered').length,
        'pendingOrders': orders.where((o) => o.status == 'pending').length,
        'recentOrders': orders.where((o) => o.isRecent).length,
      };
    } catch (e) {
      print('Error fetching user order stats: $e');
      return {};
    }
  }
}