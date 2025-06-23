import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agroconnect/logic/cart_state.dart';

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

      // Create order document
      final orderData = {
        'userId': user.uid,
        'userEmail': user.email,
        'items': cartItems.map((item) => {
          'productId': item.id,
          'productName': item.product.productName,
          'origin': item.product.origin,
          'unitPrice': item.product.unitPrice,
          'quantity': item.quantity,
          'totalPrice': item.totalPrice,
          'category': item.product.productCategory.name,
        }).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': total,
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
        'promoCode': promoCode,
        'status': 'pending', // pending, confirmed, preparing, shipped, delivered, cancelled
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('orders').add(orderData);

      // Update user's order history
      await _updateUserOrderHistory(user.uid, docRef.id);

      // Update producer notifications (optional)
      await _notifyProducers(cartItems, docRef.id);

      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Update user's order history
  Future<void> _updateUserOrderHistory(String userId, String orderId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'orderHistory': FieldValue.arrayUnion([orderId]),
        'lastOrderDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user order history: $e');
    }
  }

  // Notify producers about new orders
  Future<void> _notifyProducers(List<CartItem> cartItems, String orderId) async {
    try {
      // Group items by producer (origin)
      Map<String, List<CartItem>> itemsByProducer = {};
      for (var item in cartItems) {
        String producer = item.product.origin;
        if (!itemsByProducer.containsKey(producer)) {
          itemsByProducer[producer] = [];
        }
        itemsByProducer[producer]!.add(item);
      }

      // Create notifications for each producer
      for (var entry in itemsByProducer.entries) {
        String producer = entry.key;
        List<CartItem> items = entry.value;

        await _firestore.collection('producer_notifications').add({
          'producerName': producer,
          'orderId': orderId,
          'items': items.map((item) => {
            'productName': item.product.productName,
            'quantity': item.quantity,
            'totalPrice': item.totalPrice,
          }).toList(),
          'status': 'new',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error notifying producers: $e');
    }
  }

  // Get user's orders
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error fetching user orders: $e');
      return [];
    }
  }

  // Update order status
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

  // Get order by ID
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  // Stream for real-time order updates
  Stream<Map<String, dynamic>?> getOrderStream(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    });
  }
}