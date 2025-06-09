import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/adoption_request_entity.dart';
import 'package:pet_adoption_app/src/domain/repositories/adoption_requests_repository.dart';

class CreateAdoptionRequestUseCase {
  final AdoptionRequestsRepository repository;

  CreateAdoptionRequestUseCase(this.repository);

  Future<Either<Failure, String>> call(AdoptionRequestEntity request) async {
    return await repository.createAdoptionRequest(request);
  }
}

class GetReceivedRequestsUseCase {
  final AdoptionRequestsRepository repository;

  GetReceivedRequestsUseCase(this.repository);

  Stream<Either<Failure, List<AdoptionRequestEntity>>> call(String ownerId) {
    return repository.getReceivedRequests(ownerId);
  }
}

class GetSentRequestsUseCase {
  final AdoptionRequestsRepository repository;

  GetSentRequestsUseCase(this.repository);

  Stream<Either<Failure, List<AdoptionRequestEntity>>> call(
    String requesterId,
  ) {
    return repository.getSentRequests(requesterId);
  }
}

class GetRequestsForPetUseCase {
  final AdoptionRequestsRepository repository;

  GetRequestsForPetUseCase(this.repository);

  Stream<Either<Failure, List<AdoptionRequestEntity>>> call(String petId) {
    return repository.getRequestsForPet(petId);
  }
}

class GetRequestByIdUseCase {
  final AdoptionRequestsRepository repository;

  GetRequestByIdUseCase(this.repository);

  Future<Either<Failure, AdoptionRequestEntity>> call(String requestId) async {
    return await repository.getRequestById(requestId);
  }
}

class HasExistingRequestUseCase {
  final AdoptionRequestsRepository repository;

  HasExistingRequestUseCase(this.repository);

  Future<Either<Failure, bool>> call(String petId, String requesterId) async {
    return await repository.hasExistingRequest(petId, requesterId);
  }
}

class AcceptRequestUseCase {
  final AdoptionRequestsRepository repository;

  AcceptRequestUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String requestId, {String? notes}) async {
    return await repository.acceptRequest(requestId, notes: notes);
  }
}

class RejectRequestUseCase {
  final AdoptionRequestsRepository repository;

  RejectRequestUseCase(this.repository);

  Future<Either<Failure, Unit>> call(
    String requestId, {
    required String rejectionReason,
  }) async {
    return await repository.rejectRequest(
      requestId,
      rejectionReason: rejectionReason,
    );
  }
}

class CancelRequestUseCase {
  final AdoptionRequestsRepository repository;

  CancelRequestUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String requestId) async {
    return await repository.cancelRequest(requestId);
  }
}

class CompleteRequestUseCase {
  final AdoptionRequestsRepository repository;

  CompleteRequestUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String requestId, {String? notes}) async {
    return await repository.completeRequest(requestId, notes: notes);
  }
}

class GetRequestStatisticsUseCase {
  final AdoptionRequestsRepository repository;

  GetRequestStatisticsUseCase(this.repository);

  Future<Either<Failure, Map<String, int>>> call(String userId) async {
    return await repository.getRequestStatistics(userId);
  }
}

class RejectPendingRequestsForPetUseCase {
  final AdoptionRequestsRepository repository;

  RejectPendingRequestsForPetUseCase(this.repository);

  Future<Either<Failure, Unit>> call(
    String petId,
    String acceptedRequestId,
  ) async {
    return await repository.rejectPendingRequestsForPet(
      petId,
      acceptedRequestId,
    );
  }
}
