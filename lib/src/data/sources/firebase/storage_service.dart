import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pet_adoption_app/src/core/errors/exceptions.dart';

class FirebaseStorageService {
  final FirebaseStorage storage;

  FirebaseStorageService({required this.storage});

  Future<List<String>> uploadPetImages(List<File> images, String petId) async {
    try {
      final List<String> imageUrls = [];

      for (int i = 0; i < images.length; i++) {
        final fileName = '${petId}_image_$i.jpg';
        final ref = storage.ref().child('pets').child(petId).child(fileName);

        // Subir la imagen
        final uploadTask = ref.putFile(images[i]);
        final snapshot = await uploadTask;

        // Obtener la URL de descarga
        final downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      return imageUrls;
    } catch (e) {
      throw ServerException();
    }
  }

  Future<String> uploadUserProfileImage(File image, String userId) async {
    try {
      final fileName = '${userId}_profile.jpg';
      final ref = storage.ref().child('users').child(userId).child(fileName);

      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> deletePetImages(String petId) async {
    try {
      final petRef = storage.ref().child('pets').child(petId);
      final listResult = await petRef.listAll();

      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> deleteImageByUrl(String imageUrl) async {
    try {
      final ref = storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw ServerException();
    }
  }

  /// Actualizar imágenes de una mascota (eliminar las antiguas y subir las nuevas)
  Future<List<String>> updatePetImages(
    List<File> newImages,
    String petId,
    List<String> oldImageUrls,
  ) async {
    try {
      // Eliminar imágenes antiguas
      for (final url in oldImageUrls) {
        await deleteImageByUrl(url);
      }

      // Subir nuevas imágenes
      return await uploadPetImages(newImages, petId);
    } catch (e) {
      throw ServerException();
    }
  }
}
