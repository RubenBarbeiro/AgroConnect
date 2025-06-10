import 'package:uuid/uuid.dart';

abstract class UserModel {
  final String userId;
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

  UserModel({
    String? userId,
    required this.name,
    this.phoneNumber,
    required this.imagePath,
    required this.isSupplier,
    required this.email,
    this.allowLocationServices = false,
    this.userRating = 0.0,
    this.isActive = true,
    required this.city,
    required this.parish,
    required this.postalCode,
    required this.primaryDeliveryAddress,
    this.preferredShoppingRadius = 15,
    DateTime? createdAt,
    this.updatedAt,
  })  : createdAt = DateTime.now(),
    userId = const Uuid().v4();

  Map<String, dynamic> toJson() => {};

  factory UserModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented by subclasses');
  }



}