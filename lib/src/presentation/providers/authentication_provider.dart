import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_adoption_app/src/core/constants/error_messages.dart';
import 'package:pet_adoption_app/src/core/di/index.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/auth/sign_in_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/auth/sign_up_entity.dart';
import 'package:pet_adoption_app/src/domain/usecases/authentication_usecases.dart';

enum AuthState { initial, loading, success, error }

class AuthenticationProvider extends ChangeNotifier {
  final SignInUseCase _signInUseCase = sl<SignInUseCase>();
  final SignUpUseCase _signUpUseCase = sl<SignUpUseCase>();
  final SignOutUseCase _signOutUseCase = sl<SignOutUseCase>();

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  User? _currentUser;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> signIn(String email, String password) async {
    _setState(AuthState.loading);

    final result = await _signInUseCase(
      SignInEntity(email: email, password: password),
    );

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      userCredential,
    ) {
      _currentUser = userCredential.user;
      _setState(AuthState.success);
    });
  }

  Future<void> signUp(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    _setState(AuthState.loading);

    final result = await _signUpUseCase(
      SignUpEntity(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      ),
    );

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      userCredential,
    ) {
      _currentUser = userCredential.user;
      _setState(AuthState.success);
    });
  }

  Future<void> signOut() async {
    _setState(AuthState.loading);

    final result = await _signOutUseCase();

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (_) {
      _currentUser = null;
      _setState(AuthState.initial);
    });
  }

  void _setState(AuthState newState) {
    _state = newState;
    if (newState != AuthState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(AuthState.error);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure _:
        return ErrorMessages.networkError;
      case UserNotFoundFailure _:
        return ErrorMessages.userNotFound;
      case WrongPasswordFailure _:
        return ErrorMessages.wrongPassword;
      case WeakPasswordFailure _:
        return ErrorMessages.weakPassword;
      case ExistingEmailFailure _:
        return ErrorMessages.emailInUse;
      case TooManyRequestsFailure _:
        return ErrorMessages.tooManyRequests;
      case PasswordMismatchFailure _:
        return ErrorMessages.passwordMismatch;
      default:
        return ErrorMessages.serverError;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
