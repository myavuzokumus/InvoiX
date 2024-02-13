import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

Future<void> imageFilter(final XFile image) async {
  img.Image adjustedImage = img.decodeImage(await image.readAsBytes())!;

  const int newWidth = 512;
  final int newHeight = (adjustedImage.height * newWidth) ~/ adjustedImage.width;

  adjustedImage =
      img.copyResize(adjustedImage, width: newWidth, height: newHeight);

  img.smooth(adjustedImage, weight: 3);
  img.adjustColor(adjustedImage, brightness: 1.17);

  final File imageFile = File(image.path);

  final pngBytes = await compute(img.encodePng, adjustedImage);
  await imageFile.writeAsBytes(pngBytes);

}
