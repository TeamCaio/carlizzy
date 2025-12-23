import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/image_utils.dart';
import '../../domain/entities/user_image.dart';

abstract class LocalImageDataSource {
  Future<UserImage> pickImageFromGallery();
  Future<UserImage> pickImageFromCamera();
  Future<File> compressImage(File image);
}

class LocalImageDataSourceImpl implements LocalImageDataSource {
  final ImagePicker imagePicker;

  LocalImageDataSourceImpl(this.imagePicker);

  @override
  Future<UserImage> pickImageFromGallery() async {
    return _pickImage(ImageSource.gallery);
  }

  @override
  Future<UserImage> pickImageFromCamera() async {
    return _pickImage(ImageSource.camera);
  }

  Future<UserImage> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile == null) {
        throw CacheException('No image selected');
      }

      final File imageFile = File(pickedFile.path);

      if (!ImageUtils.validateImageFile(imageFile)) {
        throw ValidationException(
          'Invalid image file. Please use JPG or PNG format under 10MB.',
        );
      }

      final compressedFile = await compressImage(imageFile);
      final aspectRatio = await ImageUtils.getAspectRatio(compressedFile);
      final fileSize = compressedFile.lengthSync();
      final fileName = compressedFile.path.split('/').last;

      return UserImage(
        path: compressedFile.path,
        fileName: fileName,
        size: fileSize,
        aspectRatio: aspectRatio,
      );
    } catch (e) {
      if (e is CacheException || e is ValidationException) {
        rethrow;
      }
      throw CacheException('Failed to pick image: $e');
    }
  }

  @override
  Future<File> compressImage(File image) async {
    try {
      return await ImageUtils.compressImage(image);
    } catch (e) {
      throw CacheException('Failed to compress image: $e');
    }
  }
}
