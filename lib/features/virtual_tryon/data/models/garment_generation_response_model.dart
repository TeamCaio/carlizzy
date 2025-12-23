import '../../domain/entities/garment.dart';

class GarmentGenerationResponseModel {
  final String id;
  final String status;
  final List<String>? output;
  final String? error;

  const GarmentGenerationResponseModel({
    required this.id,
    required this.status,
    this.output,
    this.error,
  });

  factory GarmentGenerationResponseModel.fromJson(Map<String, dynamic> json) {
    return GarmentGenerationResponseModel(
      id: json['id'] as String,
      status: json['status'] as String,
      output: json['output'] != null
          ? List<String>.from(json['output'] as List)
          : null,
      error: json['error'] as String?,
    );
  }

  Garment toEntity(String description, String category) {
    if (output == null || output!.isEmpty) {
      throw Exception('No garment image generated');
    }

    return Garment(
      imageUrl: output!.first,
      description: description,
      category: category,
      timestamp: DateTime.now(),
    );
  }
}
