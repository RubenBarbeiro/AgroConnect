import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agroconnect/pages/chat.dart';

class Mensagens extends StatefulWidget {
  final String currentUserId;
  final String currentUserType; // 'client' or 'supplier'

  const Mensagens({
    super.key,
    required this.currentUserId,
    required this.currentUserType,
  });

  @override
  State<Mensagens> createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  int selectedFilterIndex = 0;
  final List<String> filters = ['Todas', 'Não Lidas', 'Arquivadas'];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ConversationItem>> _getConversationsStream() {
    return _firestore
        .collection('messages')
        .where('senderId', isEqualTo: widget.currentUserId)
        .snapshots()
        .asyncMap((senderSnapshot) async {

      // Also get messages where current user is receiver
      final receiverSnapshot = await _firestore
          .collection('messages')
          .where('receiverId', isEqualTo: widget.currentUserId)
          .get();

      // Combine both snapshots
      final allMessages = <Message>[];

      for (var doc in senderSnapshot.docs) {
        allMessages.add(Message.fromMap(doc.data()));
      }

      for (var doc in receiverSnapshot.docs) {
        allMessages.add(Message.fromMap(doc.data()));
      }

      // Group messages by conversation and get latest message for each
      final Map<String, ConversationItem> conversations = {};

      for (var message in allMessages) {
        final conversationId = message.getConversationId();

        // Determine the other participant
        String otherUserId;
        String otherUserType;

        if (message.senderId == widget.currentUserId) {
          otherUserId = message.receiverId;
          otherUserType = message.receiverType;
        } else {
          otherUserId = message.senderId;
          otherUserType = message.senderType;
        }

        // Check if this conversation exists or if this message is more recent
        if (!conversations.containsKey(conversationId) ||
            message.timestamp.isAfter(conversations[conversationId]!.lastMessage.timestamp)) {

          // You'll need to fetch user details from your users collection
          // For now, using placeholder data - you should replace this with actual user data
          conversations[conversationId] = ConversationItem(
            id: conversationId,
            otherUserId: otherUserId,
            otherUserType: otherUserType,
            name: await _getUserName(otherUserId, otherUserType),
            avatar: await _getUserAvatar(otherUserId, otherUserType),
            lastMessage: message,
          );
        }
      }

      return conversations.values.toList()
        ..sort((a, b) => b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp));
    });
  }

  // You'll need to implement these methods to fetch user data from your users collection
  Future<String> _getUserName(String userId, String userType) async {
    try {
      final doc = await _firestore
          .collection(userType == 'client' ? 'clients' : 'suppliers')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data()?['name'] ?? 'Usuário';
      }
      return 'Usuário';
    } catch (e) {
      return 'Usuário';
    }
  }

  Future<String> _getUserAvatar(String userId, String userType) async {
    try {
      final doc = await _firestore
          .collection(userType == 'client' ? 'clients' : 'suppliers')
          .doc(userId)
          .get();

      if (doc.exists) {
        // Return first letter of name or a default emoji
        final name = doc.data()?['name'] ?? 'U';
        return name.substring(0, 1).toUpperCase();
      }
      return 'U';
    } catch (e) {
      return 'U';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: StreamBuilder<List<ConversationItem>>(
              stream: _getConversationsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar conversas'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color.fromRGBO(84, 157, 115, 1.0),
                    ),
                  );
                }

                final conversations = snapshot.data ?? [];

                // Filter conversations based on selected filter
                List<ConversationItem> filteredConversations = [];
                switch (selectedFilterIndex) {
                  case 0: // Todas
                    filteredConversations = conversations;
                    break;
                  case 1: // Não Lidas
                    filteredConversations = conversations.where((conv) =>
                    !conv.lastMessage.isRead &&
                        conv.lastMessage.receiverId == widget.currentUserId
                    ).toList();
                    break;
                  case 2: // Arquivadas (you might want to add an isArchived field to your model)
                    filteredConversations = []; // Implement archiving logic if needed
                    break;
                }

                if (filteredConversations.isEmpty) {
                  return Center(
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
                              : 'Não há conversas ainda',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredConversations.length,
                  itemBuilder: (context, index) {
                    final conversation = filteredConversations[index];
                    final isUnread = !conversation.lastMessage.isRead &&
                        conversation.lastMessage.receiverId == widget.currentUserId;

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
                              conversation.avatar,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          title: Text(
                            conversation.name,
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              conversation.lastMessage.text,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
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
                                _formatTime(conversation.lastMessage.timestamp),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              if (isUnread)
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
                          onTap: () {
                            // Navigate to conversation screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConversationScreen(
                                  contactName: conversation.name,
                                  contactAvatar: conversation.avatar,
                                  contactId: conversation.otherUserId,
                                  contactType: conversation.otherUserType,
                                  currentUserId: widget.currentUserId,
                                  currentUserType: widget.currentUserType,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ConversationItem {
  final String id;
  final String otherUserId;
  final String otherUserType;
  final String name;
  final String avatar;
  final Message lastMessage;

  ConversationItem({
    required this.id,
    required this.otherUserId,
    required this.otherUserType,
    required this.name,
    required this.avatar,
    required this.lastMessage,
  });
}

// Message class - same as before
class Message {
  final String id;
  final String text;
  final String senderId;
  final String receiverId;
  final String senderType;
  final String receiverType;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.senderType,
    required this.receiverType,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderType': senderType,
      'receiverType': receiverType,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      senderType: map['senderType'] ?? '',
      receiverType: map['receiverType'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
    );
  }

  String getConversationId() {
    List<String> participants = [
      '${senderType}_$senderId',
      '${receiverType}_$receiverId'
    ];
    participants.sort();
    return participants.join('_');
  }

  bool isSentByUser(String currentUserId, String currentUserType) {
    return senderId == currentUserId && senderType == currentUserType;
  }
}