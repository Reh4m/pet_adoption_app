import 'package:equatable/equatable.dart';

enum ChatStatus { active, archived, blocked }

class ChatEntity extends Equatable {
  final String id;
  final String adoptionRequestId;
  final String petId;
  final String petName;
  final List<String> petImageUrls;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantPhotos;
  final String? lastMessageId;
  final String? lastMessageText;
  final String? lastMessageSenderId;
  final DateTime? lastMessageTimestamp;
  final Map<String, int> unreadCounts;
  final ChatStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ChatEntity({
    required this.id,
    required this.adoptionRequestId,
    required this.petId,
    required this.petName,
    required this.petImageUrls,
    required this.participantIds,
    required this.participantNames,
    required this.participantPhotos,
    this.lastMessageId,
    this.lastMessageText,
    this.lastMessageSenderId,
    this.lastMessageTimestamp,
    required this.unreadCounts,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    adoptionRequestId,
    petId,
    petName,
    petImageUrls,
    participantIds,
    participantNames,
    participantPhotos,
    lastMessageId,
    lastMessageText,
    lastMessageSenderId,
    lastMessageTimestamp,
    unreadCounts,
    status,
    createdAt,
    updatedAt,
  ];

  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere((id) => id != currentUserId);
  }

  String getOtherParticipantName(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantNames[otherId] ?? 'Usuario';
  }

  String? getOtherParticipantPhoto(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantPhotos[otherId];
  }

  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  bool get hasUnreadMessages {
    return unreadCounts.values.any((count) => count > 0);
  }

  bool get isActive => status == ChatStatus.active;

  ChatEntity copyWith({
    String? id,
    String? adoptionRequestId,
    String? petId,
    String? petName,
    List<String>? petImageUrls,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String?>? participantPhotos,
    String? lastMessageId,
    String? lastMessageText,
    String? lastMessageSenderId,
    DateTime? lastMessageTimestamp,
    Map<String, int>? unreadCounts,
    ChatStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      adoptionRequestId: adoptionRequestId ?? this.adoptionRequestId,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petImageUrls: petImageUrls ?? this.petImageUrls,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantPhotos: participantPhotos ?? this.participantPhotos,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
