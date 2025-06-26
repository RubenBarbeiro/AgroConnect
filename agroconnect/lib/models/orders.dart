import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final String userEmail;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String deliveryAddress;
  final String paymentMethod;
  final String? promoCode;
  late final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OrderRating? rating;
  bool isDeliveredClient;
  bool isDeliveredSupplier;

  Order({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.promoCode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.isDeliveredClient = false,
    this.isDeliveredSupplier = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'items': items.map((item) => item.toFirestore()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'promoCode': promoCode,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'rating': rating?.toFirestore(),
      'isDeliveredClient': isDeliveredClient,
      'isDeliveredSupplier': isDeliveredSupplier,
    };
  }

  void changeDeliveredStatus(String userType) {
    if (userType == 'client') {
      isDeliveredClient = true;
    } else {
      isDeliveredSupplier = true;
    }
    if (isDeliveredClient && isDeliveredSupplier) {
      status = OrderStatus.delivered as String;
    }
  }

  factory Order.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw Exception('Document data is null');

    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromFirestore(item as Map<String, dynamic>))
          .toList() ??
          [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      deliveryAddress: data['deliveryAddress'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      promoCode: data['promoCode'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rating: data['rating'] != null
          ? OrderRating.fromFirestore(data['rating'] as Map<String, dynamic>)
          : null,
    );
  }

  factory Order.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromFirestore(item as Map<String, dynamic>))
          .toList() ??
          [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      deliveryAddress: data['deliveryAddress'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      promoCode: data['promoCode'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rating: data['rating'] != null
          ? OrderRating.fromFirestore(data['rating'] as Map<String, dynamic>)
          : null,
    );
  }

  Order copyWith({
    String? id,
    String? userId,
    String? userEmail,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    String? deliveryAddress,
    String? paymentMethod,
    String? promoCode,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    OrderRating? rating,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      promoCode: promoCode ?? this.promoCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
    );
  }

  String get orderNumber => '#${id.substring(0, 8).toUpperCase()}';
  bool get isRecent => DateTime.now().difference(createdAt).inHours < 24;
  bool get canBeRated => status == 'delivered' && rating == null;
  bool get isRated => rating != null;
  double get averageRating => rating?.rating ?? 0.0;

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FFA726';
      case 'confirmed':
        return '#42A5F5';
      case 'preparing':
        return '#AB47BC';
      case 'shipping':
        return '#26C6DA';
      case 'delivered':
        return '#66BB6A';
      case 'cancelled':
        return '#EF5350';
      default:
        return '#9E9E9E';
    }
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}

class OrderItem {
  final String productId;
  final String productName;
  final String origin;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final String category;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.origin,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.category,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'origin': origin,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'category': category,
    };
  }

  factory OrderItem.fromFirestore(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      origin: data['origin'] ?? '',
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 0,
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      category: data['category'] ?? '',
    );
  }

  OrderItem copyWith({
    String? productId,
    String? productName,
    String? origin,
    double? unitPrice,
    int? quantity,
    double? totalPrice,
    String? category,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      origin: origin ?? this.origin,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      category: category ?? this.category,
    );
  }

  String get formattedUnitPrice => '€${unitPrice.toStringAsFixed(2)}';
  String get formattedTotalPrice => '€${totalPrice.toStringAsFixed(2)}';
}

class OrderRating {
  final double rating;
  final DateTime ratedAt;

  OrderRating({
    required this.rating,
    required this.ratedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'rating': rating,
      'ratedAt': Timestamp.fromDate(ratedAt),
    };
  }

  factory OrderRating.fromFirestore(Map<String, dynamic> data) {
    return OrderRating(
      rating: (data['rating'] ?? 0).toDouble(),
      ratedAt: (data['ratedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  OrderRating copyWith({
    double? rating,
    DateTime? ratedAt,
  }) {
    return OrderRating(
      rating: rating ?? this.rating,
      ratedAt: ratedAt ?? this.ratedAt,
    );
  }

  String get starDisplay {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;

    String stars = '★' * fullStars;
    if (hasHalfStar) stars += '☆';

    return stars;
  }

  bool get isGoodRating => rating >= 4.0;
}

class Message {
  final String id;
  final String text;
  final String senderId;
  final String receiverId;
  final String senderType;
  final String receiverType;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.senderType,
    required this.receiverType,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderType': senderType,
      'receiverType': receiverType,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  factory Message.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw Exception('Document data is null');

    return Message(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      senderType: data['senderType'] ?? '',
      receiverType: data['receiverType'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  factory Message.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    return Message(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      senderType: data['senderType'] ?? '',
      receiverType: data['receiverType'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Message copyWith({
    String? id,
    String? text,
    String? senderId,
    String? receiverId,
    String? senderType,
    String? receiverType,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderType: senderType ?? this.senderType,
      receiverType: receiverType ?? this.receiverType,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  String getConversationId() {
    List<String> participants = [
      '${senderType}_$senderId',
      '${receiverType}_$receiverId'
    ];
    participants.sort();
    return participants.join('_');
  }

  bool isSentByUser(String currentUserId, String currentUserType) {
    return senderId == currentUserId && senderType == currentUserType;
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  shipping,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'A Preparar';
      case OrderStatus.shipping:
        return 'A Enviar';
      case OrderStatus.delivered:
        return 'Entregue';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'shipping':
        return OrderStatus.shipping;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}