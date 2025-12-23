import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../entities/garment.dart';
import '../entities/tryon_result.dart';
import '../entities/user_image.dart';

abstract class TryonRepository {
  Future<Either<Failure, UserImage>> selectImage(ImageSource source);

  Future<Either<Failure, Garment>> generateGarmentFromText(String prompt);

  Future<Either<Failure, TryonResult>> applyVirtualTryon(
    UserImage userImage,
    Garment garment,
    String category,
  );
}
