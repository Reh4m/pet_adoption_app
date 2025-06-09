import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/user_entity.dart';
import 'package:pet_adoption_app/src/domain/repositories/user_repository.dart';

class GetUserByIdUseCase {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String userId) async {
    return await repository.getUserById(userId);
  }
}

class GetCurrentUserUseCase {
  final UserRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call() async {
    return await repository.getCurrentUser();
  }
}

class GetCurrentUserStreamUseCase {
  final UserRepository repository;

  GetCurrentUserStreamUseCase(this.repository);

  Stream<Either<Failure, UserEntity>> call() {
    return repository.getCurrentUserStream();
  }
}

class CreateUserUseCase {
  final UserRepository repository;

  CreateUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(UserEntity user) async {
    return await repository.createUser(user);
  }
}

class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(UserEntity user) async {
    return await repository.updateUser(user);
  }
}

class DeleteUserUseCase {
  final UserRepository repository;

  DeleteUserUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String userId) async {
    return await repository.deleteUser(userId);
  }
}

class UploadProfileImageUseCase {
  final UserRepository repository;

  UploadProfileImageUseCase(this.repository);

  Future<Either<Failure, String>> call(File image, String userId) async {
    return await repository.uploadProfileImage(image, userId);
  }
}

class UpdateProfileImageUseCase {
  final UserRepository repository;

  UpdateProfileImageUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(
    String userId,
    String imageUrl,
  ) async {
    return await repository.updateProfileImage(userId, imageUrl);
  }
}

class ChangeProfilePhotoUseCase {
  final UserRepository repository;

  ChangeProfilePhotoUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(File image, String userId) async {
    final uploadResult = await repository.uploadProfileImage(image, userId);

    return uploadResult.fold((failure) => Left(failure), (imageUrl) async {
      return await repository.updateProfileImage(userId, imageUrl);
    });
  }
}

class IncrementPetsPostedUseCase {
  final UserRepository repository;

  IncrementPetsPostedUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String userId) async {
    return await repository.incrementPetsPosted(userId);
  }
}

class IncrementPetsAdoptedUseCase {
  final UserRepository repository;

  IncrementPetsAdoptedUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String userId) async {
    return await repository.incrementPetsAdopted(userId);
  }
}

class DecrementPetsPostedUseCase {
  final UserRepository repository;

  DecrementPetsPostedUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String userId) async {
    return await repository.decrementPetsPosted(userId);
  }
}

class UpdateNotificationSettingsUseCase {
  final UserRepository repository;

  UpdateNotificationSettingsUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(
    String userId, {
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
  }) async {
    return await repository.updateNotificationSettings(
      userId,
      notificationsEnabled: notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
    );
  }
}

class UpdateSearchRadiusUseCase {
  final UserRepository repository;

  UpdateSearchRadiusUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String userId, double radius) async {
    return await repository.updateSearchRadius(userId, radius);
  }
}

class MarkUserAsVerifiedUseCase {
  final UserRepository repository;

  MarkUserAsVerifiedUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String userId) async {
    return await repository.markUserAsVerified(userId);
  }
}

class CheckUserExistsUseCase {
  final UserRepository repository;

  CheckUserExistsUseCase(this.repository);

  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.checkUserExists(userId);
  }
}
