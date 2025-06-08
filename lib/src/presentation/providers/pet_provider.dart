import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/core/di/index.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_location_entity.dart';
import 'package:pet_adoption_app/src/domain/usecases/pets_usecases.dart';

enum PetState { initial, loading, success, error }

class PetProvider extends ChangeNotifier {
  final GetAllPetsUseCase _getAllPetsUseCase = sl<GetAllPetsUseCase>();
  final GetPetsByCategoryUseCase _getPetsByCategoryUseCase =
      sl<GetPetsByCategoryUseCase>();
  final GetPetByIdUseCase _getPetByIdUseCase = sl<GetPetByIdUseCase>();
  final CreatePetUseCase _createPetUseCase = sl<CreatePetUseCase>();
  final UpdatePetUseCase _updatePetUseCase = sl<UpdatePetUseCase>();
  final DeletePetUseCase _deletePetUseCase = sl<DeletePetUseCase>();
  final SearchPetsUseCase _searchPetsUseCase = sl<SearchPetsUseCase>();
  final GetPetsNearLocationUseCase _getPetsNearLocationUseCase =
      sl<GetPetsNearLocationUseCase>();

  PetState _state = PetState.initial;
  String? _errorMessage;
  PetEntity? _selectedPet;

  PetState _createUpdateState = PetState.initial;
  String? _createUpdateError;

  PetState get state => _state;
  String? get errorMessage => _errorMessage;
  PetEntity? get selectedPet => _selectedPet;
  PetState get createUpdateState => _createUpdateState;
  String? get createUpdateError => _createUpdateError;

  Stream<List<PetEntity>?> getAllPets() {
    return _getAllPetsUseCase().map((either) {
      return either.fold(
        (failure) {
          _setError(_mapFailureToMessage(failure));
          return null;
        },
        (pets) {
          _clearError();
          return pets;
        },
      );
    });
  }

  Stream<List<PetEntity>?> getPetsByCategory(String category) {
    return _getPetsByCategoryUseCase(category).map((either) {
      return either.fold(
        (failure) {
          _setError(_mapFailureToMessage(failure));
          return null;
        },
        (pets) {
          _clearError();
          return pets;
        },
      );
    });
  }

  Stream<List<PetEntity>?> searchPets({
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
    return _searchPetsUseCase(
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
    ).map((either) {
      return either.fold(
        (failure) {
          _setError(_mapFailureToMessage(failure));
          return null;
        },
        (pets) {
          _clearError();
          return pets;
        },
      );
    });
  }

  Stream<List<PetEntity>?> getPetsNearLocation(
    PetLocationEntity location,
    double radiusInKm,
  ) {
    return _getPetsNearLocationUseCase(location, radiusInKm).map((either) {
      return either.fold(
        (failure) {
          _setError(_mapFailureToMessage(failure));
          return null;
        },
        (pets) {
          _clearError();
          return pets;
        },
      );
    });
  }

  Future<void> getPetById(String petId) async {
    _setState(PetState.loading);

    final result = await _getPetByIdUseCase(petId);

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (pet) {
      _selectedPet = pet;
      _setState(PetState.success);
    });
  }

  Future<String?> createPet(PetEntity pet, List<File> images) async {
    _setCreateUpdateState(PetState.loading);

    final result = await _createPetUseCase(pet, images);

    return result.fold(
      (failure) {
        _setCreateUpdateError(_mapFailureToMessage(failure));
        return null;
      },
      (petId) {
        _setCreateUpdateState(PetState.success);
        return petId;
      },
    );
  }

  Future<bool> updatePet(PetEntity pet) async {
    _setCreateUpdateState(PetState.loading);

    final result = await _updatePetUseCase(pet);

    return result.fold(
      (failure) {
        _setCreateUpdateError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setCreateUpdateState(PetState.success);
        return true;
      },
    );
  }

  Future<bool> deletePet(String petId) async {
    _setState(PetState.loading);

    final result = await _deletePetUseCase(petId);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setState(PetState.success);
        return true;
      },
    );
  }

  // Utils
  void _setState(PetState newState) {
    _state = newState;
    if (newState != PetState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(PetState.error);
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == PetState.error) {
      _setState(PetState.initial);
    }
  }

  void _setCreateUpdateState(PetState newState) {
    _createUpdateState = newState;
    if (newState != PetState.error) {
      _createUpdateError = null;
    }
    notifyListeners();
  }

  void _setCreateUpdateError(String message) {
    _createUpdateError = message;
    _setCreateUpdateState(PetState.error);
  }

  void clearCreateUpdateState() {
    _createUpdateState = PetState.initial;
    _createUpdateError = null;
    notifyListeners();
  }

  void clearSelectedPet() {
    _selectedPet = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return 'Sin conexión a internet';
      case const (ServerFailure):
        return 'Error del servidor';
      case const (PetNotFoundFailure):
        return 'Mascota no encontrada';
      default:
        return 'Error inesperado';
    }
  }
}
