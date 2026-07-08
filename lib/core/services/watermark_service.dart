import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

/// Composites the Muse logo as a centered, semi-transparent watermark onto
/// try-on result images for users without an active subscription.
class WatermarkService {
  static const double _opacity = 0.35;
  static const double _sizeFraction = 0.4;
  static const String _logoAsset = 'assets/images/muse_logo.png';

  static Uint8List? _logoBytes;

  static Future<Uint8List> apply(Uint8List sourceBytes) async {
    final image = img.decodeImage(sourceBytes);
    if (image == null) return sourceBytes;

    _logoBytes ??= (await rootBundle.load(_logoAsset)).buffer.asUint8List();
    var logo = img.decodeImage(_logoBytes!);
    if (logo == null) return sourceBytes;

    final shorterSide = image.width < image.height ? image.width : image.height;
    final targetWidth = (shorterSide * _sizeFraction).round();
    logo = img.copyResize(logo, width: targetWidth);

    for (final pixel in logo) {
      pixel.a = pixel.a * _opacity;
    }

    img.compositeImage(image, logo, center: true, blend: img.BlendMode.alpha);

    return Uint8List.fromList(img.encodeJpg(image, quality: 92));
  }
}
