// lib/features/chat/model/chat_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo da mensagem dentro de uma sala de chat.
enum ChatMessageType { user, ai, system }

/// Mensagem individual de uma sala de chat (subcoleção `chats/{id}/messages`).
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final ChatMessageType type;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.type,
    required this.createdAt,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? {};
    final ts = map['createdAt'];
    return ChatMessage(
      id: doc.id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Aventureiro',
      text: map['text'] ?? '',
      type: ChatMessageType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => ChatMessageType.user,
      ),
      // Enquanto o serverTimestamp não é confirmado, ele chega nulo localmente
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'type': type.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

/// Sala de chat (mesa / grupo) armazenada em `chats/{id}`.
class ChatRoom {
  final String id;
  final String title;
  final String system;
  final String description;
  final List<String> members;
  final String lastMessage;
  final DateTime? lastMessageAt;

  const ChatRoom({
    required this.id,
    required this.title,
    required this.system,
    required this.description,
    required this.members,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  factory ChatRoom.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? {};
    final ts = map['lastMessageAt'];
    return ChatRoom(
      id: doc.id,
      title: map['title'] ?? 'Mesa sem nome',
      system: map['system'] ?? '',
      description: map['description'] ?? '',
      members: List<String>.from(map['members'] ?? const []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
