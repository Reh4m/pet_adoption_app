import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';

abstract class MediaRepository {
  Future<Either<Failure, String>> uploadChatImage({
    required File image,
    required String chatId,
    required String senderId,
  });
  Future<Either<Failure, String>> uploadChatVideo({
    required File video,
    required String chatId,
    required String senderId,
  });
  Future<Either<Failure, String>> uploadVideoThumbnail({
    required File thumbnail,
    required String chatId,
    required String videoFileName,
  });
  Future<Either<Failure, Unit>> deleteMedia(String mediaUrl);
  Stream<Either<Failure, double>> uploadFileWithProgress({
    required File file,
    required String path,
  });
  Future<Either<Failure, bool>> validateImageSize(File image);
  Future<Either<Failure, bool>> validateVideoSize(File video);
}
