import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/chat_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatEntity>> createChat({
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
  });

  Future<Either<Failure, ChatEntity?>> getChatByAdoptionRequestId(
    String adoptionRequestId,
  );

  Future<Either<Failure, ChatEntity>> getChatById(String chatId);

  Stream<Either<Failure, List<ChatEntity>>> getUserChats(String userId);

  Future<Either<Failure, Unit>> updateChatStatus(
    String chatId,
    ChatStatus status,
  );

  Future<Either<Failure, Unit>> archiveChat(String chatId);

  Future<Either<Failure, Unit>> deleteChat(String chatId);

  Future<Either<Failure, String>> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
  });

  Stream<Either<Failure, List<MessageEntity>>> getChatMessages(String chatId);

  Future<Either<Failure, Unit>> markMessageAsRead(
    String messageId,
    String userId,
  );

  Future<Either<Failure, Unit>> markAllMessagesAsRead(
    String chatId,
    String userId,
  );

  Future<Either<Failure, Unit>> deleteMessage(String messageId);

  Future<Either<Failure, int>> getUnreadMessagesCount(String userId);

  Future<Either<Failure, Unit>> updateUnreadCount(
    String chatId,
    String userId,
    int count,
  );

  Future<Either<Failure, Unit>> sendSystemMessage({
    required String chatId,
    required String content,
  });
}
