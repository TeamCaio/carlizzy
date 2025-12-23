import 'package:equatable/equatable.dart';
import 'user_image.dart';
import 'garment.dart';

class TryonResult extends Equatable {
  final String resultImageUrl;
  final UserImage originalImage;
  final Garment garment;
  final DateTime createdAt;

  const TryonResult({
    required this.resultImageUrl,
    required this.originalImage,
    required this.garment,
    required this.createdAt,
  });

  @override
  List<Object> get props => [resultImageUrl, originalImage, garment, createdAt];
}
