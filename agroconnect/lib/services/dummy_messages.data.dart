import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/messages_model.dart';

class DummyMessagesData {
  static List<Message> getDummyMessages() {
    final now = DateTime.now();

    return [
      // Conversation with Mercado Verde - carrots inquiry
      Message(
        id: 'msg_001',
        text: 'Boa tarde! Tem cenouras hoje? Preciso de umas 2kg.',
        senderId: 'placeholder',
        receiverId: 'mercado_verde',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        isRead: true,
      ),
      Message(
        id: 'msg_002',
        text: 'Boa tarde! Tenho sim, fica a 5€/Kg. São fresquinhas, colhidas hoje de manhã!',
        senderId: 'mercado_verde',
        receiverId: 'placeholder',
        senderType: 'supplier',
        receiverType: 'client',
        timestamp: now.subtract(const Duration(days: 1, hours: 2, minutes: 45)),
        isRead: true,
      ),
      Message(
        id: 'msg_003',
        text: 'Perfeito! Pode guardar 2kg para mim? Passo aí buscar até às 18h.',
        senderId: 'placeholder',
        receiverId: 'mercado_verde',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(days: 1, hours: 2, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'msg_004',
        text: 'Claro! Já estão separadas. Até logo!',
        senderId: 'mercado_verde',
        receiverId: 'placeholder',
        senderType: 'supplier',
        receiverType: 'client',
        timestamp: now.subtract(const Duration(days: 1, hours: 2, minutes: 15)),
        isRead: true,
      ),

      // Conversation with Cenouras da Horta Encantada - bulk order
      Message(
        id: 'msg_005',
        text: 'Olá! Vi que têm cenouras. Precisava de uma quantidade maior, uns 10kg. Fazem desconto?',
        senderId: 'placeholder',
        receiverId: 'horta_encantada',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      Message(
        id: 'msg_006',
        text: 'Olá! Sim, para 10kg posso fazer a 4,50€/kg. Suas cenouras estão prontas para recolher!',
        senderId: 'horta_encantada',
        receiverId: 'placeholder',
        senderType: 'supplier',
        receiverType: 'client',
        timestamp: now.subtract(const Duration(days: 1, hours: 23)),
        isRead: true,
      ),
      Message(
        id: 'msg_007',
        text: 'Excelente preço! Quando posso passar para buscar?',
        senderId: 'placeholder',
        receiverId: 'horta_encantada',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(days: 1, hours: 22, minutes: 45)),
        isRead: false,
      ),

      // Conversation with Feira na Porta - delivery
      Message(
        id: 'msg_008',
        text: 'Bom dia! Fazem entregas na zona de Sintra? Queria pedir batatas e cebolas.',
        senderId: 'placeholder',
        receiverId: 'feira_porta',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(hours: 8)),
        isRead: true,
      ),
      Message(
        id: 'msg_009',
        text: 'Bom dia! Sim, fazemos entregas em Sintra. Taxa de entrega 3€. O que precisa?',
        senderId: 'feira_porta',
        receiverId: 'placeholder',
        senderType: 'supplier',
        receiverType: 'client',
        timestamp: now.subtract(const Duration(hours: 7, minutes: 45)),
        isRead: true,
      ),
      Message(
        id: 'msg_010',
        text: '2kg de batatas e 1kg de cebolas. Podem entregar hoje à tarde?',
        senderId: 'placeholder',
        receiverId: 'feira_porta',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(hours: 7, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'msg_011',
        text: 'Perfeitamente! Batatas 2€/kg, cebolas 1,5€/kg + 3€ entrega = 10€ total. Entrego até às 17h.',
        senderId: 'feira_porta',
        receiverId: 'placeholder',
        senderType: 'supplier',
        receiverType: 'client',
        timestamp: now.subtract(const Duration(hours: 7, minutes: 15)),
        isRead: true,
      ),
      Message(
        id: 'msg_012',
        text: 'Obrigado! Vou aguardar a entrega.',
        senderId: 'placeholder',
        receiverId: 'feira_porta',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(hours: 7)),
        isRead: false,
      ),

      // Conversation with Quintal Fresco - availability inquiry
      Message(
        id: 'msg_013',
        text: 'Boa noite! Têm alfaces hoje? E a que horas fecham?',
        senderId: 'placeholder',
        receiverId: 'quintal_fresco',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(hours: 4)),
        isRead: true,
      ),
      Message(
        id: 'msg_014',
        text: 'Boa noite! Temos alfaces frescas sim. Fechamos às 19h. Fazem entregas na zona sul?',
        senderId: 'quintal_fresco',
        receiverId: 'placeholder',
        senderType: 'supplier',
        receiverType: 'client',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 45)),
        isRead: true,
      ),
      Message(
        id: 'msg_015',
        text: 'Não preciso de entrega, posso passar aí. Quanto custam as alfaces?',
        senderId: 'placeholder',
        receiverId: 'quintal_fresco',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'msg_016',
        text: 'Alfaces grandes 1,5€ cada, pequenas 1€. Todas muito frescas!',
        senderId: 'quintal_fresco',
        receiverId: 'placeholder',
        senderType: 'supplier',
        receiverType: 'client',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 15)),
        isRead: false,
      ),

      // Conversation with Pomar das Maçãs Douradas - apple inquiry
      Message(
        id: 'msg_017',
        text: 'Olá! Que variedades de maçãs têm disponíveis?',
        senderId: 'placeholder',
        receiverId: 'pomar_macas',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(hours: 6)),
        isRead: true,
      ),
      Message(
        id: 'msg_018',
        text: 'Temos Golden, Red Delicious e Granny Smith. Todas a 2,5€/kg. Tem preferência?',
        senderId: 'pomar_macas',
        receiverId: 'placeholder',
        senderType: 'supplier',
        receiverType: 'client',
        timestamp: now.subtract(const Duration(hours: 5, minutes: 45)),
        isRead: true,
      ),
      Message(
        id: 'msg_019',
        text: 'Queria 2kg das Golden. Estão doces?',
        senderId: 'placeholder',
        receiverId: 'pomar_macas',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(hours: 5, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'msg_020',
        text: 'Boa tarde, tem maçãs?',
        senderId: 'placeholder',
        receiverId: 'pomar_macas',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: false,
      ),

      // Conversation with Batata & Cia - wholesale inquiry
      Message(
        id: 'msg_021',
        text: 'Bom dia! Trabalham com quantidades grandes? Preciso de 50kg de batatas.',
        senderId: 'placeholder',
        receiverId: 'batata_cia',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      Message(
        id: 'msg_022',
        text: 'Bom dia! Sim, trabalhamos no atacado. Para 50kg, preço especial: 1,2€/kg. Tem diversos tipos de batatas. Qual prefere?',
        senderId: 'batata_cia',
        receiverId: 'placeholder',
        senderType: 'supplier',
        receiverType: 'client',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
        isRead: true,
      ),
      Message(
        id: 'msg_023',
        text: 'Ótimo preço! Podem ser batatas para cozer, uso geral. Quando posso buscar?',
        senderId: 'placeholder',
        receiverId: 'batata_cia',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
        isRead: false,
      ),

      // Conversation with Laranjeiras do Seu Zé - orange season
      Message(
        id: 'msg_024',
        text: 'Olá! Já têm laranjas da época? Como está a qualidade este ano?',
        senderId: 'placeholder',
        receiverId: 'laranjeiras_ze',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(minutes: 45)),
        isRead: true,
      ),
      Message(
        id: 'msg_025',
        text: 'Olá! As primeiras laranjas já estão a amadurecer! Muito suculentas este ano. 3€/kg.',
        senderId: 'laranjeiras_ze',
        receiverId: 'placeholder',
        senderType: 'supplier',
        receiverType: 'client',
        timestamp: now.subtract(const Duration(minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'msg_026',
        text: 'Excelente! Posso passar amanhã de manhã para comprar umas. Que horas abrem?',
        senderId: 'placeholder',
        receiverId: 'laranjeiras_ze',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
      ),

      // Recent message from another customer about vegetables
      Message(
        id: 'msg_027',
        text: 'Olá! Vi que compraste no Mercado Verde. Como foram os legumes? Estou a pensar encomendar também.',
        senderId: 'cliente_maria',
        receiverId: 'placeholder',
        senderType: 'client',
        receiverType: 'client',
        timestamp: now.subtract(const Duration(minutes: 20)),
        isRead: false,
      ),

      // New farmer reaching out
      Message(
        id: 'msg_028',
        text: 'Bom dia! Sou novo na plataforma. Tenho uma quinta em Óbidos com produtos biológicos. Tomates, pepinos, abobrinhas. Interessado?',
        senderId: 'quinta_obidos',
        receiverId: 'placeholder',
        senderType: 'supplier',
        receiverType: 'client',
        timestamp: now.subtract(const Duration(minutes: 10)),
        isRead: false,
      ),

      // Latest response from placeholder
      Message(
        id: 'msg_029',
        text: 'Bom dia! Sim, tenho interesse em produtos biológicos. Que preços praticam?',
        senderId: 'placeholder',
        receiverId: 'quinta_obidos',
        senderType: 'client',
        receiverType: 'supplier',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
    ];
  }

  // Helper method to get messages for a specific conversation
  static List<Message> getConversationMessages(String userId, String userType, String otherUserId, String otherUserType) {
    return getDummyMessages().where((message) {
      return (message.senderId == userId && message.senderType == userType &&
          message.receiverId == otherUserId && message.receiverType == otherUserType) ||
          (message.senderId == otherUserId && message.senderType == otherUserType &&
              message.receiverId == userId && message.receiverType == userType);
    }).toList();
  }

  // Helper method to get all conversations for placeholder user
  static List<Message> getPlaceholderMessages() {
    return getDummyMessages().where((message) {
      return (message.senderId == 'placeholder' && message.senderType == 'client') ||
          (message.receiverId == 'placeholder' && message.receiverType == 'client');
    }).toList();
  }

  // Helper method to get unread messages for placeholder user
  static List<Message> getUnreadMessagesForPlaceholder() {
    return getDummyMessages().where((message) {
      return message.receiverId == 'placeholder' &&
          message.receiverType == 'client' &&
          !message.isRead;
    }).toList();
  }

  // Save messages to Firebase
  Future<void> saveMessagesToFirebase() async {
    try {
      // You'll need to import Firebase Firestore
      // import 'package:cloud_firestore/cloud_firestore.dart';

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final List<Message> messages = getDummyMessages();

      // Create a batch write for better performance
      WriteBatch batch = firestore.batch();

      for (Message message in messages) {
        DocumentReference docRef = firestore.collection('messages').doc(message.id);
        batch.set(docRef, message.toMap());
      }

      // Commit the batch
      await batch.commit();

      if (kDebugMode) {
        print('Successfully saved ${messages.length} messages to Firebase!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving messages to Firebase: $e');
      }
      rethrow;
    }
  }

  // Clear all messages from Firebase (useful for testing)
  static Future<void> clearMessagesFromFirebase() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final QuerySnapshot snapshot = await firestore.collection('messages').get();

      WriteBatch batch = firestore.batch();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) {
        print('Successfully cleared all messages from Firebase!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing messages from Firebase: $e');
      }
      rethrow;
    }
  }

  // Save specific conversation to Firebase
  static Future<void> saveConversationToFirebase(String userId, String userType, String otherUserId, String otherUserType) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final List<Message> conversationMessages = getConversationMessages(userId, userType, otherUserId, otherUserType);

      WriteBatch batch = firestore.batch();

      for (Message message in conversationMessages) {
        DocumentReference docRef = firestore.collection('messages').doc(message.id);
        batch.set(docRef, message.toMap());
      }

      await batch.commit();

      if (kDebugMode) {
        print('Successfully saved ${conversationMessages.length} messages from conversation to Firebase!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving conversation to Firebase: $e');
      }
      rethrow;
    }
  }
}