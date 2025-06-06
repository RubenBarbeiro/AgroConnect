import 'package:agroconnect/models/user_model.dart';

class SupplierModel extends UserModel {

  int numberOfSales;

  SupplierModel(
    super.phoneNumber,
    super.updatedAt,
    super.allowLocationServices,
    {
      required super.name,
      required super.imagePath,
      super.isSupplier = true,
      required super.email,
      required super.city,
      required super.parish,
      required super.postalCode,
      required super.primaryDeliveryAddress,
      this.numberOfSales = 0,
    }
  );


}
