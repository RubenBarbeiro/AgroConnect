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
      'userId' : userId,
      'name': name,
      'email': email,
      'imagePath': imagePath,
      'phoneNumber': phoneNumber,
      'city': city,
      'parish': parish,
      'postalCode': postalCode,
      'primaryDeliveryAddress': primaryDeliveryAddress,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'allowLocationServices': allowLocationServices,
    };
  }

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      phoneNumber: json['phoneNumber'],
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'])
          : null,
      createdAt: json['createdAt'],
      userId: json['userId'],
      name: json['name'],
      imagePath: json['imagePath'],
      email: json['email'],
      city: json['city'],
      parish: json['parish'],
      postalCode: json['postalCode'],
      primaryDeliveryAddress: json['primaryDeliveryAddress'],
    );
  }

  Future createClientDoc (String userId, String name, String imagePath,
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

    await FirebaseFirestore.instance.collection('clients')
        .doc(client.userId).set(client.toJson());
  }
}

Future<ClientModel?> fetchClientById(String userId) async {
  print('1');
  DocumentSnapshot doc = await FirebaseFirestore.instance
      .collection('clients')
      .doc(userId)
      .get();
  print('2');
  if (doc.exists) {
    print('3');
    return ClientModel.fromJson(doc.data() as Map<String, dynamic>);
  } else {
    return null;
  }
}