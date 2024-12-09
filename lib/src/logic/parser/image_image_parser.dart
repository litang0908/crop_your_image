import 'dart:typed_data';

import 'package:crop_your_image/src/logic/format_detector/format.dart';
import 'package:crop_your_image/src/logic/parser/errors.dart';
import 'package:crop_your_image/src/logic/parser/image_detail.dart';
import 'package:image/image.dart' as image;

import 'image_parser.dart';

/// Implementation of [ImageParser] using image package
/// Parsed image is represented as [image.Image]
final ImageParser<image.Image> imageImageParser = (data, {inputFormat}) {
  late final image.Image? tempImage;
  try {
    tempImage = _decodeWith(data, format: inputFormat);
  } on InvalidInputFormatError {
    rethrow;
  }

  assert(tempImage != null);

  // check orientation
  image.Image parsed;
  switch (tempImage?.exif.exifIfd.orientation ?? -1) {
    case 3:
      parsed = image.copyRotate(tempImage!, angle: 180);
      break;
    case 6:
      parsed = image.copyRotate(tempImage!, angle: 90);
      break;
    case 8:
      parsed = image.copyRotate(tempImage!, angle: -90);
      break;
    default:
      parsed = tempImage!;
      break;
  }
  return ImageDetail(
    image: parsed,
    width: parsed.width.toDouble(),
    height: parsed.height.toDouble(),
  );
};

image.Image? _decodeWith(Uint8List data, {ImageFormat? format}) {
  try {
    image.Image? result = null;
    switch (format) {
      case ImageFormat.jpeg:
        result = image.decodeJpg(data);
        break;
      case ImageFormat.png:
        result = image.decodePng(data);
        break;
      case ImageFormat.bmp:
        result = image.decodeBmp(data);
        break;
      case ImageFormat.ico:
        result = image.decodeIco(data);
        break;
      case ImageFormat.webp:
        result = image.decodeWebP(data);
        break;
      default:
        result = image.decodeImage(data);
        break;
    }
    return result;
  } on image.ImageException {
    throw InvalidInputFormatError(format);
  }
}
