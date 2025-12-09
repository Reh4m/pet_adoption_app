import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum MediaType { image, video }

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> pickVideoFromCamera() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> showImageSourceDialog(
    BuildContext context, {
    required Function(File?) onImageSelected,
  }) async {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Seleccionar fuente de imagen',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: theme.colorScheme.error,
                ),
                title: const Text('Galería'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await pickImageFromGallery();
                  onImageSelected(image);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: theme.colorScheme.error),
                title: const Text('Cámara'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await pickImageFromCamera();
                  onImageSelected(image);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showMediaPickerDialog(
    BuildContext context, {
    required Function(File?, MediaType) onMediaSelected,
  }) async {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Seleccionar tipo de archivo',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.photo, color: theme.colorScheme.error),
                title: const Text('Foto'),
                subtitle: const Text('Desde galería o cámara'),
                onTap: () {
                  Navigator.pop(context);
                  showImageSourceDialog(
                    context,
                    onImageSelected: (file) {
                      onMediaSelected(file, MediaType.image);
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam, color: theme.colorScheme.error),
                title: const Text('Video'),
                subtitle: const Text('Desde galería o cámara'),
                onTap: () async {
                  Navigator.pop(context);
                  final video = await pickVideoFromGallery();
                  onMediaSelected(video, MediaType.video);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static String getFileExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }

  static String getFileName(File file) {
    return file.path.split('/').last;
  }
}
