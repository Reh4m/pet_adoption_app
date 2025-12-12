import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/core/network/network_info.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/notification_service.dart';
import 'package:pet_adoption_app/src/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseNotificationService _messagingService;
  final NetworkInfo _networkInfo;

  String? _currentToken;

  NotificationRepositoryImpl({
    required FirebaseNotificationService messagingService,
    required NetworkInfo networkInfo,
  }) : _messagingService = messagingService,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, Unit>> initialize() async {
    try {
      await _messagingService.initialize();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermission() async {
    try {
      final granted = await _messagingService.requestPermission();
      return Right(granted);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> getAndSaveToken(String userId) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final token = await _messagingService.getToken();
      if (token == null) {
        return Left(ServerFailure());
      }

      _currentToken = token;
      await _messagingService.saveTokenToFirestore(userId);
      return Right(token);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> removeToken(String userId) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await _messagingService.removeTokenFromFirestore(userId);
      _currentToken = null;
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, RemoteMessage?>> getInitialMessage() async {
    try {
      final message = await _messagingService.getInitialMessage();
      return Right(message);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await _messagingService.showLocalNotification(
        title: title,
        body: body,
        payload: payload,
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> subscribeToTopic(String topic) async {
    try {
      await _messagingService.subscribeToTopic(topic);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> unsubscribeFromTopic(String topic) async {
    try {
      await _messagingService.unsubscribeFromTopic(topic);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<String> get onTokenRefresh => _messagingService.onTokenRefresh;

  @override
  Stream<RemoteMessage> get onForegroundMessage =>
      _messagingService.onMessageForeground;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      _messagingService.onMessageOpenedApp;

  @override
  String? get currentToken => _currentToken;
}
