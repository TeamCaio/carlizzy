import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/garment.dart';
import '../repositories/tryon_repository.dart';

class GenerateGarmentFromText {
  final TryonRepository repository;

  GenerateGarmentFromText(this.repository);

  Future<Either<Failure, Garment>> call(String prompt) async {
    return await repository.generateGarmentFromText(prompt);
  }
}
