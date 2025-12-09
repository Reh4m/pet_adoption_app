import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/core/constants/error_messages.dart';
import 'package:pet_adoption_app/src/core/di/index.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/usecases/media_usecases.dart';

enum MediaState { initial, loading, uploading, success, error }

class MediaProvider extends ChangeNotifier {
  final UploadChatImageUseCase _uploadImageUseCase =
      sl<UploadChatImageUseCase>();
  final UploadChatVideoUseCase _uploadVideoUseCase =
      sl<UploadChatVideoUseCase>();
  final ValidateImageSizeUseCase _validateImageSizeUseCase =
      sl<ValidateImageSizeUseCase>();
  final ValidateVideoSizeUseCase _validateVideoSizeUseCase =
      sl<ValidateVideoSizeUseCase>();

  MediaState _state = MediaState.initial;
  String? _uploadedUrl;
  String? _error;
  double _uploadProgress = 0.0;

  MediaState get state => _state;
  String? get uploadedUrl => _uploadedUrl;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;

  Future<String?> uploadImage({
    required File image,
    required String chatId,
    required String senderId,
  }) async {
    _setState(MediaState.loading);

    final validationResult = await _validateImageSizeUseCase(image);

    final isValid = validationResult.fold((failure) {
      _setError(_mapFailureToMessage(failure));
      return false;
    }, (valid) => valid);

    if (!isValid) return null;

    _setState(MediaState.uploading);

    final result = await _uploadImageUseCase(
      image: image,
      chatId: chatId,
      senderId: senderId,
    );

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return null;
      },
      (url) {
        _uploadedUrl = url;
        _setState(MediaState.success);
        return url;
      },
    );
  }

  Future<String?> uploadVideo({
    required File video,
    required String chatId,
    required String senderId,
  }) async {
    _setState(MediaState.loading);

    final validationResult = await _validateVideoSizeUseCase(video);

    final isValid = validationResult.fold((failure) {
      _setError(_mapFailureToMessage(failure));
      return false;
    }, (valid) => valid);

    if (!isValid) return null;

    _setState(MediaState.uploading);

    final result = await _uploadVideoUseCase(
      video: video,
      chatId: chatId,
      senderId: senderId,
    );

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return null;
      },
      (url) {
        _uploadedUrl = url;
        _setState(MediaState.success);
        return url;
      },
    );
  }

  void resetState() {
    _state = MediaState.initial;
    _uploadedUrl = null;
    _error = null;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  void _setState(MediaState newState) {
    _state = newState;
    if (newState != MediaState.error) {
      _error = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _setState(MediaState.error);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return ErrorMessages.networkError;
      case const (MediaTooLargeFailure):
        return 'El archivo es demasiado grande';
      case const (InvalidMediaFailure):
        return 'Archivo inválido';
      case const (MediaUploadFailure):
        return 'Error al subir archivo';
      default:
        return ErrorMessages.serverError;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
