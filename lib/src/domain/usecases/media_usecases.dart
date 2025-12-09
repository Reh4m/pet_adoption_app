import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/repositories/media_repository.dart';

class UploadChatImageUseCase {
  final MediaRepository repository;

  UploadChatImageUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required File image,
    required String chatId,
    required String senderId,
  }) async {
    return await repository.uploadChatImage(
      image: image,
      chatId: chatId,
      senderId: senderId,
    );
  }
}

class UploadChatVideoUseCase {
  final MediaRepository repository;

  UploadChatVideoUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required File video,
    required String chatId,
    required String senderId,
  }) async {
    return await repository.uploadChatVideo(
      video: video,
      chatId: chatId,
      senderId: senderId,
    );
  }
}

class UploadVideoThumbnailUseCase {
  final MediaRepository repository;

  UploadVideoThumbnailUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required File thumbnail,
    required String chatId,
    required String videoFileName,
  }) async {
    return await repository.uploadVideoThumbnail(
      thumbnail: thumbnail,
      chatId: chatId,
      videoFileName: videoFileName,
    );
  }
}

class DeleteMediaUseCase {
  final MediaRepository repository;

  DeleteMediaUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String mediaUrl) async {
    return await repository.deleteMedia(mediaUrl);
  }
}

class UploadFileWithProgressUseCase {
  final MediaRepository repository;

  UploadFileWithProgressUseCase(this.repository);

  Stream<Either<Failure, double>> call({
    required File file,
    required String path,
  }) {
    return repository.uploadFileWithProgress(file: file, path: path);
  }
}

class ValidateImageSizeUseCase {
  final MediaRepository repository;

  ValidateImageSizeUseCase(this.repository);

  Future<Either<Failure, bool>> call(File image) async {
    return await repository.validateImageSize(image);
  }
}

class ValidateVideoSizeUseCase {
  final MediaRepository repository;

  ValidateVideoSizeUseCase(this.repository);

  Future<Either<Failure, bool>> call(File video) async {
    return await repository.validateVideoSize(video);
  }
}
