import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.senderName,
    super.senderPhotoUrl,
    required super.type,
    required super.content,
    super.imageUrl,
    required super.status,
    required super.timestamp,
    super.readAt,
    super.isSystemMessage = false,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MessageModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'],
      type: _parseMessageType(data['type']),
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      status: _parseMessageStatus(data['status']),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      isSystemMessage: data['isSystemMessage'] ?? false,
    );
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderPhotoUrl: map['senderPhotoUrl'],
      type: _parseMessageType(map['type']),
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      status: _parseMessageStatus(map['status']),
      timestamp:
          map['timestamp'] is Timestamp
              ? (map['timestamp'] as Timestamp).toDate()
              : DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      readAt:
          map['readAt'] is Timestamp
              ? (map['readAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['readAt'] ?? ''),
      isSystemMessage: map['isSystemMessage'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'type': type.name,
      'content': content,
      'imageUrl': imageUrl,
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'isSystemMessage': isSystemMessage,
    };
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      chatId: entity.chatId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      senderPhotoUrl: entity.senderPhotoUrl,
      type: entity.type,
      content: entity.content,
      imageUrl: entity.imageUrl,
      status: entity.status,
      timestamp: entity.timestamp,
      readAt: entity.readAt,
      isSystemMessage: entity.isSystemMessage,
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      type: type,
      content: content,
      imageUrl: imageUrl,
      status: status,
      timestamp: timestamp,
      readAt: readAt,
      isSystemMessage: isSystemMessage,
    );
  }

  static MessageType _parseMessageType(String? type) {
    switch (type?.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  static MessageStatus _parseMessageStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }
}
