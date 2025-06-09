import 'dart:async';
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

  PetState _state = PetState.initial;
  String? _errorMessage;

  List<PetEntity> _allPets = [];
  Map<String, List<PetEntity>> _petsByCategory = {};
  PetEntity? _selectedPet;

  StreamSubscription? _allPetsSubscription;
  final Map<String, StreamSubscription> _categorySubscriptions = {};

  PetState _createUpdateState = PetState.initial;
  String? _createUpdateError;

  PetState get state => _state;
  String? get errorMessage => _errorMessage;
  PetState get createUpdateState => _createUpdateState;
  String? get createUpdateError => _createUpdateError;

  List<PetEntity> get allPets => List.from(_allPets);
  PetEntity? get selectedPet => _selectedPet;

  List<PetEntity> getPetsByCategory(String category) {
    return List.from(_petsByCategory[category] ?? []);
  }

  void _startAllPetsListener() {
    _setState(PetState.loading);

    _allPetsSubscription = _getAllPetsUseCase().listen((either) {
      either.fold((failure) => _setError(_mapFailureToMessage(failure)), (
        pets,
      ) {
        _allPets = pets;
        _setState(PetState.success);
        _organizePetsByCategory();
      });
    }, onError: (error) => _setError('Error de conexión: $error'));
  }

  void startRealtimeUpdates() {
    _startAllPetsListener();
  }

  void stopRealtimeUpdates() {
    _allPetsSubscription?.cancel();
    for (final subscription in _categorySubscriptions.values) {
      subscription.cancel();
    }
    _categorySubscriptions.clear();
  }

  void startCategoryListener(String category) {
    // Evitar múltiples listeners para la misma categoría
    if (_categorySubscriptions.containsKey(category)) return;

    _categorySubscriptions[category] = _getPetsByCategoryUseCase(
      category,
    ).listen((either) {
      either.fold((failure) => _setError(_mapFailureToMessage(failure)), (
        pets,
      ) {
        _petsByCategory[category] = pets;
        notifyListeners();
      });
    });
  }

  void stopCategoryListener(String category) {
    _categorySubscriptions[category]?.cancel();
    _categorySubscriptions.remove(category);
  }

  void _organizePetsByCategory() {
    _petsByCategory.clear();

    for (final pet in _allPets) {
      final category = pet.category;
      if (!_petsByCategory.containsKey(category)) {
        _petsByCategory[category] = [];
      }
      _petsByCategory[category]!.add(pet);
    }
  }

  Future<void> loadPetsOnce() async {
    _setState(PetState.loading);

    final result = await _getAllPetsUseCase().first;

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (pets) {
      _allPets = pets;
      _organizePetsByCategory();
      _setState(PetState.success);
    });
  }

  Future<void> refreshPets() async {
    // Para pull-to-refresh
    await loadPetsOnce();
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

        final newPet = pet.copyWith(id: petId);
        _allPets.add(newPet);
        _organizePetsByCategory();
        notifyListeners();

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

        final index = _allPets.indexWhere((p) => p.id == pet.id);
        if (index != -1) {
          _allPets[index] = pet;
          _organizePetsByCategory();
          notifyListeners();
        }

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

        _allPets.removeWhere((pet) => pet.id == petId);
        _organizePetsByCategory();
        notifyListeners();

        return true;
      },
    );
  }

  Future<List<PetEntity>> searchPets({
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
  }) async {
    final result =
        await _searchPetsUseCase(
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
        ).first;

    return result.fold((failure) {
      _setError(_mapFailureToMessage(failure));
      return [];
    }, (pets) => pets);
  }

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

  @override
  void dispose() {
    stopRealtimeUpdates();
    super.dispose();
  }
}
