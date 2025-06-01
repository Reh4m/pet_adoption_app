import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_adoption_app/src/core/errors/exceptions.dart';
import 'package:pet_adoption_app/src/data/models/auth/password_reset_model.dart';
import 'package:pet_adoption_app/src/data/models/auth/sign_in_model.dart';
import 'package:pet_adoption_app/src/data/models/auth/sign_up_model.dart';

class FirebaseAuthentication {
  Future<UserCredential> signInWithEmailAndPassword(
    SignInModel signInData,
  ) async {
    try {
      final firebaseInstance = FirebaseAuth.instance;

      await firebaseInstance.currentUser?.reload();

      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: signInData.email,
        password: signInData.password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordException();
      } else if (e.code == 'invalid-credential') {
        throw WrongPasswordException();
      } else {
        throw ServerException();
      }
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(
    SignUpModel signUpData,
  ) async {
    try {
      final firebaseInstance = FirebaseAuth.instance;

      await firebaseInstance.currentUser?.reload();

      return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: signUpData.email,
        password: signUpData.password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw ExistingEmailException();
      } else if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else {
        throw ServerException();
      }
    }
  }

  Future<Unit> verifyEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      try {
        await user.reload();
        await user.sendEmailVerification();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'too-many-requests') {
          throw TooManyRequestsException();
        } else {
          throw ServerException();
        }
      } catch (e) {
        throw ServerException();
      }
    } else {
      throw UserNotFoundException();
    }

    return Future.value(unit);
  }

  Future<Unit> resetPassword(PasswordResetModel passwordResetData) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: passwordResetData.email,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (e.code == 'too-many-requests') {
        throw TooManyRequestsException();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }

    return Future.value(unit);
  }
}
