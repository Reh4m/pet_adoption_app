import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_location_entity.dart';
import 'package:pet_adoption_app/src/domain/repositories/pet_repository.dart';

class GetAllPetsUseCase {
  final PetRepository repository;

  GetAllPetsUseCase(this.repository);

  Stream<Either<Failure, List<PetEntity>>> call() {
    return repository.getAllPets();
  }
}

class GetPetsByCategoryUseCase {
  final PetRepository repository;

  GetPetsByCategoryUseCase(this.repository);

  Stream<Either<Failure, List<PetEntity>>> call(String category) {
    return repository.getPetsByCategory(category);
  }
}

class GetPetByIdUseCase {
  final PetRepository repository;

  GetPetByIdUseCase(this.repository);

  Future<Either<Failure, PetEntity>> call(String petId) async {
    return await repository.getPetById(petId);
  }
}

class CreatePetUseCase {
  final PetRepository repository;

  CreatePetUseCase(this.repository);

  Future<Either<Failure, String>> call(PetEntity pet, List<File> images) async {
    return await repository.createPet(pet, images);
  }
}

class UpdatePetUseCase {
  final PetRepository repository;

  UpdatePetUseCase(this.repository);

  Future<Either<Failure, Unit>> call(PetEntity pet) async {
    return await repository.updatePet(pet);
  }
}

class UpdatePetForCompletedAdoptionUseCase {
  final PetRepository repository;

  UpdatePetForCompletedAdoptionUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String petId,
    required String adoptedByUserId,
  }) async {
    return await repository.updatePetForCompletedAdoption(
      petId: petId,
      adoptedByUserId: adoptedByUserId,
    );
  }
}

class DeletePetUseCase {
  final PetRepository repository;

  DeletePetUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String petId) async {
    return await repository.deletePet(petId);
  }
}

class GetPetsByOwnerUseCase {
  final PetRepository repository;

  GetPetsByOwnerUseCase(this.repository);

  Stream<Either<Failure, List<PetEntity>>> call(String ownerId) {
    return repository.getPetsByOwner(ownerId);
  }
}

class GetPetsNearLocationUseCase {
  final PetRepository repository;

  GetPetsNearLocationUseCase(this.repository);

  Stream<Either<Failure, List<PetEntity>>> call(
    PetLocationEntity location,
    double radiusInKm,
  ) {
    return repository.getPetsNearLocation(location, radiusInKm);
  }
}

class SearchPetsUseCase {
  final PetRepository repository;

  SearchPetsUseCase(this.repository);

  Stream<Either<Failure, List<PetEntity>>> call({
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
  }) {
    return repository.searchPets(
      query: query,
      categories: categories,
      sizes: sizes,
      genders: genders,
      vaccinated: vaccinated,
      sterilized: sterilized,
      goodWithKids: goodWithKids,
      goodWithPets: goodWithPets,
      maxAge: maxAge,
      minAge: minAge,
      location: location,
      radiusInKm: radiusInKm,
    );
  }
}

class ToggleFavoriteUseCase {
  final PetRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String petId) async {
    return await repository.toggleFavorite(petId);
  }
}

class GetFavoritePetsUseCase {
  final PetRepository repository;

  GetFavoritePetsUseCase(this.repository);

  Stream<Either<Failure, List<PetEntity>>> call() {
    return repository.getFavoritePets();
  }
}
