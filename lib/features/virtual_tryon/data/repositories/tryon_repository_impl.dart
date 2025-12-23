import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/garment.dart';
import '../../domain/entities/tryon_result.dart';
import '../../domain/entities/user_image.dart';
import '../../domain/repositories/tryon_repository.dart';
import '../datasources/local_image_datasource.dart';
import '../datasources/replicate_remote_datasource.dart';
import '../models/tryon_request_model.dart';

class TryonRepositoryImpl implements TryonRepository {
  final ReplicateRemoteDataSource remoteDataSource;
  final LocalImageDataSource localDataSource;
  final NetworkInfo networkInfo;

  TryonRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserImage>> selectImage(ImageSource source) async {
    try {
      final UserImage userImage;
      if (source == ImageSource.camera) {
        userImage = await localDataSource.pickImageFromCamera();
      } else {
        userImage = await localDataSource.pickImageFromGallery();
      }
      return Right(userImage);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to select image: $e'));
    }
  }

  @override
  Future<Either<Failure, Garment>> generateGarmentFromText(
    String prompt,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('No internet connection. Please check your network.'),
      );
    }

    try {
      final category = _detectCategory(prompt);

      final response = await remoteDataSource.generateGarment(
        prompt,
        category,
      );

      final garment = response.toEntity(prompt, category);
      return Right(garment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, TryonResult>> applyVirtualTryon(
    UserImage userImage,
    Garment garment,
    String category,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('No internet connection. Please check your network.'),
      );
    }

    try {
      final userImageFile = File(userImage.path);
      final userImageUrl = await remoteDataSource.uploadImageAndGetUrl(
        userImageFile,
      );

      final request = TryonRequestModel(
        humanImageUrl: userImageUrl,
        garmentImageUrl: garment.imageUrl,
        garmentDescription: garment.description,
        category: category,
      );

      final response = await remoteDataSource.applyTryon(request);

      final result = response.toEntity(userImage, garment);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  String _detectCategory(String prompt) {
    final lower = prompt.toLowerCase();

    if (lower.contains('dress') || lower.contains('gown')) {
      return 'dresses';
    } else if (lower.contains('pants') ||
        lower.contains('jeans') ||
        lower.contains('shorts') ||
        lower.contains('skirt') ||
        lower.contains('trousers')) {
      return 'lower_body';
    } else {
      return 'upper_body';
    }
  }
}
