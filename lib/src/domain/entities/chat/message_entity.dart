import 'package:equatable/equatable.dart';

enum MessageType { text, image, system }

enum MessageStatus { sent, delivered, read }

class MessageEntity extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final MessageType type;
  final String content;
  final String? imageUrl;
  final MessageStatus status;
  final DateTime timestamp;
  final DateTime? readAt;
  final bool isSystemMessage;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.type,
    required this.content,
    this.imageUrl,
    required this.status,
    required this.timestamp,
    this.readAt,
    this.isSystemMessage = false,
  });

  @override
  List<Object?> get props => [
    id,
    chatId,
    senderId,
    senderName,
    senderPhotoUrl,
    type,
    content,
    imageUrl,
    status,
    timestamp,
    readAt,
    isSystemMessage,
  ];

  bool get isRead => status == MessageStatus.read;
  bool get isDelivered => status == MessageStatus.delivered;
  bool get isSent => status == MessageStatus.sent;
  bool get isTextMessage => type == MessageType.text;
  bool get isImageMessage => type == MessageType.image;

  String get timeString {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  MessageEntity copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderPhotoUrl,
    MessageType? type,
    String? content,
    String? imageUrl,
    MessageStatus? status,
    DateTime? timestamp,
    DateTime? readAt,
    bool? isSystemMessage,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      type: type ?? this.type,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      readAt: readAt ?? this.readAt,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
    );
  }
}
