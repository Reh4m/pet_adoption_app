import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/adoption_request_entity.dart';

abstract class AdoptionRequestsRepository {
  Future<Either<Failure, String>> createAdoptionRequest(
    AdoptionRequestEntity request,
  );

  Stream<Either<Failure, List<AdoptionRequestEntity>>> getReceivedRequests(
    String ownerId,
  );

  Stream<Either<Failure, List<AdoptionRequestEntity>>> getSentRequests(
    String requesterId,
  );

  Stream<Either<Failure, List<AdoptionRequestEntity>>> getRequestsForPet(
    String petId,
  );

  Future<Either<Failure, AdoptionRequestEntity>> getRequestById(
    String requestId,
  );

  Future<Either<Failure, bool>> hasExistingRequest(
    String petId,
    String requesterId,
  );

  Future<Either<Failure, Unit>> acceptRequest(
    String requestId, {
    String? notes,
  });

  Future<Either<Failure, Unit>> rejectRequest(
    String requestId, {
    required String rejectionReason,
  });

  Future<Either<Failure, Unit>> cancelRequest(String requestId);

  Future<Either<Failure, Unit>> completeRequest(
    String requestId, {
    String? notes,
  });

  Future<Either<Failure, Map<String, int>>> getRequestStatistics(String userId);

  Future<Either<Failure, Unit>> rejectPendingRequestsForPet(
    String petId,
    String acceptedRequestId,
  );
}
