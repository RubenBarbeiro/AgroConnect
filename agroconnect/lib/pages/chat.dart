import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ConversationScreen extends StatefulWidget {
  final String contactName;
  final String contactAvatar;
  final String contactId;
  final String contactType;
  final String currentUserId;
  final String currentUserType;

  const ConversationScreen({
    super.key,
    required this.contactName,
    required this.contactAvatar,
    required this.contactId,
    required this.contactType,
    required this.currentUserId,
    required this.currentUserType,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  String get conversationId {
    List<String> participants = [
      '${widget.currentUserType}_${widget.currentUserId}',
      '${widget.contactType}_${widget.contactId}'
    ];
    participants.sort();
    return participants.join('_');
  }

  Stream<List<Message>> _getMessagesStream() {
    return _firestore
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => Message.fromMap(doc.data()))
          .where((message) {
        return (message.senderId == widget.currentUserId &&
            message.receiverId == widget.contactId) ||
            (message.senderId == widget.contactId &&
                message.receiverId == widget.currentUserId);
      }).toList();

      _markMessagesAsRead(messages);

      return messages;
    });
  }

  Future<void> _markMessagesAsRead(List<Message> messages) async {
    final batch = _firestore.batch();
    bool hasUpdates = false;

    for (var message in messages) {
      if (!message.isRead &&
          message.senderId == widget.contactId &&
          message.receiverId == widget.currentUserId) {
        final docRef = _firestore.collection('messages').doc(message.id);
        batch.update(docRef, {'isRead': true});
        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      try {
        await batch.commit();
      } catch (e) {}
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    final message = Message(
      id: _uuid.v4(),
      text: messageText,
      senderId: widget.currentUserId,
      receiverId: widget.contactId,
      senderType: widget.currentUserType,
      receiverType: widget.contactType,
      timestamp: DateTime.now(),
      isRead: false,
    );

    try {
      await _firestore
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());

      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar mensagem: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Color.fromRGBO(84, 157, 115, 0.1),
              child: Text(
                widget.contactAvatar,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contactName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromRGBO(84, 157, 115, 1.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Color.fromRGBO(84, 157, 115, 1.0),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Erro ao carregar mensagens',
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color.fromRGBO(84, 157, 115, 1.0),
                    ),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhuma mensagem ainda.\nComece a conversa!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Escreva uma mensagem...',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(84, 157, 115, 1.0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final bool isMe = message.isSentByUser(widget.currentUserId, widget.currentUserType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Color.fromRGBO(84, 157, 115, 0.1),
              child: Text(
                widget.contactAvatar,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Color.fromRGBO(84, 157, 115, 1.0)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Color.fromRGBO(84, 157, 115, 0.1),
              child: Icon(
                Icons.person,
                size: 16,
                color: Color.fromRGBO(84, 157, 115, 1.0),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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

  Message copyWith({
    String? id,
    String? text,
    String? senderId,
    String? receiverId,
    String? senderType,
    String? receiverType,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderType: senderType ?? this.senderType,
      receiverType: receiverType ?? this.receiverType,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
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