import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/auth/password_reset_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/auth/sign_in_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/auth/sign_up_entity.dart';
import 'package:pet_adoption_app/src/domain/repositories/authentication_repository.dart';

class SignInUseCase {
  final AuthenticationRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, UserCredential>> call(SignInEntity signInData) async {
    return await repository.signInWithEmailAndPassword(signInData);
  }
}

class SignUpUseCase {
  final AuthenticationRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, User>> call(SignUpEntity signUpData) async {
    return await repository.signUpWithEmailAndPassword(signUpData);
  }
}

class SignInWithGoogleUseCase {
  final AuthenticationRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<Either<Failure, UserCredential>> call() async {
    return await repository.signInWithGoogle();
  }
}

class SendEmailVerificationUseCase {
  final AuthenticationRepository repository;

  SendEmailVerificationUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.sendEmailVerification();
  }
}

class CheckEmailVerificationUseCase {
  final AuthenticationRepository repository;

  CheckEmailVerificationUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.checkEmailVerification();
  }
}

class SaveUserDataToFirestoreUseCase {
  final AuthenticationRepository repository;

  SaveUserDataToFirestoreUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.saveUserDataToFirestore();
  }
}

class IsRegistrationCompleteUseCase {
  final AuthenticationRepository repository;

  IsRegistrationCompleteUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.isRegistrationComplete();
  }
}

class ResetPasswordUseCase {
  final AuthenticationRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, Unit>> call(
    PasswordResetEntity passwordResetData,
  ) async {
    return await repository.resetPassword(passwordResetData);
  }
}

class SignOutUseCase {
  final AuthenticationRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.signOut();
  }
}
