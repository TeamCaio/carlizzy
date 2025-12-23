import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/garment_generation_request_model.dart';
import '../models/garment_generation_response_model.dart';
import '../models/tryon_request_model.dart';
import '../models/tryon_response_model.dart';

abstract class ReplicateRemoteDataSource {
  Future<GarmentGenerationResponseModel> generateGarment(
    String prompt,
    String category,
  );

  Future<TryonResponseModel> applyTryon(TryonRequestModel request);

  Future<String> pollPrediction(String predictionId);

  Future<String> uploadImageAndGetUrl(File imageFile);
}

class ReplicateRemoteDataSourceImpl implements ReplicateRemoteDataSource {
  final Dio dio;
  final String apiToken;

  ReplicateRemoteDataSourceImpl({
    required this.dio,
    required this.apiToken,
  }) {
    dio.options = BaseOptions(
      baseUrl: ApiConstants.replicateBaseUrl,
      connectTimeout: Duration(seconds: ApiConstants.apiTimeoutSeconds),
      receiveTimeout: Duration(seconds: ApiConstants.apiTimeoutSeconds),
      headers: {
        ApiConstants.authHeaderKey: ApiConstants.getAuthHeaderValue(apiToken),
        ApiConstants.contentTypeHeaderKey: ApiConstants.contentTypeJson,
      },
    );
  }

  @override
  Future<GarmentGenerationResponseModel> generateGarment(
    String prompt,
    String category,
  ) async {
    try {
      final enhancedPrompt = _enhancePrompt(prompt, category);

      final requestModel = GarmentGenerationRequestModel(
        prompt: enhancedPrompt,
      );

      final response = await dio.post(
        ApiConstants.predictionsEndpoint,
        data: {
          'version': ApiConstants.fluxSchnellModel,
          'input': requestModel.toJson(),
        },
      );

      if (response.statusCode != 201) {
        throw ServerException(
          'Failed to create prediction',
          statusCode: response.statusCode,
        );
      }

      final predictionId = response.data['id'] as String;

      final outputUrl = await pollPrediction(predictionId);

      return GarmentGenerationResponseModel(
        id: predictionId,
        status: 'succeeded',
        output: [outputUrl],
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<TryonResponseModel> applyTryon(TryonRequestModel request) async {
    try {
      final response = await dio.post(
        ApiConstants.predictionsEndpoint,
        data: {
          'version': ApiConstants.idmVtonModel,
          'input': request.toJson(),
        },
      );

      if (response.statusCode != 201) {
        throw ServerException(
          'Failed to create prediction',
          statusCode: response.statusCode,
        );
      }

      final predictionId = response.data['id'] as String;

      final outputUrl = await pollPrediction(predictionId);

      return TryonResponseModel(
        id: predictionId,
        status: 'succeeded',
        output: outputUrl,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<String> pollPrediction(String predictionId) async {
    int attempts = 0;

    while (attempts < ApiConstants.maxPollAttempts) {
      try {
        await Future.delayed(
          Duration(milliseconds: ApiConstants.pollIntervalMilliseconds),
        );

        final response = await dio.get(
          ApiConstants.getPredictionUrl(predictionId).replaceFirst(
            ApiConstants.replicateBaseUrl,
            '',
          ),
        );

        if (response.statusCode != 200) {
          throw ServerException(
            'Failed to get prediction status',
            statusCode: response.statusCode,
          );
        }

        final status = response.data['status'] as String;

        if (status == 'succeeded') {
          final output = response.data['output'];

          if (output is List && output.isNotEmpty) {
            return output.first as String;
          } else if (output is String && output.isNotEmpty) {
            return output;
          } else {
            throw ServerException('Invalid output format from API');
          }
        } else if (status == 'failed' || status == 'canceled') {
          final error = response.data['error'] as String? ??
              'Prediction failed with status: $status';
          throw ServerException(error);
        }

        attempts++;
      } on DioException catch (e) {
        throw _handleDioException(e);
      }
    }

    throw TimeoutException(
      'Prediction timed out after ${ApiConstants.maxPollAttempts} attempts',
    );
  }

  @override
  Future<String> uploadImageAndGetUrl(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = bytes.toString();

      final extension = imageFile.path.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      throw ServerException('Failed to prepare image: $e');
    }
  }

  String _enhancePrompt(String userPrompt, String category) {
    return 'professional product photography of a $category, $userPrompt, '
        'high quality, detailed, clean background, studio lighting';
  }

  ServerException _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ServerException('Request timed out. Please try again.');
    } else if (e.type == DioExceptionType.connectionError) {
      return ServerException('Connection error. Please check your network.');
    } else if (e.response != null) {
      final statusCode = e.response!.statusCode;
      String message;

      switch (statusCode) {
        case 401:
          message = 'Authentication failed. Please check API configuration.';
          break;
        case 429:
          message = 'Too many requests. Please try again in a moment.';
          break;
        case 500:
        case 502:
        case 503:
          message = 'Service temporarily unavailable. Please try again.';
          break;
        default:
          message = 'Server error occurred. Please try again.';
      }

      return ServerException(message, statusCode: statusCode);
    }

    return ServerException('Unexpected error occurred: ${e.message}');
  }
}
