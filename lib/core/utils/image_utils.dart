import 'dart:io';
import 'package:image/image.dart' as img;
import '../errors/exceptions.dart';

class ImageUtils {
  static const int maxFileSizeInBytes = 10 * 1024 * 1024; // 10MB
  static const int targetWidth = 1024;
  static const int targetHeight = 1024;
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

  static Future<File> compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      if (bytes.length <= maxFileSizeInBytes &&
          bytes.length <= 1024 * 1024) {
        return imageFile;
      }

      final image = img.decodeImage(bytes);
      if (image == null) {
        throw ValidationException('Invalid image file');
      }

      img.Image resizedImage;
      if (image.width > targetWidth || image.height > targetHeight) {
        resizedImage = img.copyResize(
          image,
          width: targetWidth,
          height: targetHeight,
          maintainAspect: true,
        );
      } else {
        resizedImage = image;
      }

      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);

      final compressedFile = File('${imageFile.path}_compressed.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ValidationException('Failed to compress image: $e');
    }
  }

  static bool validateImageFile(File imageFile) {
    final extension = imageFile.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return false;
    }

    final fileSize = imageFile.lengthSync();
    if (fileSize > maxFileSizeInBytes) {
      return false;
    }

    return true;
  }

  static Future<String> convertToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = 'data:image/jpeg;base64,${bytes.toString()}';
      return base64String;
    } catch (e) {
      throw ValidationException('Failed to convert image to base64: $e');
    }
  }

  static Future<double> getAspectRatio(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw ValidationException('Invalid image file');
      }

      return image.width / image.height;
    } catch (e) {
      throw ValidationException('Failed to get image aspect ratio: $e');
    }
  }
}
