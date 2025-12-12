import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';

abstract class NotificationRepository {
  Future<Either<Failure, Unit>> initialize();

  Future<Either<Failure, bool>> requestPermission();

  Future<Either<Failure, String>> getAndSaveToken(String userId);

  Future<Either<Failure, Unit>> removeToken(String userId);

  Future<Either<Failure, RemoteMessage?>> getInitialMessage();

  Future<Either<Failure, Unit>> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  });

  Future<Either<Failure, Unit>> subscribeToTopic(String topic);

  Future<Either<Failure, Unit>> unsubscribeFromTopic(String topic);

  Stream<String> get onTokenRefresh;

  Stream<RemoteMessage> get onForegroundMessage;

  Stream<RemoteMessage> get onMessageOpenedApp;

  String? get currentToken;
}
