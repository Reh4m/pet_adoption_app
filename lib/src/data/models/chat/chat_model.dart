import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.adoptionRequestId,
    required super.petId,
    required super.petName,
    required super.petImageUrls,
    required super.participantIds,
    required super.participantNames,
    required super.participantPhotos,
    super.lastMessageId,
    super.lastMessageText,
    super.lastMessageSenderId,
    super.lastMessageTimestamp,
    required super.unreadCounts,
    required super.status,
    required super.createdAt,
    super.updatedAt,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatModel(
      id: doc.id,
      adoptionRequestId: data['adoptionRequestId'] ?? '',
      petId: data['petId'] ?? '',
      petName: data['petName'] ?? '',
      petImageUrls: List<String>.from(data['petImageUrls'] ?? []),
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: Map<String, String>.from(
        data['participantNames'] ?? {},
      ),
      participantPhotos: Map<String, String?>.from(
        data['participantPhotos'] ?? {},
      ),
      lastMessageId: data['lastMessageId'],
      lastMessageText: data['lastMessageText'],
      lastMessageSenderId: data['lastMessageSenderId'],
      lastMessageTimestamp:
          (data['lastMessageTimestamp'] as Timestamp?)?.toDate(),
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
      status: _parseChatStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] ?? '',
      adoptionRequestId: map['adoptionRequestId'] ?? '',
      petId: map['petId'] ?? '',
      petName: map['petName'] ?? '',
      petImageUrls: List<String>.from(map['petImageUrls'] ?? []),
      participantIds: List<String>.from(map['participantIds'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      participantPhotos: Map<String, String?>.from(
        map['participantPhotos'] ?? {},
      ),
      lastMessageId: map['lastMessageId'],
      lastMessageText: map['lastMessageText'],
      lastMessageSenderId: map['lastMessageSenderId'],
      lastMessageTimestamp:
          map['lastMessageTimestamp'] is Timestamp
              ? (map['lastMessageTimestamp'] as Timestamp).toDate()
              : DateTime.tryParse(map['lastMessageTimestamp'] ?? ''),
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
      status: _parseChatStatus(map['status']),
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt:
          map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['updatedAt'] ?? ''),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'adoptionRequestId': adoptionRequestId,
      'petId': petId,
      'petName': petName,
      'petImageUrls': petImageUrls,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantPhotos': participantPhotos,
      'lastMessageId': lastMessageId,
      'lastMessageText': lastMessageText,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTimestamp':
          lastMessageTimestamp != null
              ? Timestamp.fromDate(lastMessageTimestamp!)
              : null,
      'unreadCounts': unreadCounts,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ChatModel.fromEntity(ChatEntity entity) {
    return ChatModel(
      id: entity.id,
      adoptionRequestId: entity.adoptionRequestId,
      petId: entity.petId,
      petName: entity.petName,
      petImageUrls: entity.petImageUrls,
      participantIds: entity.participantIds,
      participantNames: entity.participantNames,
      participantPhotos: entity.participantPhotos,
      lastMessageId: entity.lastMessageId,
      lastMessageText: entity.lastMessageText,
      lastMessageSenderId: entity.lastMessageSenderId,
      lastMessageTimestamp: entity.lastMessageTimestamp,
      unreadCounts: entity.unreadCounts,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ChatEntity toEntity() {
    return ChatEntity(
      id: id,
      adoptionRequestId: adoptionRequestId,
      petId: petId,
      petName: petName,
      petImageUrls: petImageUrls,
      participantIds: participantIds,
      participantNames: participantNames,
      participantPhotos: participantPhotos,
      lastMessageId: lastMessageId,
      lastMessageText: lastMessageText,
      lastMessageSenderId: lastMessageSenderId,
      lastMessageTimestamp: lastMessageTimestamp,
      unreadCounts: unreadCounts,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static ChatStatus _parseChatStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return ChatStatus.active;
      case 'archived':
        return ChatStatus.archived;
      case 'blocked':
        return ChatStatus.blocked;
      default:
        return ChatStatus.active;
    }
  }
}
