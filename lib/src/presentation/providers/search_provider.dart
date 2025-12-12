import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pet_adoption_app/src/core/di/index.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_location_entity.dart';
import 'package:pet_adoption_app/src/domain/usecases/pets_usecases.dart';

enum SearchState { initial, loading, success, error, locationDenied }

class SearchFilters {
  final String? query;
  final List<String>? categories;
  final List<String>? sizes;
  final List<String>? genders;
  final bool? vaccinated;
  final bool? sterilized;
  final bool? goodWithKids;
  final bool? goodWithPets;
  final int? maxAge;
  final int? minAge;
  final PetLocationEntity? location;
  final double? radiusInKm;

  const SearchFilters({
    this.query,
    this.categories,
    this.sizes,
    this.genders,
    this.vaccinated,
    this.sterilized,
    this.goodWithKids,
    this.goodWithPets,
    this.maxAge,
    this.minAge,
    this.location,
    this.radiusInKm,
  });

  SearchFilters copyWith({
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
    return SearchFilters(
      query: query ?? this.query,
      categories: categories ?? this.categories,
      sizes: sizes ?? this.sizes,
      genders: genders ?? this.genders,
      vaccinated: vaccinated ?? this.vaccinated,
      sterilized: sterilized ?? this.sterilized,
      goodWithKids: goodWithKids ?? this.goodWithKids,
      goodWithPets: goodWithPets ?? this.goodWithPets,
      maxAge: maxAge ?? this.maxAge,
      minAge: minAge ?? this.minAge,
      location: location ?? this.location,
      radiusInKm: radiusInKm ?? this.radiusInKm,
    );
  }

  bool get hasActiveFilters =>
      query != null ||
      (categories != null && categories!.isNotEmpty) ||
      (sizes != null && sizes!.isNotEmpty) ||
      (genders != null && genders!.isNotEmpty) ||
      vaccinated != null ||
      sterilized != null ||
      goodWithKids != null ||
      goodWithPets != null ||
      maxAge != null ||
      minAge != null ||
      location != null ||
      radiusInKm != null;

  int get activeFiltersCount {
    int count = 0;
    if (query != null && query!.isNotEmpty) count++;
    if (categories != null && categories!.isNotEmpty) count++;
    if (sizes != null && sizes!.isNotEmpty) count++;
    if (genders != null && genders!.isNotEmpty) count++;
    if (vaccinated != null) count++;
    if (sterilized != null) count++;
    if (goodWithKids != null) count++;
    if (goodWithPets != null) count++;
    if (maxAge != null || minAge != null) count++;
    if (location != null) count++;
    return count;
  }
}

class SearchProvider extends ChangeNotifier {
  final SearchPetsUseCase _searchPetsUseCase = sl<SearchPetsUseCase>();
  final GetPetsNearLocationUseCase _getPetsNearLocationUseCase =
      sl<GetPetsNearLocationUseCase>();

  SearchState _state = SearchState.initial;
  String? _errorMessage;
  List<PetEntity> _searchResults = [];
  SearchFilters _filters = const SearchFilters();

  // Location
  PetLocationEntity? _currentLocation;
  double _searchRadius = 50.0; // km por defecto

  SearchState get state => _state;
  String? get errorMessage => _errorMessage;
  List<PetEntity> get searchResults => List.from(_searchResults);
  SearchFilters get filters => _filters;
  PetLocationEntity? get currentLocation => _currentLocation;
  double get searchRadius => _searchRadius;

  bool get hasResults => _searchResults.isNotEmpty;
  int get resultsCount => _searchResults.length;

  // Actualizar filtros
  void updateFilters(SearchFilters newFilters) {
    _filters = newFilters;
    notifyListeners();
  }

  void clearFilters() {
    _filters = const SearchFilters();
    _searchResults = [];
    _setState(SearchState.initial);
  }

  void updateSearchRadius(double radius) {
    _searchRadius = radius;
    notifyListeners();
  }

  void setSearchLocation(PetLocationEntity location) {
    _currentLocation = location;
    _filters = _filters.copyWith(location: location, radiusInKm: _searchRadius);
    notifyListeners();
  }

  // Obtener ubicación actual del dispositivo
  Future<bool> getCurrentDeviceLocation() async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setState(SearchState.locationDenied);
          _errorMessage = 'Permisos de ubicación denegados';
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setState(SearchState.locationDenied);
        _errorMessage = 'Permisos de ubicación denegados permanentemente';
        return false;
      }

      // Obtener posición
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentLocation = PetLocationEntity(
        latitude: position.latitude,
        longitude: position.longitude,
        address: 'Mi ubicación',
        city: 'Ubicación actual',
        state: '',
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al obtener ubicación: $e';
      _setState(SearchState.error);
      return false;
    }
  }

  Future<void> searchWithFilters() async {
    _setState(SearchState.loading);

    try {
      StreamSubscription? subscription;

      if (_filters.location != null) {
        // Búsqueda por ubicación
        subscription = _getPetsNearLocationUseCase(
          _filters.location!,
          _filters.radiusInKm ?? _searchRadius,
        ).listen((either) {
          either.fold((failure) => _setError('Error en la búsqueda'), (pets) {
            _searchResults = _applyAdditionalFilters(pets);
            _setState(SearchState.success);
          });
        });
      } else {
        // Búsqueda con otros filtros
        subscription = _searchPetsUseCase(
          query: _filters.query,
          categories: _filters.categories,
          sizes: _filters.sizes,
          genders: _filters.genders,
          vaccinated: _filters.vaccinated,
          sterilized: _filters.sterilized,
          goodWithKids: _filters.goodWithKids,
          goodWithPets: _filters.goodWithPets,
          maxAge: _filters.maxAge,
          minAge: _filters.minAge,
        ).listen((either) {
          either.fold((failure) => _setError('Error en la búsqueda'), (pets) {
            _searchResults = pets;
            _setState(SearchState.success);
          });
        });
      }

      await Future.delayed(const Duration(milliseconds: 500));
      await subscription.cancel();
    } catch (e) {
      _setError('Error inesperado: $e');
    }
  }

  // Aplicar filtros adicionales localmente
  List<PetEntity> _applyAdditionalFilters(List<PetEntity> pets) {
    var filteredPets = pets;

    // Filtro de texto
    if (_filters.query != null && _filters.query!.isNotEmpty) {
      final query = _filters.query!.toLowerCase();
      filteredPets =
          filteredPets.where((pet) {
            return pet.name.toLowerCase().contains(query) ||
                pet.breed.toLowerCase().contains(query) ||
                pet.description.toLowerCase().contains(query);
          }).toList();
    }

    // Filtro de categorías
    if (_filters.categories != null && _filters.categories!.isNotEmpty) {
      filteredPets =
          filteredPets.where((pet) {
            return _filters.categories!.contains(pet.category.toLowerCase());
          }).toList();
    }

    // Filtro de tamaños
    if (_filters.sizes != null && _filters.sizes!.isNotEmpty) {
      filteredPets =
          filteredPets.where((pet) {
            return _filters.sizes!.contains(pet.size.name);
          }).toList();
    }

    // Filtro de géneros
    if (_filters.genders != null && _filters.genders!.isNotEmpty) {
      filteredPets =
          filteredPets.where((pet) {
            return _filters.genders!.contains(pet.gender.name);
          }).toList();
    }

    // Filtros médicos
    if (_filters.vaccinated != null) {
      filteredPets =
          filteredPets
              .where((pet) => pet.vaccinated == _filters.vaccinated)
              .toList();
    }

    if (_filters.sterilized != null) {
      filteredPets =
          filteredPets
              .where((pet) => pet.sterilized == _filters.sterilized)
              .toList();
    }

    // Filtros de comportamiento
    if (_filters.goodWithKids != null) {
      filteredPets =
          filteredPets
              .where((pet) => pet.goodWithKids == _filters.goodWithKids)
              .toList();
    }

    if (_filters.goodWithPets != null) {
      filteredPets =
          filteredPets
              .where((pet) => pet.goodWithPets == _filters.goodWithPets)
              .toList();
    }

    // Filtro de edad
    if (_filters.minAge != null) {
      filteredPets =
          filteredPets
              .where((pet) => pet.ageInMonths >= _filters.minAge!)
              .toList();
    }

    if (_filters.maxAge != null) {
      filteredPets =
          filteredPets
              .where((pet) => pet.ageInMonths <= _filters.maxAge!)
              .toList();
    }

    return filteredPets;
  }

  void _setState(SearchState newState) {
    _state = newState;
    if (newState != SearchState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(SearchState.error);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
