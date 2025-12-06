import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/chat_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/message_entity.dart';
import 'package:pet_adoption_app/src/domain/repositories/chat_repository.dart';

// Chat Use Cases
class CreateChatUseCase {
  final ChatRepository repository;

  CreateChatUseCase(this.repository);

  Future<Either<Failure, ChatEntity>> call({
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
    return await repository.createChat(
      adoptionRequestId: adoptionRequestId,
      petId: petId,
      petName: petName,
      petImageUrls: petImageUrls,
      requesterId: requesterId,
      requesterName: requesterName,
      requesterPhotoUrl: requesterPhotoUrl,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerPhotoUrl: ownerPhotoUrl,
    );
  }
}

class GetChatByAdoptionRequestIdUseCase {
  final ChatRepository repository;

  GetChatByAdoptionRequestIdUseCase(this.repository);

  Future<Either<Failure, ChatEntity?>> call(String adoptionRequestId) async {
    return await repository.getChatByAdoptionRequestId(adoptionRequestId);
  }
}

class GetChatByIdUseCase {
  final ChatRepository repository;

  GetChatByIdUseCase(this.repository);

  Future<Either<Failure, ChatEntity>> call(String chatId) async {
    return await repository.getChatById(chatId);
  }
}

class GetUserChatsUseCase {
  final ChatRepository repository;

  GetUserChatsUseCase(this.repository);

  Stream<Either<Failure, List<ChatEntity>>> call(String userId) {
    return repository.getUserChats(userId);
  }
}

class UpdateChatStatusUseCase {
  final ChatRepository repository;

  UpdateChatStatusUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String chatId, ChatStatus status) async {
    return await repository.updateChatStatus(chatId, status);
  }
}

class ArchiveChatUseCase {
  final ChatRepository repository;

  ArchiveChatUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String chatId) async {
    return await repository.archiveChat(chatId);
  }
}

class DeleteChatUseCase {
  final ChatRepository repository;

  DeleteChatUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String chatId) async {
    return await repository.deleteChat(chatId);
  }
}

// Message Use Cases
class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
  }) async {
    return await repository.sendMessage(
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      content: content,
      type: type,
      imageUrl: imageUrl,
    );
  }
}

class GetChatMessagesUseCase {
  final ChatRepository repository;

  GetChatMessagesUseCase(this.repository);

  Stream<Either<Failure, List<MessageEntity>>> call(String chatId) {
    return repository.getChatMessages(chatId);
  }
}

class MarkMessageAsReadUseCase {
  final ChatRepository repository;

  MarkMessageAsReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String messageId, String userId) async {
    return await repository.markMessageAsRead(messageId, userId);
  }
}

class MarkAllMessagesAsReadUseCase {
  final ChatRepository repository;

  MarkAllMessagesAsReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String chatId, String userId) async {
    return await repository.markAllMessagesAsRead(chatId, userId);
  }
}

class DeleteMessageUseCase {
  final ChatRepository repository;

  DeleteMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String messageId) async {
    return await repository.deleteMessage(messageId);
  }
}

class GetUnreadMessagesCountUseCase {
  final ChatRepository repository;

  GetUnreadMessagesCountUseCase(this.repository);

  Future<Either<Failure, int>> call(String userId) async {
    return await repository.getUnreadMessagesCount(userId);
  }
}

class UpdateUnreadCountUseCase {
  final ChatRepository repository;

  UpdateUnreadCountUseCase(this.repository);

  Future<Either<Failure, Unit>> call(
    String chatId,
    String userId,
    int count,
  ) async {
    return await repository.updateUnreadCount(chatId, userId, count);
  }
}

class SendSystemMessageUseCase {
  final ChatRepository repository;

  SendSystemMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String chatId,
    required String content,
  }) async {
    return await repository.sendSystemMessage(chatId: chatId, content: content);
  }
}

// Combined Use Cases for common operations
class CreateOrGetChatUseCase {
  final GetChatByAdoptionRequestIdUseCase getChatByAdoptionRequestId;
  final CreateChatUseCase createChat;

  CreateOrGetChatUseCase({
    required this.getChatByAdoptionRequestId,
    required this.createChat,
  });

  Future<Either<Failure, ChatEntity>> call({
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
    // Primero intentar obtener el chat existente
    final existingChatResult = await getChatByAdoptionRequestId(
      adoptionRequestId,
    );

    return existingChatResult.fold((failure) => Left(failure), (
      existingChat,
    ) async {
      if (existingChat != null) {
        // Si el chat ya existe, devolverlo
        return Right(existingChat);
      } else {
        // Si no existe, crear uno nuevo
        return await createChat(
          adoptionRequestId: adoptionRequestId,
          petId: petId,
          petName: petName,
          petImageUrls: petImageUrls,
          requesterId: requesterId,
          requesterName: requesterName,
          requesterPhotoUrl: requesterPhotoUrl,
          ownerId: ownerId,
          ownerName: ownerName,
          ownerPhotoUrl: ownerPhotoUrl,
        );
      }
    });
  }
}
