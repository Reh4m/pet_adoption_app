import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/exceptions.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/core/network/network_info.dart';
import 'package:pet_adoption_app/src/data/sources/firebase/storage_service.dart';
import 'package:pet_adoption_app/src/domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  final FirebaseStorageService storageService;
  final NetworkInfo networkInfo;

  MediaRepositoryImpl({
    required this.storageService,
    required this.networkInfo,
  });

  static const int maxImageSizeInBytes = 10 * 1024 * 1024;
  static const int maxVideoSizeInBytes = 50 * 1024 * 1024;
  static const int maxAudioSizeInBytes = 10 * 1024 * 1024;

  @override
  Future<Either<Failure, String>> uploadChatImage({
    required File image,
    required String chatId,
    required String senderId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final isValidSize = await validateImageSize(image);
      if (isValidSize.isLeft()) {
        return Left(MediaTooLargeFailure());
      }

      final url = await storageService.uploadChatImage(
        image: image,
        chatId: chatId,
        senderId: senderId,
      );
      return Right(url);
    } on MediaUploadException {
      return Left(MediaUploadFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadChatVideo({
    required File video,
    required String chatId,
    required String senderId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final isValidSize = await validateVideoSize(video);
      if (isValidSize.isLeft()) {
        return Left(MediaTooLargeFailure());
      }

      final url = await storageService.uploadChatVideo(
        video: video,
        chatId: chatId,
        senderId: senderId,
      );
      return Right(url);
    } on MediaUploadException {
      return Left(MediaUploadFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadVideoThumbnail({
    required File thumbnail,
    required String chatId,
    required String videoFileName,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final url = await storageService.uploadVideoThumbnail(
        thumbnail: thumbnail,
        chatId: chatId,
        videoFileName: videoFileName,
      );
      return Right(url);
    } on ThumbnailGenerationException {
      return Left(ThumbnailGenerationFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMedia(String mediaUrl) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await storageService.deleteMediaByUrl(mediaUrl);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, double>> uploadFileWithProgress({
    required File file,
    required String path,
  }) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final snapshot in storageService.uploadFileWithProgress(
        file: file,
        path: path,
      )) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        yield Right(progress);
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> validateImageSize(File image) async {
    try {
      final fileSize = await image.length();
      if (fileSize > maxImageSizeInBytes) {
        return Left(MediaTooLargeFailure());
      }
      return const Right(true);
    } catch (e) {
      return Left(InvalidMediaFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> validateVideoSize(File video) async {
    try {
      final fileSize = await video.length();
      if (fileSize > maxVideoSizeInBytes) {
        return Left(MediaTooLargeFailure());
      }
      return const Right(true);
    } catch (e) {
      return Left(InvalidMediaFailure());
    }
  }
}
