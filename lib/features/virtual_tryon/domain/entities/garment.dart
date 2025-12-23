import 'package:equatable/equatable.dart';

class Garment extends Equatable {
  final String imageUrl;
  final String description;
  final String category;
  final DateTime timestamp;

  const Garment({
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.timestamp,
  });

  @override
  List<Object> get props => [imageUrl, description, category, timestamp];
}
