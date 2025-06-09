import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pet_adoption_app/src/core/network/network_info.dart';
import 'package:pet_adoption_app/src/data/implements/authentication_repository_impl.dart';
import 'package:pet_adoption_app/src/data/implements/pets_repository_impl.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/authentication_service.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/pets_service.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/storage_service.dart';
import 'package:pet_adoption_app/src/domain/repositories/authentication_repository.dart';
import 'package:pet_adoption_app/src/domain/repositories/pets_repository.dart';
import 'package:pet_adoption_app/src/domain/usecases/authentication_usecases.dart';
import 'package:pet_adoption_app/src/domain/usecases/pets_usecases.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /* External */
  // Internet Connection Checker
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());

  // Firebase instances
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  /* Core */
  // Network
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(sl<InternetConnection>()),
  );

  /* Data Sources */
  // Firebase Authentication
  sl.registerLazySingleton<FirebaseAuthenticationService>(
    () => FirebaseAuthenticationService(),
  );

  // Firebase Pets Service
  sl.registerLazySingleton<FirebasePetsService>(
    () => FirebasePetsService(
      firestore: sl<FirebaseFirestore>(),
      storage: sl<FirebaseStorage>(),
    ),
  );

  // Firebase Storage Service
  sl.registerLazySingleton<FirebaseStorageService>(
    () => FirebaseStorageService(storage: sl<FirebaseStorage>()),
  );

  /* Repositories */
  // Authentication Repository
  sl.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(
      firebaseAuthentication: sl<FirebaseAuthenticationService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Pets Repository
  sl.registerLazySingleton<PetsRepository>(
    () => PetsRepositoryImpl(
      firebasePetsService: sl<FirebasePetsService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  /* Use Cases */
  // Authentication Use Cases
  sl.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<SignInWithGoogleUseCase>(
    () => SignInWithGoogleUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<VerifyEmailUseCase>(
    () => VerifyEmailUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<CheckEmailVerificationUseCase>(
    () => CheckEmailVerificationUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(sl<AuthenticationRepository>()),
  );

  // Pets Use Cases
  sl.registerLazySingleton<GetAllPetsUseCase>(
    () => GetAllPetsUseCase(sl<PetsRepository>()),
  );
  sl.registerLazySingleton<GetPetsByCategoryUseCase>(
    () => GetPetsByCategoryUseCase(sl<PetsRepository>()),
  );
  sl.registerLazySingleton<GetPetByIdUseCase>(
    () => GetPetByIdUseCase(sl<PetsRepository>()),
  );
  sl.registerLazySingleton<CreatePetUseCase>(
    () => CreatePetUseCase(sl<PetsRepository>()),
  );
  sl.registerLazySingleton<UpdatePetUseCase>(
    () => UpdatePetUseCase(sl<PetsRepository>()),
  );
  sl.registerLazySingleton<DeletePetUseCase>(
    () => DeletePetUseCase(sl<PetsRepository>()),
  );
  sl.registerLazySingleton<GetPetsByOwnerUseCase>(
    () => GetPetsByOwnerUseCase(sl<PetsRepository>()),
  );
  sl.registerLazySingleton<GetPetsNearLocationUseCase>(
    () => GetPetsNearLocationUseCase(sl<PetsRepository>()),
  );
  sl.registerLazySingleton<SearchPetsUseCase>(
    () => SearchPetsUseCase(sl<PetsRepository>()),
  );
  sl.registerLazySingleton<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(sl<PetsRepository>()),
  );
  sl.registerLazySingleton<GetFavoritePetsUseCase>(
    () => GetFavoritePetsUseCase(sl<PetsRepository>()),
  );
}
