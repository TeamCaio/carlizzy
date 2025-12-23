import 'package:equatable/equatable.dart';

class UserImage extends Equatable {
  final String path;
  final String fileName;
  final int size;
  final double aspectRatio;

  const UserImage({
    required this.path,
    required this.fileName,
    required this.size,
    required this.aspectRatio,
  });

  @override
  List<Object> get props => [path, fileName, size, aspectRatio];
}
