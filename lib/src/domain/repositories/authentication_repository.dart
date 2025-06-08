import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/auth/password_reset_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/auth/sign_in_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/auth/sign_up_entity.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, UserCredential>> signInWithEmailAndPassword(
    SignInEntity signInData,
  );
  Future<Either<Failure, UserCredential>> signUpWithEmailAndPassword(
    SignUpEntity signUpData,
  );
  Future<Either<Failure, UserCredential>> signInWithGoogle();
  Future<Either<Failure, Unit>> verifyEmail();
  Future<Either<Failure, Unit>> checkEmailVerification();
  Future<Either<Failure, Unit>> resetPassword(
    PasswordResetEntity passwordResetData,
  );
  Future<Either<Failure, Unit>> signOut();
}
