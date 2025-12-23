import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/garment.dart';
import '../entities/tryon_result.dart';
import '../entities/user_image.dart';
import '../repositories/tryon_repository.dart';

class ApplyVirtualTryon {
  final TryonRepository repository;

  ApplyVirtualTryon(this.repository);

  Future<Either<Failure, TryonResult>> call(
    UserImage userImage,
    Garment garment,
    String category,
  ) async {
    return await repository.applyVirtualTryon(userImage, garment, category);
  }
}
