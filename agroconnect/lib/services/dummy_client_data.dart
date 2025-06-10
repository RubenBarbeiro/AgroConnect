import 'package:agroconnect/models/client_model.dart';

class DummyClientData {

  // Define the individual clients as fields
  late ClientModel client1;
  late ClientModel client2;
  late ClientModel client3;
  late ClientModel client4;  // Add missing client fields
  late ClientModel client5;
  late ClientModel client6;
  late ClientModel client7;
  late ClientModel client8;
  late ClientModel client9;
  late ClientModel client10;

  late List<ClientModel> clients;

  DummyClientData() {  // Fixed constructor name
    _generateDummyClients();
    _initData(); // builds the list using those clients
  }

  void _generateDummyClients() {  // Added void return type

    // Assign to class fields, not local variables
    client1 = ClientModel(
        phoneNumber: '+351912345678',
        updatedAt: null,
        name: 'João Silva',
        imagePath: 'assets/images/client1.jpg',
        email: 'joao@email.com',
        city: 'Lisboa',
        parish: 'Alvalade',
        postalCode: '1700-001',
        primaryDeliveryAddress: 'Rua das Flores, 123',
        userId: null,
        createdAt: null
    );

    client2 = ClientModel(
        phoneNumber: '+351923456789',
        updatedAt: null,
        name: 'Maria Santos',
        imagePath: 'assets/images/client2.jpg',
        email: 'maria@email.com',
        city: 'Porto',
        parish: 'Cedofeita',
        postalCode: '4050-001',
        primaryDeliveryAddress: 'Avenida Central, 456',
        userId: null,
        createdAt: null
    );

    client3 = ClientModel(
      phoneNumber: '+351912345678',
      updatedAt: null,
      name: 'João Ferreira',
      imagePath: 'assets/images/client3.jpg',
      email: 'joao@email.com',
      city: 'Lisboa',
      parish: 'Alvalade',
      postalCode: '1700-111',
      primaryDeliveryAddress: 'Rua das Flores, 789',
      userId: null,
      createdAt: null,
    );

    client4 = ClientModel(
      phoneNumber: '+351934567890',
      updatedAt: null,
      name: 'Ana Oliveira',
      imagePath: 'assets/images/client4.jpg',
      email: 'ana@email.com',
      city: 'Coimbra',
      parish: 'Sé Nova',
      postalCode: '3000-001',
      primaryDeliveryAddress: 'Largo da Universidade, 12',
      userId: null,
      createdAt: null,
    );

    client5 = ClientModel(
      phoneNumber: '+351926789012',
      updatedAt: null,
      name: 'Carlos Silva',
      imagePath: 'assets/images/client5.jpg',
      email: 'carlos@email.com',
      city: 'Braga',
      parish: 'São Vicente',
      postalCode: '4700-123',
      primaryDeliveryAddress: 'Rua do Souto, 34',
      userId: null,
      createdAt: null,
    );

    client6 = ClientModel(
      phoneNumber: '+351938765432',
      updatedAt: null,
      name: 'Sofia Costa',
      imagePath: 'assets/images/client6.jpg',
      email: 'sofia@email.com',
      city: 'Funchal',
      parish: 'Santa Luzia',
      postalCode: '9050-001',
      primaryDeliveryAddress: 'Estrada Monumental, 90',
      userId: null,
      createdAt: null,
    );

    client7 = ClientModel(
      phoneNumber: '+351911223344',
      updatedAt: null,
      name: 'Ricardo Mendes',
      imagePath: 'assets/images/client7.jpg',
      email: 'ricardo@email.com',
      city: 'Aveiro',
      parish: 'Glória e Vera Cruz',
      postalCode: '3810-193',
      primaryDeliveryAddress: 'Cais da Fonte Nova, 7',
      userId: null,
      createdAt: null,
    );

    client8 = ClientModel(
      phoneNumber: '+351924567890',
      updatedAt: null,
      name: 'Beatriz Almeida',
      imagePath: 'assets/images/client8.jpg',
      email: 'beatriz@email.com',
      city: 'Setúbal',
      parish: 'São Sebastião',
      postalCode: '2900-312',
      primaryDeliveryAddress: 'Avenida Luísa Todi, 123',
      userId: null,
      createdAt: null,
    );

    client9 = ClientModel(
      phoneNumber: '+351917654321',
      updatedAt: null,
      name: 'Tiago Rocha',
      imagePath: 'assets/images/client9.jpg',
      email: 'tiago@email.com',
      city: 'Leiria',
      parish: 'Marrazes',
      postalCode: '2400-123',
      primaryDeliveryAddress: 'Rua Capitão Mouzinho de Albuquerque, 56',
      userId: null,
      createdAt: null,
    );

    client10 = ClientModel(
      phoneNumber: '+351935678901',
      updatedAt: null,
      name: 'Helena Pinto',
      imagePath: 'assets/images/client10.jpg',
      email: 'helena@email.com',
      city: 'Viseu',
      parish: 'Coração de Jesus',
      postalCode: '3500-999',
      primaryDeliveryAddress: 'Praça da República, 88',
      userId: null,
      createdAt: null,
    );
  }

  Future<void> _initData() async {  // Added void return type
    // Initialize the clients list with all clients
    clients = [
      client1, client2, client3, client4, client5,
      client6, client7, client8, client9, client10
    ];
  }

  Future<void> saveClientsToFirebase() async {
    for (ClientModel client in clients) {
      try {
        await client.createClientDoc(
          client.userId,
          client.name,
          client.imagePath,
          client.userRating,
          client.email,
          client.phoneNumber,
          client.city,
          client.parish,
          client.postalCode,
          client.primaryDeliveryAddress,
          client.createdAt,
        );
      } catch (e) {
        print('Error saving client ${client.name}: $e');
      }
    }
  }

  List<ClientModel> getClients (){
    return clients;
  }
}