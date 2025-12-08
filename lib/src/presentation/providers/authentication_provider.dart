import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_adoption_app/src/core/constants/error_messages.dart';
import 'package:pet_adoption_app/src/core/di/index.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/auth/sign_in_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/auth/sign_up_entity.dart';
import 'package:pet_adoption_app/src/domain/usecases/authentication_usecases.dart';

enum AuthState { initial, loading, checking, verified, success, error }

class AuthenticationProvider extends ChangeNotifier {
  final SignInUseCase _signInUseCase = sl<SignInUseCase>();
  final SignUpUseCase _signUpUseCase = sl<SignUpUseCase>();
  final SignInWithGoogleUseCase _signInWithGoogleUseCase =
      sl<SignInWithGoogleUseCase>();
  final SendEmailVerificationUseCase _sendEmailVerificationUseCase =
      sl<SendEmailVerificationUseCase>();
  final CheckEmailVerificationUseCase _checkEmailVerificationUseCase =
      sl<CheckEmailVerificationUseCase>();
  final SaveUserDataToFirestoreUseCase _saveUserDataToFirestoreUseCase =
      sl<SaveUserDataToFirestoreUseCase>();

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  User? _currentUser;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  Future<void> signIn(String email, String password) async {
    _setState(AuthState.loading);

    final result = await _signInUseCase(
      SignInEntity(email: email, password: password),
    );

    await result.fold(
      (failure) async => _setError(_mapFailureToMessage(failure)),
      (userCredential) async {
        _currentUser = userCredential.user;

        _setState(AuthState.success);
      },
    );
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

    await result.fold(
      (failure) async => _setError(_mapFailureToMessage(failure)),
      (newUser) async {
        _currentUser = newUser;

        _setState(AuthState.success);
      },
    );
  }

  Future<void> signInWithGoogle() async {
    _setState(AuthState.loading);

    final result = await _signInWithGoogleUseCase();

    await result.fold(
      (failure) async => _setError(_mapFailureToMessage(failure)),
      (userCredential) async {
        _currentUser = userCredential.user;

        final result = await saveUserDataToFirestore();

        if (!result) {
          _setState(AuthState.error);
        } else {
          _setState(AuthState.success);
        }
      },
    );
  }

  Future<void> sendEmailVerification() async {
    _setState(AuthState.loading);

    final result = await _sendEmailVerificationUseCase();

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (_) => _setState(AuthState.initial),
    );
  }

  Future<bool> checkEmailVerification() async {
    _setState(AuthState.checking);

    final result = await _checkEmailVerificationUseCase();

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (isVerified) {
        if (isVerified) {
          _setState(AuthState.verified);
        } else {
          _setState(AuthState.initial);
        }
        return isVerified;
      },
    );
  }

  Future<bool> saveUserDataToFirestore() async {
    _setState(AuthState.loading);

    final result = await _saveUserDataToFirestoreUseCase();

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setState(AuthState.verified);
        return true;
      },
    );
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
      case const (NetworkFailure):
        return ErrorMessages.networkError;
      case const (UserNotFoundFailure):
        return ErrorMessages.userNotFound;
      case const (WrongPasswordFailure):
        return ErrorMessages.wrongPassword;
      case const (WeakPasswordFailure):
        return ErrorMessages.weakPassword;
      case const (ExistingEmailFailure):
        return ErrorMessages.emailInUse;
      case const (TooManyRequestsFailure):
        return ErrorMessages.tooManyRequests;
      case const (PasswordMismatchFailure):
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
