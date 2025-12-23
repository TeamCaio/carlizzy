import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_image.dart';
import '../repositories/tryon_repository.dart';

class SelectUserImage {
  final TryonRepository repository;

  SelectUserImage(this.repository);

  Future<Either<Failure, UserImage>> call(ImageSource source) async {
    return await repository.selectImage(source);
  }
}
