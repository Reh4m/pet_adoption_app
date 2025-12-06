import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/adoption_request_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/chat_entity.dart';
import 'package:pet_adoption_app/src/domain/repositories/adoption_requests_repository.dart';
import 'package:pet_adoption_app/src/domain/repositories/chat_repository.dart';
import 'package:pet_adoption_app/src/domain/repositories/pets_repository.dart';
import 'package:pet_adoption_app/src/domain/repositories/user_repository.dart';

class InitiateChatFromAdoptionRequestUseCase {
  final ChatRepository chatRepository;
  final AdoptionRequestsRepository adoptionRepository;
  final PetsRepository petsRepository;
  final UserRepository userRepository;

  InitiateChatFromAdoptionRequestUseCase({
    required this.chatRepository,
    required this.adoptionRepository,
    required this.petsRepository,
    required this.userRepository,
  });

  Future<Either<Failure, ChatEntity>> call(String adoptionRequestId) async {
    try {
      // 1. Obtener la solicitud de adopción
      final requestResult = await adoptionRepository.getRequestById(
        adoptionRequestId,
      );

      return await requestResult.fold((failure) async => Left(failure), (
        request,
      ) async {
        // 2. Obtener información de la mascota
        final petResult = await petsRepository.getPetById(request.petId);

        return await petResult.fold((failure) async => Left(failure), (
          pet,
        ) async {
          // 3. Obtener información de los usuarios
          final requesterResult = await userRepository.getUserById(
            request.requesterId,
          );
          final ownerResult = await userRepository.getUserById(request.ownerId);

          return await requesterResult.fold((failure) async => Left(failure), (
            requester,
          ) async {
            return await ownerResult.fold((failure) async => Left(failure), (
              owner,
            ) async {
              // 4. Verificar si ya existe un chat para esta solicitud
              final existingChatResult = await chatRepository
                  .getChatByAdoptionRequestId(adoptionRequestId);

              return await existingChatResult.fold(
                (failure) async => Left(failure),
                (existingChat) async {
                  if (existingChat != null) {
                    return Right(existingChat);
                  }

                  // 5. Crear el chat si no existe
                  return await chatRepository.createChat(
                    adoptionRequestId: adoptionRequestId,
                    petId: pet.id,
                    petName: pet.name,
                    petImageUrls: pet.imageUrls,
                    requesterId: requester.id,
                    requesterName: requester.name,
                    requesterPhotoUrl: requester.photoUrl,
                    ownerId: owner.id,
                    ownerName: owner.name,
                    ownerPhotoUrl: owner.photoUrl,
                  );
                },
              );
            });
          });
        });
      });
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

class SendAdoptionStatusUpdateUseCase {
  final ChatRepository chatRepository;

  SendAdoptionStatusUpdateUseCase(this.chatRepository);

  Future<Either<Failure, Unit>> call({
    required String adoptionRequestId,
    required AdoptionRequestStatus newStatus,
    String? additionalMessage,
  }) async {
    try {
      // Obtener el chat asociado a la solicitud
      final chatResult = await chatRepository.getChatByAdoptionRequestId(
        adoptionRequestId,
      );

      return await chatResult.fold((failure) async => Left(failure), (
        chat,
      ) async {
        if (chat == null) {
          return Left(ChatNotFoundFailure());
        }

        // Generar mensaje del sistema basado en el estado
        String systemMessage = _generateStatusMessage(
          newStatus,
          additionalMessage,
        );

        return await chatRepository.sendSystemMessage(
          chatId: chat.id,
          content: systemMessage,
        );
      });
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  String _generateStatusMessage(
    AdoptionRequestStatus status,
    String? additionalMessage,
  ) {
    String baseMessage;

    switch (status) {
      case AdoptionRequestStatus.accepted:
        baseMessage = '🎉 ¡Tu solicitud de adopción ha sido aceptada!';
        break;
      case AdoptionRequestStatus.rejected:
        baseMessage = '😔 Tu solicitud de adopción ha sido rechazada.';
        break;
      case AdoptionRequestStatus.completed:
        baseMessage = '✅ ¡La adopción se ha completado exitosamente!';
        break;
      case AdoptionRequestStatus.cancelled:
        baseMessage = '❌ La solicitud de adopción ha sido cancelada.';
        break;
      default:
        baseMessage = 'El estado de tu solicitud ha sido actualizado.';
    }

    if (additionalMessage != null && additionalMessage.isNotEmpty) {
      baseMessage += '\n\nMensaje adicional: $additionalMessage';
    }

    return baseMessage;
  }
}
