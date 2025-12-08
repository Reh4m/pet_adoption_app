import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_adoption_app/src/core/errors/exceptions.dart';
import 'package:pet_adoption_app/src/data/models/chat/chat_model.dart';
import 'package:pet_adoption_app/src/data/models/chat/message_model.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/chat_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/message_entity.dart';

class FirebaseChatService {
  final FirebaseFirestore firestore;

  FirebaseChatService({required this.firestore});

  static const String _chatsCollection = 'chats';
  static const String _messagesCollection = 'messages';

  Future<ChatModel> createChat({
    required String adoptionRequestId,
    required String petId,
    required String petName,
    required List<String> petImageUrls,
    required String requesterId,
    required String requesterName,
    String? requesterPhotoUrl,
    required String ownerId,
    required String ownerName,
    String? ownerPhotoUrl,
  }) async {
    try {
      final docRef = firestore.collection(_chatsCollection).doc();
      final chatId = docRef.id;

      final chat = ChatModel(
        id: chatId,
        adoptionRequestId: adoptionRequestId,
        petId: petId,
        petName: petName,
        petImageUrls: petImageUrls,
        participantIds: [requesterId, ownerId],
        participantNames: {requesterId: requesterName, ownerId: ownerName},
        participantPhotos: {
          requesterId: requesterPhotoUrl,
          ownerId: ownerPhotoUrl,
        },
        unreadCounts: {requesterId: 0, ownerId: 0},
        status: ChatStatus.active,
        createdAt: DateTime.now(),
      );

      await docRef.set(chat.toFirestore());

      // Enviar mensaje de sistema inicial
      await sendSystemMessage(
        chatId: chatId,
        content: 'Chat iniciado para la adopción de $petName',
      );

      return chat;
    } catch (e) {
      throw ServerException();
    }
  }

  Future<ChatModel?> getChatByAdoptionRequestId(
    String adoptionRequestId,
  ) async {
    try {
      final query =
          await firestore
              .collection(_chatsCollection)
              .where('adoptionRequestId', isEqualTo: adoptionRequestId)
              .limit(1)
              .get();

      if (query.docs.isEmpty) return null;

      return ChatModel.fromFirestore(query.docs.first);
    } catch (e) {
      throw ServerException();
    }
  }

  Future<ChatModel> getChatById(String chatId) async {
    try {
      final doc =
          await firestore.collection(_chatsCollection).doc(chatId).get();

      if (!doc.exists) {
        throw ChatNotFoundException();
      }

      return ChatModel.fromFirestore(doc);
    } catch (e) {
      if (e is ChatNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    try {
      return firestore
          .collection(_chatsCollection)
          .where('participantIds', arrayContains: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => ChatModel.fromFirestore(doc))
                    .toList(),
          );
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> updateChatStatus(String chatId, ChatStatus status) async {
    try {
      await firestore.collection(_chatsCollection).doc(chatId).update({
        'status': status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> archiveChat(String chatId) async {
    try {
      await updateChatStatus(chatId, ChatStatus.archived);
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      final batch = firestore.batch();

      // Eliminar todos los mensajes del chat
      final messagesQuery =
          await firestore
              .collection(_messagesCollection)
              .where('chatId', isEqualTo: chatId)
              .get();

      for (final doc in messagesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Eliminar el chat
      batch.delete(firestore.collection(_chatsCollection).doc(chatId));

      await batch.commit();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<String> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
  }) async {
    try {
      final batch = firestore.batch();

      // Crear el mensaje
      final messageRef = firestore.collection(_messagesCollection).doc();
      final messageId = messageRef.id;

      final message = MessageModel(
        id: messageId,
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        type: type,
        content: content,
        imageUrl: imageUrl,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
      );

      batch.set(messageRef, message.toFirestore());

      // Actualizar el chat con el último mensaje
      final chatRef = firestore.collection(_chatsCollection).doc(chatId);

      // Obtener el chat actual para actualizar unread counts
      final chatDoc = await chatRef.get();
      final chatData = chatDoc.data() as Map<String, dynamic>;
      final participantIds = List<String>.from(
        chatData['participantIds'] ?? [],
      );
      final currentUnreadCounts = Map<String, int>.from(
        chatData['unreadCounts'] ?? {},
      );

      // Incrementar unread count para todos los participantes excepto el sender
      for (String participantId in participantIds) {
        if (participantId != senderId) {
          currentUnreadCounts[participantId] =
              (currentUnreadCounts[participantId] ?? 0) + 1;
        } else {
          currentUnreadCounts[participantId] = 0;
        }
      }

      batch.update(chatRef, {
        'lastMessageId': messageId,
        'lastMessageText': content,
        'lastMessageSenderId': senderId,
        'lastMessageTimestamp': Timestamp.fromDate(message.timestamp),
        'unreadCounts': currentUnreadCounts,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await batch.commit();
      return messageId;
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<List<MessageModel>> getChatMessagesStream(String chatId) {
    try {
      return firestore
          .collection(_messagesCollection)
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => MessageModel.fromFirestore(doc))
                    .toList(),
          );
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> markMessageAsRead(String messageId, String userId) async {
    try {
      await firestore.collection(_messagesCollection).doc(messageId).update({
        'status': MessageStatus.read.name,
        'readAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> markAllMessagesAsDelivered(String chatId, String userId) async {
    try {
      final batch = firestore.batch();

      // Marcar todos los mensajes como entregados
      final messagesQuery =
          await firestore
              .collection(_messagesCollection)
              .where('chatId', isEqualTo: chatId)
              .where(
                'senderId',
                isNotEqualTo: userId,
              ) // Solo mensajes que no envió el usuario
              .where('status', whereIn: ['sent']) // Solo mensajes no entregados
              .get();

      for (final doc in messagesQuery.docs) {
        batch.update(doc.reference, {'status': MessageStatus.delivered.name});
      }

      await batch.commit();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> markAllMessagesAsRead(String chatId, String userId) async {
    try {
      final batch = firestore.batch();

      // Marcar todos los mensajes como leídos
      final messagesQuery =
          await firestore
              .collection(_messagesCollection)
              .where('chatId', isEqualTo: chatId)
              .where(
                'senderId',
                isNotEqualTo: userId,
              ) // Solo mensajes que no envió el usuario
              .where(
                'status',
                whereIn: ['sent', 'delivered'],
              ) // Solo mensajes no leídos
              .get();

      for (final doc in messagesQuery.docs) {
        batch.update(doc.reference, {
          'status': MessageStatus.read.name,
          'readAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      // Resetear el contador de no leídos para este usuario
      final chatRef = firestore.collection(_chatsCollection).doc(chatId);
      final chatDoc = await chatRef.get();

      if (chatDoc.exists) {
        final chatData = chatDoc.data() as Map<String, dynamic>;
        final currentUnreadCounts = Map<String, int>.from(
          chatData['unreadCounts'] ?? {},
        );
        currentUnreadCounts[userId] = 0;

        batch.update(chatRef, {
          'unreadCounts': currentUnreadCounts,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await firestore.collection(_messagesCollection).doc(messageId).delete();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<int> getUnreadMessagesCount(String userId) async {
    try {
      final chatsQuery =
          await firestore
              .collection(_chatsCollection)
              .where('participantIds', arrayContains: userId)
              .where('status', isEqualTo: 'active')
              .get();

      int totalUnread = 0;
      for (final doc in chatsQuery.docs) {
        final chatData = doc.data();
        final unreadCounts = Map<String, int>.from(
          chatData['unreadCounts'] ?? {},
        );
        totalUnread += unreadCounts[userId] ?? 0;
      }

      return totalUnread;
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> sendSystemMessage({
    required String chatId,
    required String content,
  }) async {
    try {
      final messageRef = firestore.collection(_messagesCollection).doc();
      final messageId = messageRef.id;

      final systemMessage = MessageModel(
        id: messageId,
        chatId: chatId,
        senderId: 'system',
        senderName: 'Sistema',
        type: MessageType.system,
        content: content,
        status: MessageStatus.delivered,
        timestamp: DateTime.now(),
        isSystemMessage: true,
      );

      await messageRef.set(systemMessage.toFirestore());

      // Actualizar el último mensaje del chat
      await firestore.collection(_chatsCollection).doc(chatId).update({
        'lastMessageId': messageId,
        'lastMessageText': content,
        'lastMessageSenderId': 'system',
        'lastMessageTimestamp': Timestamp.fromDate(systemMessage.timestamp),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  // Métodos auxiliares para notificaciones y estadísticas
  Future<List<String>> getChatParticipants(String chatId) async {
    try {
      final doc =
          await firestore.collection(_chatsCollection).doc(chatId).get();

      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      return List<String>.from(data['participantIds'] ?? []);
    } catch (e) {
      throw ServerException();
    }
  }

  Future<Map<String, dynamic>> getChatStatistics(String userId) async {
    try {
      final chatsQuery =
          await firestore
              .collection(_chatsCollection)
              .where('participantIds', arrayContains: userId)
              .get();

      int totalChats = chatsQuery.docs.length;
      int activeChats = 0;
      int archivedChats = 0;
      int totalUnreadMessages = 0;

      for (final doc in chatsQuery.docs) {
        final data = doc.data();
        final status = data['status'] as String?;
        final unreadCounts = Map<String, int>.from(data['unreadCounts'] ?? {});

        if (status == 'active') {
          activeChats++;
        } else if (status == 'archived') {
          archivedChats++;
        }

        totalUnreadMessages += unreadCounts[userId] ?? 0;
      }

      return {
        'totalChats': totalChats,
        'activeChats': activeChats,
        'archivedChats': archivedChats,
        'totalUnreadMessages': totalUnreadMessages,
      };
    } catch (e) {
      throw ServerException();
    }
  }
}
