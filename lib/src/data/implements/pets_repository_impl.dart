import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/exceptions.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/core/network/network_info.dart';
import 'package:pet_adoption_app/src/data/models/pet/pet_model.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/pets_service.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_location_entity.dart';
import 'package:pet_adoption_app/src/domain/repositories/pets_repository.dart';

class PetsRepositoryImpl implements PetsRepository {
  final FirebasePetsService firebasePetsService;
  final NetworkInfo networkInfo;

  PetsRepositoryImpl({
    required this.firebasePetsService,
    required this.networkInfo,
  });

  @override
  Stream<Either<Failure, List<PetEntity>>> getAllPets() async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final pets in firebasePetsService.getAllPets()) {
        yield Right(pets.cast<PetEntity>());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<PetEntity>>> getPetsByCategory(
    String category,
  ) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final pets in firebasePetsService.getPetsByCategory(
        category,
      )) {
        yield Right(pets.cast<PetEntity>());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PetEntity>> getPetById(String petId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final pet = await firebasePetsService.getPetById(petId);
      return Right(pet);
    } on PetNotFoundException {
      return Left(PetNotFoundFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<PetEntity>>> getPetsByOwner(
    String ownerId,
  ) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final pets in firebasePetsService.getPetsByOwner(ownerId)) {
        yield Right(pets.cast<PetEntity>());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> createPet(
    PetEntity pet,
    List<File> images,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final petModel = PetModel.fromEntity(pet);
      final petId = await firebasePetsService.createPet(petModel, images);
      return Right(petId);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePet(PetEntity pet) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final petModel = PetModel.fromEntity(pet);
      await firebasePetsService.updatePet(petModel);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePet(String petId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebasePetsService.deletePet(petId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<PetEntity>>> getPetsNearLocation(
    PetLocationEntity location,
    double radiusInKm,
  ) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final pets in firebasePetsService.getPetsNearLocation(
        location.latitude,
        location.longitude,
        radiusInKm,
      )) {
        yield Right(pets.cast<PetEntity>());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
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
  }) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final pets in firebasePetsService.searchPets(
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
      )) {
        yield Right(pets.cast<PetEntity>());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleFavorite(String petId) async {
    // TODO: Implementar funcionalidad de favoritos
    return const Right(unit);
  }

  @override
  Stream<Either<Failure, List<PetEntity>>> getFavoritePets() async* {
    // TODO: Implementar funcionalidad de favoritos
    yield const Right([]);
  }
}
