import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:thumbhash/thumbhash.dart' as thumbhash;

// takes image picker xfile & generates thumbhash
Future<String?> getThumbhashFromXFile(XFile file) async {
  final Uint8List sourceImageBytes = await file.readAsBytes();

  // Thumbhash encoding must have a 100x100 image max, so generate first
  img.Image? originalImage = img.decodeImage(sourceImageBytes);
  if (originalImage == null) {
    throw Exception('Could not decode image');
  }
  int originalWidth = originalImage.width;
  int originalHeight = originalImage.height;
  double scalingFactor = 100 / originalWidth < 100 / originalHeight
      ? 100 / originalWidth
      : 100 / originalHeight;
  int newWidth = (originalWidth * scalingFactor).round();
  int newHeight = (originalHeight * scalingFactor).round();
  img.Image resizedImage = img.copyResize(
    originalImage,
    width: newWidth,
    height: newHeight,
  );

  // Convert the resized image to RGBA format
  Uint8List rgbaBytes = Uint8List(newWidth * newHeight * 4);
  int index = 0;
  for (int y = 0; y < newHeight; y++) {
    for (int x = 0; x < newWidth; x++) {
      img.Pixel pixel = resizedImage.getPixel(x, y);
      List<num> pixelList = pixel.toList();

      // Ensure the pixel list has 4 values (RGBA), with default alpha of 255
      int r = (pixelList[0] as int);
      int g = (pixelList[1] as int);
      int b = (pixelList[2] as int);
      int a = ((pixelList.length > 3 ? pixelList[3] : 255) as int);

      rgbaBytes[index++] = r;
      rgbaBytes[index++] = g;
      rgbaBytes[index++] = b;
      rgbaBytes[index++] = a;
    }
  }

  final thumbhashBytes = thumbhash.rgbaToThumbHash(
    resizedImage.width,
    resizedImage.height,
    rgbaBytes,
  );
  return base64.encode(thumbhashBytes);
}
