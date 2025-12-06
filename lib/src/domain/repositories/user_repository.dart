import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> getUserById(String userId);

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Stream<Either<Failure, UserEntity>> getCurrentUserStream();

  // Operaciones CRUD
  Future<Either<Failure, UserEntity>> createUser(UserEntity user);

  Future<Either<Failure, UserEntity>> updateUser(UserEntity user);

  Future<Either<Failure, Unit>> deleteUser(String userId);

  // Actualización de foto de perfil
  Future<Either<Failure, String>> uploadProfileImage(File image, String userId);

  Future<Either<Failure, UserEntity>> updateProfileImage(
    String userId,
    String imageUrl,
  );

  // Estadísticas
  Future<Either<Failure, Unit>> incrementPetsPosted(String userId);

  Future<Either<Failure, Unit>> incrementPetsAdopted(String userId);

  Future<Either<Failure, Unit>> decrementPetsPosted(String userId);

  // Configuraciones
  Future<Either<Failure, UserEntity>> updateNotificationSettings(
    String userId, {
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
  });

  Future<Either<Failure, UserEntity>> updateSearchRadius(
    String userId,
    double radius,
  );

  // Verificaciones
  Future<Either<Failure, Unit>> markUserAsVerified(String userId);

  Future<Either<Failure, bool>> checkUserExists(String userId);
}
