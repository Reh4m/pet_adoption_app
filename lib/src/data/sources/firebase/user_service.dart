import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pet_adoption_app/src/core/errors/exceptions.dart';
import 'package:pet_adoption_app/src/data/models/user_model.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/storage_service.dart';
import 'package:pet_adoption_app/src/domain/entities/user_entity.dart';

class FirebaseUsersService {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  late final FirebaseStorageService storageService;

  FirebaseUsersService({required this.firestore, required this.storage}) {
    storageService = FirebaseStorageService(storage: storage);
  }

  static const String _usersCollection = 'users';

  Future<UserModel> getUserById(String userId) async {
    try {
      final doc =
          await firestore.collection(_usersCollection).doc(userId).get();

      if (!doc.exists) {
        throw UserNotFoundException();
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseInstance = FirebaseAuth.instance;

      await firebaseInstance.currentUser?.reload();

      final currentUser = firebaseInstance.currentUser;

      if (currentUser == null) return null;

      final doc =
          await firestore
              .collection(_usersCollection)
              .doc(currentUser.uid)
              .get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<UserModel?> getCurrentUserStream() {
    try {
      final firebaseInstance = FirebaseAuth.instance;

      final currentUser = firebaseInstance.currentUser;

      if (currentUser == null) {
        return Stream.value(null);
      }

      return firestore
          .collection(_usersCollection)
          .doc(currentUser.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return null;
            return UserModel.fromFirestore(doc);
          });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<UserModel> createUser(UserModel user) async {
    try {
      final userWithTimestamp = user.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(userWithTimestamp.toFirestore());

      return userWithTimestamp;
    } catch (e) {
      if (e is FirebaseException && e.code == 'already-exists') {
        throw UserAlreadyExistsException();
      }
      throw ServerException();
    }
  }

  Future<UserModel> updateUser(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());

      await firestore
          .collection(_usersCollection)
          .doc(user.id)
          .update(updatedUser.toFirestore());

      return updatedUser;
    } catch (e) {
      if (e is FirebaseException && e.code == 'not-found') {
        throw UserNotFoundException();
      }
      throw UserUpdateFailedException();
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      // 1. Eliminar foto de perfil si existe
      try {
        await storageService.deleteImageByUrl('users/$userId/profile.jpg');
      } catch (e) {
        // Si no existe la imagen, continuar
      }

      // 2. Eliminar documento de usuario
      await firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<String> uploadProfileImage(File image, String userId) async {
    try {
      return await storageService.uploadUserProfileImage(image, userId);
    } catch (e) {
      throw ProfileImageUploadException();
    }
  }

  Future<UserModel> updateProfileImage(String userId, String imageUrl) async {
    try {
      await firestore.collection(_usersCollection).doc(userId).update({
        'photoUrl': imageUrl,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Retornar el usuario actualizado
      return await getUserById(userId);
    } catch (e) {
      throw UserUpdateFailedException();
    }
  }

  Future<void> incrementPetsPosted(String userId) async {
    try {
      await firestore.collection(_usersCollection).doc(userId).update({
        'petsPosted': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> incrementPetsAdopted(String userId) async {
    try {
      await firestore.collection(_usersCollection).doc(userId).update({
        'petsAdopted': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> decrementPetsPosted(String userId) async {
    try {
      await firestore.collection(_usersCollection).doc(userId).update({
        'petsPosted': FieldValue.increment(-1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<UserModel> updateNotificationSettings(
    String userId, {
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (notificationsEnabled != null) {
        updateData['notificationsEnabled'] = notificationsEnabled;
      }

      if (emailNotificationsEnabled != null) {
        updateData['emailNotificationsEnabled'] = emailNotificationsEnabled;
      }

      await firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(updateData);

      return await getUserById(userId);
    } catch (e) {
      throw UserUpdateFailedException();
    }
  }

  Future<UserModel> updateSearchRadius(String userId, double radius) async {
    try {
      await firestore.collection(_usersCollection).doc(userId).update({
        'searchRadius': radius,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return await getUserById(userId);
    } catch (e) {
      throw UserUpdateFailedException();
    }
  }

  Future<void> markUserAsVerified(String userId) async {
    try {
      await firestore.collection(_usersCollection).doc(userId).update({
        'isVerified': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<bool> checkUserExists(String userId) async {
    try {
      final doc =
          await firestore.collection(_usersCollection).doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw ServerException();
    }
  }

  Future<UserModel> createOrUpdateUserFromAuth(User firebaseUser) async {
    try {
      final userDoc =
          await firestore
              .collection(_usersCollection)
              .doc(firebaseUser.uid)
              .get();

      if (userDoc.exists) {
        // Usuario ya existe, actualizar solo si es necesario
        final existingUser = UserModel.fromFirestore(userDoc);

        // Verificar si necesita actualización
        final needsUpdate =
            existingUser.name != (firebaseUser.displayName ?? '') ||
            existingUser.email != firebaseUser.email! ||
            existingUser.photoUrl != firebaseUser.photoURL;

        if (needsUpdate) {
          final updatedUser = existingUser.copyWith(
            name: firebaseUser.displayName ?? existingUser.name,
            email: firebaseUser.email!,
            photoUrl: firebaseUser.photoURL,
            updatedAt: DateTime.now(),
          );

          await updateUser(updatedUser);
          return updatedUser;
        }

        return existingUser;
      } else {
        // Crear nuevo usuario
        final newUser = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email!,
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          authProvider: _detectUserAuthProvider(firebaseUser),
          isVerified: firebaseUser.emailVerified,
        );

        return await createUser(newUser);
      }
    } catch (e) {
      throw ServerException();
    }
  }

  UserAuthProvider _detectUserAuthProvider(User firebaseUser) {
    for (final provider in firebaseUser.providerData) {
      if (provider.providerId == 'google.com') {
        return UserAuthProvider.google;
      }
    }
    return UserAuthProvider.email;
  }
}
