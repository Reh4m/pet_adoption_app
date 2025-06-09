import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_adoption_app/src/core/constants/error_messages.dart';
import 'package:pet_adoption_app/src/core/di/index.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/user_entity.dart';
import 'package:pet_adoption_app/src/domain/usecases/auth_user_usecases.dart';
import 'package:pet_adoption_app/src/domain/usecases/user_usecases.dart';

enum UserState { initial, loading, success, error }

class UserProvider extends ChangeNotifier {
  // Use Cases
  final GetCurrentUserUseCase _getCurrentUserUseCase =
      sl<GetCurrentUserUseCase>();
  final GetCurrentUserStreamUseCase _getCurrentUserStreamUseCase =
      sl<GetCurrentUserStreamUseCase>();
  final GetUserByIdUseCase _getUserByIdUseCase = sl<GetUserByIdUseCase>();
  final UpdateUserUseCase _updateUserUseCase = sl<UpdateUserUseCase>();
  final ChangeProfilePhotoUseCase _changeProfilePhotoUseCase =
      sl<ChangeProfilePhotoUseCase>();
  final UpdateNotificationSettingsUseCase _updateNotificationSettingsUseCase =
      sl<UpdateNotificationSettingsUseCase>();
  final UpdateSearchRadiusUseCase _updateSearchRadiusUseCase =
      sl<UpdateSearchRadiusUseCase>();
  final CreateOrUpdateUserFromAuthUseCase _createOrUpdateUserFromAuthUseCase =
      sl<CreateOrUpdateUserFromAuthUseCase>();
  final SyncUserWithAuthUseCase _syncUserWithAuthUseCase =
      sl<SyncUserWithAuthUseCase>();

  UserState _currentUserState = UserState.initial;
  UserEntity? _currentUser;
  String? _currentUserError;
  StreamSubscription? _currentUserSubscription;

  UserState _operationState = UserState.initial;
  String? _operationError;

  UserState _userProfileState = UserState.initial;
  UserEntity? _userProfile;
  String? _userProfileError;

  UserState get currentUserState => _currentUserState;
  UserEntity? get currentUser => _currentUser;
  String? get currentUserError => _currentUserError;
  bool get isLoggedIn => _currentUser != null;

  UserState get operationState => _operationState;
  String? get operationError => _operationError;

  UserState get userProfileState => _userProfileState;
  UserEntity? get userProfile => _userProfile;
  String? get userProfileError => _userProfileError;

  void startCurrentUserListener() {
    _setCurrentUserState(UserState.loading);

    _currentUserSubscription = _getCurrentUserStreamUseCase().listen(
      (either) {
        either.fold(
          (failure) => _setCurrentUserError(_mapFailureToMessage(failure)),
          (user) {
            _currentUser = user;
            _setCurrentUserState(UserState.success);
          },
        );
      },
      onError: (error) {
        _setCurrentUserError('Error de conexión: $error');
      },
    );
  }

  void stopCurrentUserListener() {
    _currentUserSubscription?.cancel();
    _currentUserSubscription = null;
  }

  Future<void> syncWithAuth() async {
    _setCurrentUserState(UserState.loading);

    final result = await _syncUserWithAuthUseCase();

    result.fold(
      (failure) => _setCurrentUserError(_mapFailureToMessage(failure)),
      (user) {
        _currentUser = user;
        _setCurrentUserState(UserState.success);
      },
    );
  }

  Future<bool> createOrUpdateFromAuth(User firebaseUser) async {
    _setCurrentUserState(UserState.loading);

    final result = await _createOrUpdateUserFromAuthUseCase(firebaseUser);

    return result.fold(
      (failure) {
        _setCurrentUserError(_mapFailureToMessage(failure));
        return false;
      },
      (user) {
        _currentUser = user;
        _setCurrentUserState(UserState.success);
        return true;
      },
    );
  }

  Future<void> loadCurrentUser() async {
    _setCurrentUserState(UserState.loading);

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) => _setCurrentUserError(_mapFailureToMessage(failure)),
      (user) {
        _currentUser = user;
        _setCurrentUserState(UserState.success);
      },
    );
  }

  Future<void> loadUserProfile(String userId) async {
    _setUserProfileState(UserState.loading);

    final result = await _getUserByIdUseCase(userId);

    result.fold(
      (failure) => _setUserProfileError(_mapFailureToMessage(failure)),
      (user) {
        _userProfile = user;
        _setUserProfileState(UserState.success);
      },
    );
  }

  Future<bool> updateCurrentUserProfile(UserEntity updatedUser) async {
    if (_currentUser == null) return false;

    _setOperationState(UserState.loading);

    final result = await _updateUserUseCase(updatedUser);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (user) {
        _currentUser = user;
        _setOperationState(UserState.success);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> changeProfilePhoto(File image) async {
    if (_currentUser == null) return false;

    _setOperationState(UserState.loading);

    final result = await _changeProfilePhotoUseCase(image, _currentUser!.id);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (user) {
        _currentUser = user;
        _setOperationState(UserState.success);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updateNotificationSettings({
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
  }) async {
    if (_currentUser == null) return false;

    _setOperationState(UserState.loading);

    final result = await _updateNotificationSettingsUseCase(
      _currentUser!.id,
      notificationsEnabled: notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
    );

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (user) {
        _currentUser = user;
        _setOperationState(UserState.success);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updateSearchRadius(double radius) async {
    if (_currentUser == null) return false;

    _setOperationState(UserState.loading);

    final result = await _updateSearchRadiusUseCase(_currentUser!.id, radius);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (user) {
        _currentUser = user;
        _setOperationState(UserState.success);
        notifyListeners();
        return true;
      },
    );
  }

  void clearUserProfile() {
    _userProfile = null;
    _setUserProfileState(UserState.initial);
  }

  void clearCurrentUser() {
    stopCurrentUserListener();
    _currentUser = null;
    _setCurrentUserState(UserState.initial);
    clearUserProfile();
  }

  bool get canEditProfilePhoto {
    return _currentUser?.canEditPhoto ?? false;
  }

  bool get isProfileComplete {
    if (_currentUser == null) return false;
    return _currentUser!.hasPhoto && _currentUser!.hasBio;
  }

  Map<String, int> get userStats {
    if (_currentUser == null) return {'petsPosted': 0, 'petsAdopted': 0};
    return {
      'petsPosted': _currentUser!.petsPosted,
      'petsAdopted': _currentUser!.petsAdopted,
    };
  }

  void _setCurrentUserState(UserState newState) {
    _currentUserState = newState;
    if (newState != UserState.error) {
      _currentUserError = null;
    }
    notifyListeners();
  }

  void _setCurrentUserError(String message) {
    _currentUserError = message;
    _setCurrentUserState(UserState.error);
  }

  void _setOperationState(UserState newState) {
    _operationState = newState;
    if (newState != UserState.error) {
      _operationError = null;
    }
    notifyListeners();
  }

  void _setOperationError(String message) {
    _operationError = message;
    _setOperationState(UserState.error);
  }

  void _setUserProfileState(UserState newState) {
    _userProfileState = newState;
    if (newState != UserState.error) {
      _userProfileError = null;
    }
    notifyListeners();
  }

  void _setUserProfileError(String message) {
    _userProfileError = message;
    _setUserProfileState(UserState.error);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return ErrorMessages.networkError;
      case const (UserNotFoundFailure):
        return 'Usuario no encontrado';
      case const (UserUpdateFailedFailure):
        return 'Error al actualizar perfil';
      case const (ProfileImageUploadFailure):
        return 'Error al subir imagen';
      case const (ServerFailure):
        return ErrorMessages.serverError;
      default:
        return 'Error inesperado';
    }
  }

  void clearCurrentUserError() {
    _currentUserError = null;
    notifyListeners();
  }

  void clearOperationError() {
    _operationError = null;
    notifyListeners();
  }

  void clearUserProfileError() {
    _userProfileError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopCurrentUserListener();
    super.dispose();
  }
}
