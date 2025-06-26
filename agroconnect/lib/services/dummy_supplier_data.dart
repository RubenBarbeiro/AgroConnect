import 'package:agroconnect/models/supplier_model.dart';

class DummySupplierData {
  late SupplierModel supplier1;
  late SupplierModel supplier2;
  late SupplierModel supplier3;
  late List<SupplierModel> suppliers;

  DummySupplierData() {
    _generateDummySuppliers();
    _initData();
  }

  void _generateDummySuppliers() {
    supplier1 = SupplierModel(
      phoneNumber: '+351917654321',
      updatedAt: null,
      name: 'Mercado Verde',
      imagePath: 'assets/supplier-images/mercadoverde.jpg',
      email: 'info@mercadoverde.pt',
      city: 'Sesimbra',
      parish: 'Santiago',
      postalCode: '2970-001',
      primaryDeliveryAddress: 'Rua do Mercado, 45',
      userId: 'mercado_verde',
      createdAt: DateTime.now().subtract(Duration(days: 180)),
      numberOfSales: 247,
    );

    supplier2 = SupplierModel(
      phoneNumber: '+351924567890',
      updatedAt: null,
      name: 'Quinta da Colina',
      imagePath: 'assets/supplier-images/quinta_colina.jpg',
      email: 'vendas@quintacolina.pt',
      city: 'Palmela',
      parish: 'Quinta do Anjo',
      postalCode: '2950-001',
      primaryDeliveryAddress: 'Estrada Nacional 379, Km 12',
      userId: 'quinta_colina',
      createdAt: DateTime.now().subtract(Duration(days: 95)),
      numberOfSales: 142,
    );

    supplier3 = SupplierModel(
      phoneNumber: '+351935678901',
      updatedAt: null,
      name: 'Horta do Tomás',
      imagePath: 'assets/supplier-images/horta_tomas.jpg',
      email: 'tomas@hortadotomas.pt',
      city: 'Setúbal',
      parish: 'São Julião',
      postalCode: '2900-001',
      primaryDeliveryAddress: 'Rua das Hortaliças, 78',
      userId: 'horta_tomas',
      createdAt: DateTime.now().subtract(Duration(days: 45)),
      numberOfSales: 89,
    );
  }

  void _initData() {
    suppliers = [supplier1, supplier2, supplier3];
  }

  List<SupplierModel> getSuppliers() {
    return suppliers;
  }

  SupplierModel getSupplierById(String userId) {
    return suppliers.firstWhere((supplier) => supplier.userId == userId);
  }

  List<SupplierModel> getSuppliersByCity(String city) {
    return suppliers.where((supplier) => supplier.city == city).toList();
  }

  Future<void> saveSuppliersToFirebase() async {
    for (SupplierModel supplier in suppliers) {
      try {
        await supplier.createSupplierDoc(
          supplier.userId!,
          supplier.name,
          supplier.imagePath!,
          0.0,
          supplier.email!,
          supplier.phoneNumber!,
          supplier.city!,
          supplier.parish!,
          supplier.postalCode!,
          supplier.primaryDeliveryAddress!,
          supplier.createdAt!,
        );
      } catch (e) {
        print('Error saving supplier ${supplier.name}: $e');
      }
    }
  }
}