import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pet_adoption_app/src/core/errors/exceptions.dart';
import 'package:pet_adoption_app/src/data/models/auth/password_reset_model.dart';
import 'package:pet_adoption_app/src/data/models/auth/sign_in_model.dart';
import 'package:pet_adoption_app/src/data/models/auth/sign_up_model.dart';

class FirebaseAuthenticationService {
  final FirebaseAuth firebaseAuth;

  FirebaseAuthenticationService({required this.firebaseAuth});

  Future<UserCredential> signInWithEmailAndPassword(
    SignInModel signInData,
  ) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
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
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: signUpData.email,
        password: signUpData.password,
      );

      return result;
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

  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw UserNotFoundException();
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw ExistingEmailException();
      } else if (e.code == 'invalid-credential') {
        throw ServerException();
      } else if (e.code == 'operation-not-allowed') {
        throw ServerException();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  Future<Unit> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw UserNotFoundException();
      }

      await user.reload();
      await user.sendEmailVerification();

      return unit;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        throw TooManyRequestsException();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  Future<bool> isEmailVerified() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw UserNotFoundException();
      }

      await user.reload();

      return user.emailVerified;
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Future<bool> isRegistrationComplete() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw UserNotFoundException();
      }

      final hasName = user.displayName != null && user.displayName!.isNotEmpty;
      final hasEmail = user.email != null && user.email!.isNotEmpty;

      return hasName && hasEmail;
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Future<Unit> resetPassword(PasswordResetModel passwordResetData) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: passwordResetData.email);
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
