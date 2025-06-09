import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_adoption_app/src/core/di/index.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_location_entity.dart';
import 'package:pet_adoption_app/src/domain/usecases/pets_usecases.dart';

class PetRegistrationProvider extends ChangeNotifier {
  final CreatePetUseCase _createPetUseCase = sl<CreatePetUseCase>();

  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0;
  bool _isCompleted = false;

  final Map<String, dynamic> _formData = {};
  final List<File> _selectedImages = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentStep => _currentStep;
  bool get isCompleted => _isCompleted;
  Map<String, dynamic> get formData => Map.from(_formData);
  List<File> get selectedImages => List.from(_selectedImages);

  static const int totalSteps = 6;
  bool get isFirstStep => _currentStep == 0;
  bool get isLastStep => _currentStep == totalSteps - 1;

  // Información básica (Paso 1)
  String? get petName => _formData['name'];
  String? get petCategory => _formData['category'];
  String? get petBreed => _formData['breed'];
  int? get petAgeInMonths => _formData['ageInMonths'];

  // Características físicas (Paso 2)
  PetSize? get petSize => _formData['size'];
  double? get petWeight => _formData['weight'];
  String? get petColor => _formData['color'];
  PetGender? get petGender => _formData['gender'];

  // Información médica y comportamiento (Paso 3)
  bool get isVaccinated => _formData['vaccinated'] ?? false;
  bool get isSterilized => _formData['sterilized'] ?? false;
  List<String> get medicalConditions =>
      List<String>.from(_formData['medicalConditions'] ?? []);
  bool get goodWithKids => _formData['goodWithKids'] ?? false;
  bool get goodWithPets => _formData['goodWithPets'] ?? false;
  bool get goodWithStrangers => _formData['goodWithStrangers'] ?? false;

  // Ubicación y descripción (Paso 5)
  PetLocationEntity? get petLocation => _formData['location'];
  String? get petDescription => _formData['description'];

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void updateFormData(String key, dynamic value) {
    _formData[key] = value;
    notifyListeners();
  }

  void updateBasicInfo({
    required String name,
    required String category,
    required String breed,
    required int ageInMonths,
  }) {
    _formData.addAll({
      'name': name,
      'category': category,
      'breed': breed,
      'ageInMonths': ageInMonths,
    });
    notifyListeners();
  }

  void updatePhysicalInfo({
    required PetSize size,
    required double weight,
    required String color,
    required PetGender gender,
  }) {
    _formData.addAll({
      'size': size,
      'weight': weight,
      'color': color,
      'gender': gender,
    });
    notifyListeners();
  }

  void updateMedicalInfo({
    required bool vaccinated,
    required bool sterilized,
    required List<String> medicalConditions,
    required bool goodWithKids,
    required bool goodWithPets,
    required bool goodWithStrangers,
  }) {
    _formData.addAll({
      'vaccinated': vaccinated,
      'sterilized': sterilized,
      'medicalConditions': medicalConditions,
      'goodWithKids': goodWithKids,
      'goodWithPets': goodWithPets,
      'goodWithStrangers': goodWithStrangers,
    });
    notifyListeners();
  }

  void updateLocationInfo({
    required PetLocationEntity location,
    required String description,
  }) {
    _formData.addAll({'location': location, 'description': description});
    notifyListeners();
  }

  void addImage(File image) {
    if (_selectedImages.length < 5) {
      _selectedImages.add(image);
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  void clearImages() {
    _selectedImages.clear();
    notifyListeners();
  }

  bool validateStep(int step) {
    switch (step) {
      case 0: // Información básica
        return petName != null &&
            petName!.isNotEmpty &&
            petCategory != null &&
            petCategory!.isNotEmpty &&
            petBreed != null &&
            petBreed!.isNotEmpty &&
            petAgeInMonths != null &&
            petAgeInMonths! > 0;

      case 1: // Características físicas
        return petSize != null &&
            petWeight != null &&
            petWeight! > 0 &&
            petColor != null &&
            petColor!.isNotEmpty &&
            petGender != null;

      case 2: // Información médica (siempre válida, son opcionales)
        return true;

      case 3: // Imágenes
        return _selectedImages.isNotEmpty;

      case 4: // Ubicación y descripción
        return petLocation != null &&
            petDescription != null &&
            petDescription!.isNotEmpty;

      case 5: // Preview (siempre válida si llegamos aquí)
        return true;

      default:
        return false;
    }
  }

  bool get canProceedToNext => validateStep(_currentStep);

  Future<bool> createPet() async {
    if (!_validateAllSteps()) {
      _setError('Faltan datos obligatorios');
      return false;
    }

    _setLoading(true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _setError('No hay usuario autenticado');
        return false;
      }

      final pet = PetEntity(
        id: '', // Se generará en Firestore
        name: petName!,
        ageInMonths: petAgeInMonths!,
        weight: petWeight!,
        size: petSize!,
        breed: petBreed!,
        color: petColor!,
        gender: petGender!,
        category: petCategory!,
        vaccinated: isVaccinated,
        sterilized: isSterilized,
        medicalConditions: medicalConditions,
        goodWithKids: goodWithKids,
        goodWithPets: goodWithPets,
        goodWithStrangers: goodWithStrangers,
        description: petDescription!,
        imageUrls: [], // Se llenarán en el servicio
        location: petLocation!,
        ownerId: currentUser.uid,
        status: PetStatus.available,
        createdAt: DateTime.now(),
      );

      final result = await _createPetUseCase(pet, _selectedImages);

      return result.fold(
        (failure) {
          _setError('Error al registrar mascota: ${failure.toString()}');
          return false;
        },
        (petId) {
          _isCompleted = true;
          _setLoading(false);
          return true;
        },
      );
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    }
  }

  bool _validateAllSteps() {
    for (int i = 0; i < totalSteps - 1; i++) {
      if (!validateStep(i)) return false;
    }
    return true;
  }

  // Utils
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (!loading) _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetForm() {
    _formData.clear();
    _selectedImages.clear();
    _currentStep = 0;
    _isCompleted = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  double get progress => (_currentStep + 1) / totalSteps;

  String get currentStepTitle {
    switch (_currentStep) {
      case 0:
        return 'Información Básica';
      case 1:
        return 'Características Físicas';
      case 2:
        return 'Salud y Comportamiento';
      case 3:
        return 'Fotos';
      case 4:
        return 'Ubicación y Descripción';
      case 5:
        return 'Vista Previa';
      default:
        return 'Paso ${_currentStep + 1}';
    }
  }
}
