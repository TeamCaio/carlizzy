import '../../domain/entities/garment.dart';
import '../../domain/entities/tryon_result.dart';
import '../../domain/entities/user_image.dart';

class TryonResponseModel {
  final String id;
  final String status;
  final String? output;
  final String? error;

  const TryonResponseModel({
    required this.id,
    required this.status,
    this.output,
    this.error,
  });

  factory TryonResponseModel.fromJson(Map<String, dynamic> json) {
    return TryonResponseModel(
      id: json['id'] as String,
      status: json['status'] as String,
      output: json['output'] as String?,
      error: json['error'] as String?,
    );
  }

  TryonResult toEntity(UserImage originalImage, Garment garment) {
    if (output == null || output!.isEmpty) {
      throw Exception('No try-on result generated');
    }

    return TryonResult(
      resultImageUrl: output!,
      originalImage: originalImage,
      garment: garment,
      createdAt: DateTime.now(),
    );
  }
}
