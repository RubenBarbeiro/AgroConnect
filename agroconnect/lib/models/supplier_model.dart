import 'package:agroconnect/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierModel extends UserModel {

  int numberOfSales;

  //TODO: atualizar os metodos a buscar valor da super
  SupplierModel({
      required super.name,
      super.phoneNumber,
      super.updatedAt,
      required super.imagePath,
      super.isSupplier = false,
      required super.email,
      required super.city,
      required super.parish,
      required super.postalCode,
      required super.primaryDeliveryAddress,
      required super.userId,
      required super.createdAt,
      this.numberOfSales = 0,
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

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
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
      numberOfSales: json['numberOfSales'],
    );
  }

  Future createSupplierDoc (String userId, String name, String imagePath,
      double userRating, String email, String phoneNumber, String city,
      String parish, String postalCode, String primaryDeliveryAddress,
      DateTime createdAt) async {

    final newDocUser = FirebaseFirestore.instance.collection('suppliers').doc();
    final supplier = SupplierModel(
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
      numberOfSales: numberOfSales,
    );
    await newDocUser.set(supplier.toJson());
  }
}
