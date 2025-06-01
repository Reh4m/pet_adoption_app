import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pet_adoption_app/src/core/network/network_info.dart';
import 'package:pet_adoption_app/src/data/implements/authentication_repository_impl.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/authentication.dart';
import 'package:pet_adoption_app/src/domain/repositories/authentication_repository.dart';
import 'package:pet_adoption_app/src/domain/usecases/authentication_usecases.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /* External */
  // Internet Connection Checker
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());

  /* Core */
  // Network
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(sl<InternetConnection>()),
  );

  /* Data Sources */
  // Firebase Authentication
  sl.registerLazySingleton<FirebaseAuthentication>(
    () => FirebaseAuthentication(),
  );

  /* Repositories */
  // Authentication Repository
  sl.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(
      firebaseAuthentication: sl<FirebaseAuthentication>(),
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
}
