import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pet_adoption_app/src/core/network/network_info.dart';
import 'package:pet_adoption_app/src/data/implements/adoption_request_respository_impl.dart';
import 'package:pet_adoption_app/src/data/implements/authentication_repository_impl.dart';
import 'package:pet_adoption_app/src/data/implements/chat_repository_impl.dart';
import 'package:pet_adoption_app/src/data/implements/pet_repository_impl.dart';
import 'package:pet_adoption_app/src/data/implements/user_repository_impl.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/adoption_requests_service.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/authentication_service.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/chat_service.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/pet_service.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/storage_service.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/user_service.dart';
import 'package:pet_adoption_app/src/domain/repositories/adoption_requests_repository.dart';
import 'package:pet_adoption_app/src/domain/repositories/authentication_repository.dart';
import 'package:pet_adoption_app/src/domain/repositories/chat_repository.dart';
import 'package:pet_adoption_app/src/domain/repositories/pet_repository.dart';
import 'package:pet_adoption_app/src/domain/repositories/user_repository.dart';
import 'package:pet_adoption_app/src/domain/usecases/adoption_integration_usecases.dart';
import 'package:pet_adoption_app/src/domain/usecases/adoption_requests_usecases.dart';
import 'package:pet_adoption_app/src/domain/usecases/authentication_usecases.dart';
import 'package:pet_adoption_app/src/domain/usecases/chat_usecases.dart';
import 'package:pet_adoption_app/src/domain/usecases/pets_usecases.dart';
import 'package:pet_adoption_app/src/domain/usecases/user_usecases.dart';
import 'package:pet_adoption_app/src/presentation/providers/adoption_request_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/chat_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_registration_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /* External */
  // Internet Connection Checker
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());

  // Firebase instances
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
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
    () => FirebaseAuthenticationService(firebaseAuth: sl<FirebaseAuth>()),
  );

  // Firebase Pets Service
  sl.registerLazySingleton<FirebasePetService>(
    () => FirebasePetService(
      firestore: sl<FirebaseFirestore>(),
      storageService: sl<FirebaseStorageService>(),
    ),
  );

  // Firebase Storage Service
  sl.registerLazySingleton<FirebaseStorageService>(
    () => FirebaseStorageService(storage: sl<FirebaseStorage>()),
  );

  // Firebase Users Service
  sl.registerLazySingleton<FirebaseUserService>(
    () => FirebaseUserService(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
      storageService: sl<FirebaseStorageService>(),
    ),
  );

  // Firebase Adoption Requests Service
  sl.registerLazySingleton<FirebaseAdoptionRequestsService>(
    () => FirebaseAdoptionRequestsService(firestore: sl<FirebaseFirestore>()),
  );

  // Firebase Chat Service
  sl.registerLazySingleton<FirebaseChatService>(
    () => FirebaseChatService(firestore: sl<FirebaseFirestore>()),
  );

  /* Repositories */
  // Authentication Repository
  sl.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(
      firebaseAuth: sl<FirebaseAuth>(),
      firebaseUserService: sl<FirebaseUserService>(),
      firebaseAuthentication: sl<FirebaseAuthenticationService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Pets Repository
  sl.registerLazySingleton<PetRepository>(
    () => PetRepositoryImpl(
      firebasePetService: sl<FirebasePetService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // User Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      firebaseUsersService: sl<FirebaseUserService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Adoption Requests Repository
  sl.registerLazySingleton<AdoptionRequestsRepository>(
    () => AdoptionRequestsRepositoryImpl(
      firebaseService: sl<FirebaseAdoptionRequestsService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Chat Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      firebaseChatService: sl<FirebaseChatService>(),
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
  sl.registerLazySingleton<CheckEmailVerificationUseCase>(
    () => CheckEmailVerificationUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<SendEmailVerificationUseCase>(
    () => SendEmailVerificationUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<SaveUserDataToFirestoreUseCase>(
    () => SaveUserDataToFirestoreUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<IsRegistrationCompleteUseCase>(
    () => IsRegistrationCompleteUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(sl<AuthenticationRepository>()),
  );

  // Pets Use Cases
  sl.registerLazySingleton<GetAllPetsUseCase>(
    () => GetAllPetsUseCase(sl<PetRepository>()),
  );
  sl.registerLazySingleton<GetPetsByCategoryUseCase>(
    () => GetPetsByCategoryUseCase(sl<PetRepository>()),
  );
  sl.registerLazySingleton<GetPetByIdUseCase>(
    () => GetPetByIdUseCase(sl<PetRepository>()),
  );
  sl.registerLazySingleton<CreatePetUseCase>(
    () => CreatePetUseCase(sl<PetRepository>()),
  );
  sl.registerLazySingleton<UpdatePetUseCase>(
    () => UpdatePetUseCase(sl<PetRepository>()),
  );
  sl.registerLazySingleton<DeletePetUseCase>(
    () => DeletePetUseCase(sl<PetRepository>()),
  );
  sl.registerLazySingleton<GetPetsByOwnerUseCase>(
    () => GetPetsByOwnerUseCase(sl<PetRepository>()),
  );
  sl.registerLazySingleton<GetPetsNearLocationUseCase>(
    () => GetPetsNearLocationUseCase(sl<PetRepository>()),
  );
  sl.registerLazySingleton<SearchPetsUseCase>(
    () => SearchPetsUseCase(sl<PetRepository>()),
  );
  sl.registerLazySingleton<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(sl<PetRepository>()),
  );
  sl.registerLazySingleton<GetFavoritePetsUseCase>(
    () => GetFavoritePetsUseCase(sl<PetRepository>()),
  );

  // User Use Cases
  sl.registerLazySingleton<GetUserByIdUseCase>(
    () => GetUserByIdUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUserStreamUseCase>(
    () => GetCurrentUserStreamUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<CreateUserUseCase>(
    () => CreateUserUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<UpdateUserUseCase>(
    () => UpdateUserUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<DeleteUserUseCase>(
    () => DeleteUserUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<UploadProfileImageUseCase>(
    () => UploadProfileImageUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<UpdateProfileImageUseCase>(
    () => UpdateProfileImageUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<ChangeProfilePhotoUseCase>(
    () => ChangeProfilePhotoUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<IncrementPetsPostedUseCase>(
    () => IncrementPetsPostedUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<IncrementPetsAdoptedUseCase>(
    () => IncrementPetsAdoptedUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<DecrementPetsPostedUseCase>(
    () => DecrementPetsPostedUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<UpdateNotificationSettingsUseCase>(
    () => UpdateNotificationSettingsUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<UpdateSearchRadiusUseCase>(
    () => UpdateSearchRadiusUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<MarkUserAsVerifiedUseCase>(
    () => MarkUserAsVerifiedUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<CheckUserExistsUseCase>(
    () => CheckUserExistsUseCase(sl<UserRepository>()),
  );

  // Adoption Requests Use Cases
  sl.registerLazySingleton<CreateAdoptionRequestUseCase>(
    () => CreateAdoptionRequestUseCase(sl<AdoptionRequestsRepository>()),
  );
  sl.registerLazySingleton<GetReceivedRequestsUseCase>(
    () => GetReceivedRequestsUseCase(sl<AdoptionRequestsRepository>()),
  );
  sl.registerLazySingleton<GetSentRequestsUseCase>(
    () => GetSentRequestsUseCase(sl<AdoptionRequestsRepository>()),
  );
  sl.registerLazySingleton<GetRequestsForPetUseCase>(
    () => GetRequestsForPetUseCase(sl<AdoptionRequestsRepository>()),
  );
  sl.registerLazySingleton<GetRequestByIdUseCase>(
    () => GetRequestByIdUseCase(sl<AdoptionRequestsRepository>()),
  );
  sl.registerLazySingleton<HasExistingRequestUseCase>(
    () => HasExistingRequestUseCase(sl<AdoptionRequestsRepository>()),
  );
  sl.registerLazySingleton<AcceptRequestUseCase>(
    () => AcceptRequestUseCase(sl<AdoptionRequestsRepository>()),
  );
  sl.registerLazySingleton<RejectRequestUseCase>(
    () => RejectRequestUseCase(sl<AdoptionRequestsRepository>()),
  );
  sl.registerLazySingleton<CancelRequestUseCase>(
    () => CancelRequestUseCase(sl<AdoptionRequestsRepository>()),
  );
  sl.registerLazySingleton<CompleteRequestUseCase>(
    () => CompleteRequestUseCase(sl<AdoptionRequestsRepository>()),
  );
  sl.registerLazySingleton<GetRequestStatisticsUseCase>(
    () => GetRequestStatisticsUseCase(sl<AdoptionRequestsRepository>()),
  );
  sl.registerLazySingleton<RejectPendingRequestsForPetUseCase>(
    () => RejectPendingRequestsForPetUseCase(sl<AdoptionRequestsRepository>()),
  );

  // Chat Use Cases
  sl.registerLazySingleton<CreateChatUseCase>(
    () => CreateChatUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<GetChatByAdoptionRequestIdUseCase>(
    () => GetChatByAdoptionRequestIdUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<GetChatByIdUseCase>(
    () => GetChatByIdUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<GetUserChatsStreamUseCase>(
    () => GetUserChatsStreamUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<UpdateChatStatusUseCase>(
    () => UpdateChatStatusUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<ArchiveChatUseCase>(
    () => ArchiveChatUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<DeleteChatUseCase>(
    () => DeleteChatUseCase(sl<ChatRepository>()),
  );

  // Message Use Cases
  sl.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<GetChatMessagesStreamUseCase>(
    () => GetChatMessagesStreamUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<MarkMessageAsReadUseCase>(
    () => MarkMessageAsReadUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<MarkAllMessagesAsDeliveredUseCase>(
    () => MarkAllMessagesAsDeliveredUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<MarkAllMessagesAsReadUseCase>(
    () => MarkAllMessagesAsReadUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<DeleteMessageUseCase>(
    () => DeleteMessageUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<GetUnreadMessagesCountUseCase>(
    () => GetUnreadMessagesCountUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<SendSystemMessageUseCase>(
    () => SendSystemMessageUseCase(sl<ChatRepository>()),
  );

  // Combined Use Case
  sl.registerLazySingleton<CreateOrGetChatUseCase>(
    () => CreateOrGetChatUseCase(
      getChatByAdoptionRequestId: sl<GetChatByAdoptionRequestIdUseCase>(),
      createChat: sl<CreateChatUseCase>(),
    ),
  );

  // Adoption Integration Use Cases
  sl.registerLazySingleton<InitiateChatFromAdoptionRequestUseCase>(
    () => InitiateChatFromAdoptionRequestUseCase(
      chatRepository: sl<ChatRepository>(),
      adoptionRepository: sl<AdoptionRequestsRepository>(),
      petRepository: sl<PetRepository>(),
      userRepository: sl<UserRepository>(),
    ),
  );

  sl.registerLazySingleton<SendAdoptionStatusUpdateUseCase>(
    () => SendAdoptionStatusUpdateUseCase(sl<ChatRepository>()),
  );

  // Providers
  sl.registerLazySingleton<UserProvider>(() => UserProvider()..initialize());
  sl.registerLazySingleton<PetProvider>(() => PetProvider());
  sl.registerLazySingleton<AdoptionRequestProvider>(
    () => AdoptionRequestProvider(),
  );
  sl.registerLazySingleton<PetRegistrationProvider>(
    () => PetRegistrationProvider(),
  );
  sl.registerLazySingleton<ChatProvider>(() => ChatProvider());
}
