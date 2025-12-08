import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/exceptions.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/core/network/network_info.dart';
import 'package:pet_adoption_app/src/data/models/user_model.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/user_service.dart';
import 'package:pet_adoption_app/src/domain/entities/user_entity.dart';
import 'package:pet_adoption_app/src/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseUserService firebaseUsersService;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.firebaseUsersService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> getUserById(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final user = await firebaseUsersService.getUserById(userId);
      return Right(user.toEntity());
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final user = await firebaseUsersService.getCurrentUser();
      return Right(user?.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, UserEntity>> getCurrentUserStream() async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final user in firebaseUsersService.getCurrentUserStream()) {
        if (user != null) {
          yield Right(user.toEntity());
        } else {
          yield Left(UserNotFoundFailure());
        }
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createUser(UserEntity user) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final userModel = UserModel.fromEntity(user);
      final createdUser = await firebaseUsersService.createUser(userModel);
      return Right(createdUser.toEntity());
    } on UserAlreadyExistsException {
      return Left(UserAlreadyExistsFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final userModel = UserModel.fromEntity(user);

      // 1. Actualizar datos del usuario en Firestore
      final updatedUser = await firebaseUsersService.updateFirestoreUser(
        userModel,
      );

      // 2. Actualizar perfil en Firebase Auth
      await firebaseUsersService.updateFirebaseAuthUser(
        displayName: user.name,
        photoUrl: user.photoUrl,
      );

      return Right(updatedUser.toEntity());
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on UserUpdateFailedException {
      return Left(UserUpdateFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseUsersService.deleteUser(userId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(
    File image,
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final imageUrl = await firebaseUsersService.uploadProfileImage(
        image,
        userId,
      );
      return Right(imageUrl);
    } on ProfileImageUploadException {
      return Left(ProfileImageUploadFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfileImage(
    String userId,
    String imageUrl,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final updatedUser = await firebaseUsersService.updateProfileImage(
        userId,
        imageUrl,
      );
      return Right(updatedUser.toEntity());
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on UserUpdateFailedException {
      return Left(UserUpdateFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> incrementPetsPosted(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseUsersService.incrementPetsPosted(userId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> incrementPetsAdopted(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseUsersService.incrementPetsAdopted(userId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> decrementPetsPosted(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseUsersService.decrementPetsPosted(userId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateNotificationSettings(
    String userId, {
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final updatedUser = await firebaseUsersService.updateNotificationSettings(
        userId,
        notificationsEnabled: notificationsEnabled,
        emailNotificationsEnabled: emailNotificationsEnabled,
      );
      return Right(updatedUser.toEntity());
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on UserUpdateFailedException {
      return Left(UserUpdateFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateSearchRadius(
    String userId,
    double radius,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final updatedUser = await firebaseUsersService.updateSearchRadius(
        userId,
        radius,
      );
      return Right(updatedUser.toEntity());
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on UserUpdateFailedException {
      return Left(UserUpdateFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markUserAsVerified(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseUsersService.markUserAsVerified(userId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> checkUserExists(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final exists = await firebaseUsersService.checkUserExists(userId);
      return Right(exists);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
