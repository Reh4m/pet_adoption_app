import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_location_entity.dart';

abstract class PetRepository {
  // Obtener mascotas
  Stream<Either<Failure, List<PetEntity>>> getAllPets();

  Stream<Either<Failure, List<PetEntity>>> getPetsByCategory(String category);

  Future<Either<Failure, PetEntity>> getPetById(String petId);

  Stream<Either<Failure, List<PetEntity>>> getPetsByOwner(String ownerId);

  Stream<Either<Failure, List<PetEntity>>> getPetsNearLocation(
    PetLocationEntity location,
    double radiusInKm,
  );

  // Operaciones CRUD
  Future<Either<Failure, String>> createPet(PetEntity pet, List<File> images);

  Future<Either<Failure, Unit>> updatePet(PetEntity pet);

  Future<Either<Failure, Unit>> updatePetForCompletedAdoption({
    required String petId,
    required String adoptedByUserId,
  });

  Future<Either<Failure, Unit>> deletePet(String petId);

  // Búsquedas avanzadas
  Stream<Either<Failure, List<PetEntity>>> searchPets({
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
    PetLocationEntity? location,
    double? radiusInKm,
  });

  Future<Either<Failure, Unit>> toggleFavorite(String petId);
  Stream<Either<Failure, List<PetEntity>>> getFavoritePets();
}
