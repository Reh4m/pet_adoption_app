import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_adoption_app/src/core/errors/exceptions.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/core/network/network_info.dart';
import 'package:pet_adoption_app/src/data/models/auth/password_reset_model.dart';
import 'package:pet_adoption_app/src/data/models/auth/sign_in_model.dart';
import 'package:pet_adoption_app/src/data/models/auth/sign_up_model.dart';
import 'package:pet_adoption_app/src/data/models/user_model.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/authentication_service.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/user_service.dart';
import 'package:pet_adoption_app/src/domain/entities/auth/password_reset_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/auth/sign_in_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/auth/sign_up_entity.dart';
import 'package:pet_adoption_app/src/domain/repositories/authentication_repository.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseAuthenticationService firebaseAuthentication;
  final FirebaseUserService firebaseUserService;
  final NetworkInfo networkInfo;

  AuthenticationRepositoryImpl({
    required this.firebaseAuth,
    required this.firebaseAuthentication,
    required this.firebaseUserService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserCredential>> signInWithEmailAndPassword(
    SignInEntity signInData,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final signInModel = SignInModel(
        email: signInData.email,
        password: signInData.password,
      );
      final userCredential = await firebaseAuthentication
          .signInWithEmailAndPassword(signInModel);

      return Right(userCredential);
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on WrongPasswordException {
      return Left(WrongPasswordFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword(
    SignUpEntity signUpData,
  ) async {
    if (!await networkInfo.isConnected) {
      return Future.value(Left(NetworkFailure()));
    }

    if (signUpData.password != signUpData.confirmPassword) {
      return Future.value(Left(PasswordMismatchFailure()));
    }

    try {
      final signUpModel = SignUpModel(
        name: signUpData.name,
        email: signUpData.email,
        password: signUpData.password,
        confirmPassword: signUpData.confirmPassword,
      );

      // 1. Crear el usuario en Firebase Authentication
      await firebaseAuthentication.signUpWithEmailAndPassword(signUpModel);

      // 2. Actualizar el perfil del usuario con el nombre proporcionado
      final updatedUser = await firebaseUserService.updateFirebaseAuthUser(
        displayName: signUpData.name,
      );

      // 3. Enviar correo de verificación
      await firebaseAuthentication.sendEmailVerification();

      return Right(updatedUser);
    } on WeakPasswordException {
      return Left(WeakPasswordFailure());
    } on ExistingEmailException {
      return Left(ExistingEmailFailure());
    } on TooManyRequestsException {
      return Left(TooManyRequestsFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserCredential>> signInWithGoogle() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final userCredential = await firebaseAuthentication.signInWithGoogle();

      return Right(userCredential);
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on ExistingEmailException {
      return Left(ExistingEmailFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendEmailVerification() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseAuthentication.sendEmailVerification();

      return const Right(unit);
    } on TooManyRequestsException {
      return Left(TooManyRequestsFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailVerification() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        return Left(UserNotFoundFailure());
      }

      await user.reload();

      final updatedUser = firebaseAuth.currentUser;

      return Right(updatedUser?.emailVerified ?? false);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> saveUserDataToFirestore() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        return Left(UserNotFoundFailure());
      }

      // Verificar que el email esté realmente verificado
      await currentUser.reload();

      if (!currentUser.emailVerified) {
        return Left(EmailVerificationFailure());
      }

      // Verificar si el usuario ya existe en Firestore
      final userExists = await firebaseUserService.checkUserExists(
        currentUser.uid,
      );

      if (userExists) {
        // Si ya existe, actualizar sus datos y marcar como verificado
        final existingUser = await firebaseUserService.getUserById(
          currentUser.uid,
        );

        final updatedUser = existingUser.copyWith(
          name: currentUser.displayName ?? existingUser.name,
          email: currentUser.email ?? existingUser.email,
          phoneNumber: currentUser.phoneNumber,
          photoUrl: currentUser.photoURL,
          isVerified: true,
          updatedAt: DateTime.now(),
        );

        await firebaseUserService.updateFirestoreUser(updatedUser);
        await firebaseUserService.updateFirebaseAuthUser(
          displayName: updatedUser.name,
          photoUrl: updatedUser.photoUrl,
        );
      } else {
        // Si no existe, crear nuevo usuario en Firestore
        await firebaseUserService.createUser(
          UserModel(
            id: currentUser.uid,
            name: currentUser.displayName ?? '',
            email: currentUser.email ?? '',
            phoneNumber: currentUser.phoneNumber,
            photoUrl: currentUser.photoURL,
            isVerified: true,
            authProvider: firebaseUserService.getCurrentUserAuthProvider(),
            createdAt: DateTime.now(),
          ),
        );
      }

      return const Right(unit);
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on InvalidUserDataException {
      return Left(InvalidUserDataFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(
    PasswordResetEntity passwordResetData,
  ) async {
    if (!await networkInfo.isConnected) {
      return Future.value(Left(NetworkFailure()));
    }

    try {
      final passwordResetModel = PasswordResetModel(
        email: passwordResetData.email,
      );
      await firebaseAuthentication.resetPassword(passwordResetModel);
      return Future.value(const Right(unit));
    } on UserNotFoundException {
      return Future.value(Left(UserNotFoundFailure()));
    } on TooManyRequestsException {
      return Future.value(Left(TooManyRequestsFailure()));
    } on ServerException {
      return Future.value(Left(ServerFailure()));
    } catch (e) {
      return Future.value(Left(ServerFailure()));
    }
  }

  @override
  Future<Either<Failure, bool>> isRegistrationComplete() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        return const Right(false);
      }

      await currentUser.reload();

      final isEmailVerified = currentUser.emailVerified;

      final hasName =
          currentUser.displayName != null &&
          currentUser.displayName!.isNotEmpty;
      final hasEmail =
          currentUser.email != null && currentUser.email!.isNotEmpty;

      // Si no tiene todos los datos necesarios en Auth, no está completo
      if (!isEmailVerified || !hasName || !hasEmail) {
        return const Right(false);
      }

      final userExists = await firebaseUserService.checkUserExists(
        currentUser.uid,
      );

      if (!userExists) {
        return const Right(false);
      }

      // Verificar que los datos en Firestore estén completos
      final user = await firebaseUserService.getUserById(currentUser.uid);

      final hasCompleteData =
          user.name.isNotEmpty && user.email.isNotEmpty && user.isVerified;

      return Right(hasCompleteData);
    } on UserNotFoundException {
      return const Right(false);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await FirebaseAuth.instance.signOut();

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
