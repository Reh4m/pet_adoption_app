import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/exceptions.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/core/network/network_info.dart';
import 'package:pet_adoption_app/src/data/models/adoption_request_model.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/adoption_requests_service.dart';
import 'package:pet_adoption_app/src/domain/entities/adoption_request_entity.dart';
import 'package:pet_adoption_app/src/domain/repositories/adoption_requests_repository.dart';

class AdoptionRequestsRepositoryImpl implements AdoptionRequestsRepository {
  final FirebaseAdoptionRequestsService firebaseService;
  final NetworkInfo networkInfo;

  AdoptionRequestsRepositoryImpl({
    required this.firebaseService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> createAdoptionRequest(
    AdoptionRequestEntity request,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final requestModel = AdoptionRequestModel.fromEntity(request);
      final requestId = await firebaseService.createAdoptionRequest(
        requestModel,
      );
      return Right(requestId);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getRequestStatistics(
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final statistics = await firebaseService.getRequestStatistics(userId);
      return Right(statistics);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> rejectPendingRequestsForPet(
    String petId,
    String acceptedRequestId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseService.rejectPendingRequestsForPet(
        petId,
        acceptedRequestId,
      );
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<AdoptionRequestEntity>>> getReceivedRequests(
    String ownerId,
  ) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final requests in firebaseService.getReceivedRequests(
        ownerId,
      )) {
        yield Right(requests.map((model) => model.toEntity()).toList());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<AdoptionRequestEntity>>> getSentRequests(
    String requesterId,
  ) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final requests in firebaseService.getSentRequests(
        requesterId,
      )) {
        yield Right(requests.map((model) => model.toEntity()).toList());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<AdoptionRequestEntity>>> getRequestsForPet(
    String petId,
  ) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final requests in firebaseService.getRequestsForPet(petId)) {
        yield Right(requests.map((model) => model.toEntity()).toList());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AdoptionRequestEntity>> getRequestById(
    String requestId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final request = await firebaseService.getRequestById(requestId);
      return Right(request.toEntity());
    } on AdoptionRequestNotFoundException {
      return Left(AdoptionRequestNotFoundFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> hasExistingRequest(
    String petId,
    String requesterId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final hasRequest = await firebaseService.hasExistingRequest(
        petId,
        requesterId,
      );
      return Right(hasRequest);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptRequest(
    String requestId, {
    String? notes,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseService.acceptRequest(requestId, notes: notes);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> rejectRequest(
    String requestId, {
    required String rejectionReason,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseService.rejectRequest(
        requestId,
        rejectionReason: rejectionReason,
      );
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelRequest(String requestId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseService.cancelRequest(requestId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> completeRequest(
    String requestId, {
    String? notes,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseService.completeRequest(requestId, notes: notes);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
