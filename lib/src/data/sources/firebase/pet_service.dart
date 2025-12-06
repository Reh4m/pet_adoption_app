import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_adoption_app/src/core/errors/exceptions.dart';
import 'package:pet_adoption_app/src/data/models/pet/pet_model.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/storage_service.dart';

class FirebasePetService {
  final FirebaseFirestore firestore;
  late final FirebaseStorageService storageService;

  FirebasePetService({required this.firestore, required this.storageService});

  static const String _petsCollection = 'pets';

  Stream<List<PetModel>> getAllPets() {
    try {
      return firestore
          .collection(_petsCollection)
          .where('status', isEqualTo: 'available')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => PetModel.fromFirestore(doc))
                    .toList(),
          );
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<List<PetModel>> getPetsByCategory(String category) {
    try {
      return firestore
          .collection(_petsCollection)
          .where('status', isEqualTo: 'available')
          .where('category', isEqualTo: category.toLowerCase())
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => PetModel.fromFirestore(doc))
                    .toList(),
          );
    } catch (e) {
      throw ServerException();
    }
  }

  Future<PetModel> getPetById(String petId) async {
    try {
      final doc = await firestore.collection(_petsCollection).doc(petId).get();

      if (!doc.exists) {
        throw PetNotFoundException();
      }

      return PetModel.fromFirestore(doc);
    } catch (e) {
      if (e is PetNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Stream<List<PetModel>> getPetsByOwner(String ownerId) {
    try {
      return firestore
          .collection(_petsCollection)
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => PetModel.fromFirestore(doc))
                    .toList(),
          );
    } catch (e) {
      throw ServerException();
    }
  }

  Future<String> createPet(PetModel pet, List<File> images) async {
    try {
      // 1. Crear documento en Firestore para obtener ID
      final docRef = firestore.collection(_petsCollection).doc();
      final petId = docRef.id;

      // 2. Subir imágenes con el ID de la mascota
      final imageUrls = await storageService.uploadPetImages(images, petId);

      // 3. Crear mascota con las URLs de las imágenes
      final petWithImages = PetModel.fromEntity(
        pet.copyWith(
          id: petId,
          imageUrls: imageUrls,
          createdAt: DateTime.now(),
        ),
      );

      // 4. Guardar en Firestore
      await docRef.set(petWithImages.toFirestore());

      return petId;
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> updatePet(PetModel pet) async {
    try {
      final updatedPet = PetModel.fromEntity(
        pet.copyWith(updatedAt: DateTime.now()),
      );

      await firestore
          .collection(_petsCollection)
          .doc(pet.id)
          .update(updatedPet.toFirestore());
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> deletePet(String petId) async {
    try {
      // 1. Eliminar imágenes del storage
      await storageService.deletePetImages(petId);

      // 2. Eliminar documento de Firestore
      await firestore.collection(_petsCollection).doc(petId).delete();
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<List<PetModel>> searchPets({
    String? query,
    List<String>? categories,
    List<String>? sizes,
    List<String>? genders,
    bool? vaccinated,
    bool? sterilized,
    bool? goodWithKids,
    bool? goodWithPets,
    int? maxAge,
    int? minAge,
  }) {
    try {
      Query<Map<String, dynamic>> queryRef = firestore
          .collection(_petsCollection)
          .where('status', isEqualTo: 'available');

      // Filtros básicos
      if (categories != null && categories.isNotEmpty) {
        queryRef = queryRef.where('category', whereIn: categories);
      }

      if (sizes != null && sizes.isNotEmpty) {
        queryRef = queryRef.where('size', whereIn: sizes);
      }

      if (genders != null && genders.isNotEmpty) {
        queryRef = queryRef.where('gender', whereIn: genders);
      }

      if (vaccinated != null) {
        queryRef = queryRef.where('vaccinated', isEqualTo: vaccinated);
      }

      if (sterilized != null) {
        queryRef = queryRef.where('sterilized', isEqualTo: sterilized);
      }

      if (goodWithKids != null) {
        queryRef = queryRef.where('goodWithKids', isEqualTo: goodWithKids);
      }

      if (goodWithPets != null) {
        queryRef = queryRef.where('goodWithPets', isEqualTo: goodWithPets);
      }

      // Filtros de edad
      if (minAge != null) {
        queryRef = queryRef.where(
          'ageInMonths',
          isGreaterThanOrEqualTo: minAge,
        );
      }

      if (maxAge != null) {
        queryRef = queryRef.where('ageInMonths', isLessThanOrEqualTo: maxAge);
      }

      return queryRef.orderBy('createdAt', descending: true).snapshots().map((
        snapshot,
      ) {
        List<PetModel> pets =
            snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();

        // Filtro de texto
        if (query != null && query.isNotEmpty) {
          final lowercaseQuery = query.toLowerCase();
          pets =
              pets.where((pet) {
                return pet.name.toLowerCase().contains(lowercaseQuery) ||
                    pet.breed.toLowerCase().contains(lowercaseQuery) ||
                    pet.description.toLowerCase().contains(lowercaseQuery) ||
                    pet.searchTags.any((tag) => tag.contains(lowercaseQuery));
              }).toList();
        }

        return pets;
      });
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<List<PetModel>> getPetsNearLocation(
    double latitude,
    double longitude,
    double radiusInKm,
  ) {
    try {
      return firestore
          .collection(_petsCollection)
          .where('status', isEqualTo: 'available')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => PetModel.fromFirestore(doc))
                .where((pet) {
                  // Calcular distancia
                  final distance = pet.location.distanceTo(
                    pet.location.copyWith(
                      latitude: latitude,
                      longitude: longitude,
                    ),
                  );
                  return distance <= radiusInKm;
                })
                .toList();
          });
    } catch (e) {
      throw ServerException();
    }
  }
}
