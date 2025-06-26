import 'package:agroconnect/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClientModel extends UserModel {
  ClientModel({
    required super.name,
    super.phoneNumber,
    required super.imagePath,
    super.isSupplier = false,
    required super.email,
    required super.city,
    required super.parish,
    required super.postalCode,
    required super.primaryDeliveryAddress,
    required super.userId,
    required super.createdAt,
    super.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'imagePath': imagePath,
      'phoneNumber': phoneNumber,
      'city': city,
      'parish': parish,
      'postalCode': postalCode,
      'primaryDeliveryAddress': primaryDeliveryAddress,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'allowLocationServices': allowLocationServices,
      'userRating': userRating,
      'isSupplier': isSupplier,
      'isActive': isActive,
      'preferredShoppingRadius': preferredShoppingRadius,
    };
  }

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      phoneNumber: json['phoneNumber'],
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : DateTime.tryParse(json['updatedAt'].toString()))
          : null,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.tryParse(json['createdAt'].toString()))
          : DateTime.now(),
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      imagePath: json['imagePath'] ?? '',
      email: json['email'] ?? '',
      city: json['city'],
      parish: json['parish'],
      postalCode: json['postalCode'],
      primaryDeliveryAddress: json['primaryDeliveryAddress'],
    );
  }

  Future createClientDoc(String userId, String name, String imagePath,
      double userRating, String email, String? phoneNumber, String? city,
      String? parish, String? postalCode, String? primaryDeliveryAddress,
      DateTime createdAt) async {
    final client = ClientModel(
      userId: userId,
      phoneNumber: phoneNumber,
      createdAt: createdAt,
      updatedAt: updatedAt,
      name: name,
      imagePath: imagePath,
      email: email,
      city: city,
      parish: parish,
      postalCode: postalCode,
      primaryDeliveryAddress: primaryDeliveryAddress,
    );

    await FirebaseFirestore.instance
        .collection('clients')
        .doc(client.userId)
        .set(client.toJson());
  }
}

Future<ClientModel?> fetchClientById(String userId) async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('clients')
        .doc(userId)
        .get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      return ClientModel.fromJson(data);
    } else {
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser?.email != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('clients')
            .where('email', isEqualTo: currentUser!.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final data = querySnapshot.docs.first.data() as Map<String, dynamic>;

          await FirebaseFirestore.instance
              .collection('clients')
              .doc(userId)
              .set({...data, 'userId': userId});

          return ClientModel.fromJson({...data, 'userId': userId});
        }
      }

      currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final newClient = ClientModel(
          userId: userId,
          name: currentUser.displayName ?? 'Utilizador',
          email: currentUser.email ?? '',
          imagePath: '',
          city: '',
          parish: '',
          postalCode: '',
          primaryDeliveryAddress: '',
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('clients')
            .doc(userId)
            .set(newClient.toJson());

        return newClient;
      }

      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<void> createClientIfNotExists(String userId, String name, String email) async {
  try {
    final existingClient = await fetchClientById(userId);
    if (existingClient == null) {
      final newClient = ClientModel(
        userId: userId,
        name: name,
        email: email,
        imagePath: '',
        city: '',
        parish: '',
        postalCode: '',
        primaryDeliveryAddress: '',
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('clients')
          .doc(userId)
          .set(newClient.toJson());
    }
  } catch (e) {}
}