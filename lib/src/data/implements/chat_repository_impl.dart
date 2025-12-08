import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/exceptions.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/core/network/network_info.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/chat_service.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/chat_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/message_entity.dart';
import 'package:pet_adoption_app/src/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseChatService firebaseChatService;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({
    required this.firebaseChatService,
    required this.networkInfo,
  });

  @override
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
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final chat = await firebaseChatService.createChat(
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
      return Right(chat.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ChatEntity?>> getChatByAdoptionRequestId(
    String adoptionRequestId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final chat = await firebaseChatService.getChatByAdoptionRequestId(
        adoptionRequestId,
      );
      return Right(chat?.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ChatEntity>> getChatById(String chatId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final chat = await firebaseChatService.getChatById(chatId);
      return Right(chat.toEntity());
    } on ChatNotFoundException {
      return Left(ChatNotFoundFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<ChatEntity>>> getUserChatsStream(
    String userId,
  ) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final chats in firebaseChatService.getUserChatsStream(
        userId,
      )) {
        yield Right(chats.map((chat) => chat.toEntity()).toList());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateChatStatus(
    String chatId,
    ChatStatus status,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseChatService.updateChatStatus(chatId, status);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> archiveChat(String chatId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseChatService.archiveChat(chatId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteChat(String chatId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseChatService.deleteChat(chatId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final messageId = await firebaseChatService.sendMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        content: content,
        type: type,
        imageUrl: imageUrl,
      );
      return Right(messageId);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getChatMessagesStream(
    String chatId,
  ) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final messages in firebaseChatService.getChatMessagesStream(
        chatId,
      )) {
        yield Right(messages.map((message) => message.toEntity()).toList());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markMessageAsRead(
    String messageId,
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseChatService.markMessageAsRead(messageId, userId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllMessagesAsDelivered(
    String chatId,
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseChatService.markAllMessagesAsDelivered(chatId, userId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllMessagesAsRead(
    String chatId,
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseChatService.markAllMessagesAsRead(chatId, userId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage(String messageId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseChatService.deleteMessage(messageId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadMessagesCount(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final count = await firebaseChatService.getUnreadMessagesCount(userId);
      return Right(count);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendSystemMessage({
    required String chatId,
    required String content,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseChatService.sendSystemMessage(
        chatId: chatId,
        content: content,
      );
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
