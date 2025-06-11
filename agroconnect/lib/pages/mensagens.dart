import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:agroconnect/pages/chat.dart';

class Mensagens extends StatefulWidget {
  const Mensagens({super.key});

  @override
  State<Mensagens> createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  int selectedFilterIndex = 0;
  final List<String> filters = ['Todas', 'Não Lidas', 'Arquivadas'];

  // Sample message data based on your mockup
  final List<MessageItem> messages = [
    MessageItem(
      name: 'Mercado Verde',
      message: 'Boa tarde! Temos sim, fica a 5€/Kg',
      time: '1d',
      avatar: '🏪',
      isUnread: false,
    ),
    MessageItem(
      name: 'Cenouras da Horta Encantada',
      message: 'Suas cenouras estão prontas para...',
      time: '1d',
      avatar: '🥕',
      isUnread: true,
    ),
    MessageItem(
      name: 'Feira na Porta',
      message: 'Obrigado! Vou aguardar a entrega',
      time: '2d',
      avatar: '🏪',
      isUnread: false,
    ),
    MessageItem(
      name: 'Quintal Fresco',
      message: 'Fazem entregas na zona sul?',
      time: '3d',
      avatar: '🥗',
      isUnread: false,
    ),
    MessageItem(
      name: 'Pomar das Maçãs Douradas',
      message: 'Boa tarde, tem maçãs?',
      time: '4d',
      avatar: '🍎',
      isUnread: false,
    ),
    MessageItem(
      name: 'Batata & Cia',
      message: 'Temos diversos tipo de batatas. Qual...',
      time: '5d',
      avatar: '🥔',
      isUnread: false,
      isArchived: true,
    ),
    MessageItem(
      name: 'Mercado do Campo',
      message: 'Quando volta a ter mais legumes em sto...',
      time: '5d',
      avatar: '🌾',
      isUnread: false,
      isArchived: true,
    ),
    MessageItem(
      name: 'Laranjeiras do Seu Zé',
      message: 'Vende laranjas?',
      time: '5d',
      avatar: '🍊',
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter messages based on selected filter
    List<MessageItem> filteredMessages = [];
    switch (selectedFilterIndex) {
      case 0: // Todas
        filteredMessages = messages.where((message) => !message.isArchived).toList();
        break;
      case 1: // Não Lidas
        filteredMessages = messages.where((message) => message.isUnread).toList();
        break;
      case 2: // Arquivadas
        filteredMessages = messages.where((message) => message.isArchived).toList();
        break;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color.fromRGBO(84, 157, 115, 1.0),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/inbox_nav_icon.svg',
              height: 20,
              width: 20,
            ),
            SizedBox(width: 8),
            Text("Mensagens"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: List.generate(filters.length, (index) {
                final isSelected = selectedFilterIndex == index;
                return Padding(
                  padding: EdgeInsets.only(right: index < filters.length - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilterIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Color.fromRGBO(84, 157, 115, 1.0) : Color.fromRGBO(84, 157, 115, 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        filters[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Color.fromRGBO(84, 157, 115, 1.0),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Messages list
          Expanded(
            child: filteredMessages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    selectedFilterIndex == 1
                        ? 'Não há mensagens não lidas'
                        : selectedFilterIndex == 2
                        ? 'Não há mensagens arquivadas'
                        : 'Não há mensagens',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: filteredMessages.length,
              itemBuilder: (context, index) {
                final message = filteredMessages[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Color.fromRGBO(84, 157, 115, 0.1),
                        child: Text(
                          message.avatar,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        message.name,
                        style: TextStyle(
                          fontWeight: message.isUnread ? FontWeight.bold : FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          message.message,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: message.isUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            message.time,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                          if (message.isUnread)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(84, 157, 115, 1.0),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      // HERE'S WHERE YOU ADD THE NAVIGATION
                      onTap: () {
                        // Navigate to conversation screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConversationScreen(
                              contactName: message.name,
                              contactAvatar: message.avatar,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MessageItem {
  final String name;
  final String message;
  final String time;
  final String avatar;
  final bool isUnread;
  final bool isArchived;

  MessageItem({
    required this.name,
    required this.message,
    required this.time,
    required this.avatar,
    this.isUnread = false,
    this.isArchived = false,
  });
}