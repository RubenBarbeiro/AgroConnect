import 'package:uuid/uuid.dart';

abstract class UserModel {
  final String id;
  final String name;
  final String imagePath;
  final double userRating;
  final String email;
  final String? phoneNumber;
  final bool isSupplier;

  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  final String? city;
  final String? parish;
  final String? postalCode;

  final String? primaryDeliveryAddress;

  final double preferredShoppingRadius;

  final bool allowLocationServices;

  UserModel(
    this.phoneNumber,
    this.updatedAt,
    this.allowLocationServices, {
    required this.name,
    required this.imagePath,
    required this.isSupplier,
    required this.email,
    this.userRating = 0.0,
    this.isActive = true,
    required this.city,
    required this.parish,
    required this.postalCode,
    required this.primaryDeliveryAddress,
    this.preferredShoppingRadius = 15,
      }) : createdAt = DateTime.now(),
        id = Uuid().v4();


}