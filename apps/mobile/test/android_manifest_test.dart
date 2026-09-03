import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release Android manifest declares internet permission', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml');

    expect(
      manifest.readAsStringSync(),
      contains('android.permission.INTERNET'),
    );
  });

  test('Android launcher uses Barom Kagyu Calendar app name and branded icon', () async {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final adaptiveIcon = File(
      'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
    );
    final adaptiveRoundIcon = File(
      'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml',
    );
    final adaptiveBackground = File(
      'android/app/src/main/res/values/ic_launcher_background.xml',
    );
    final xxxhdpiIcon = File(
      'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
    );
    final xxxhdpiForeground = File(
      'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png',
    );
    final icon = await _decodeImage(xxxhdpiIcon);
    final cornerPixel = await _pixelAt(icon, 0, 0);
    final insetPixel = await _pixelAt(icon, 10, 10);
    final whiteTextPixels = await _nearWhitePixelsInBand(
      icon,
      topRatio: 0.84,
      bottomRatio: 0.97,
    );
    final maroonBackgroundPixels = await _nearMaroonPixelsInBand(
      icon,
      topRatio: 0.84,
      bottomRatio: 0.97,
    );

    expect(manifest, contains('android:label="Barom Kagyu Calendar"'));
    expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
    expect(manifest, contains('android:roundIcon="@mipmap/ic_launcher_round"'));
    expect(
      adaptiveIcon.readAsStringSync(),
      contains('@color/ic_launcher_background'),
    );
    expect(
      adaptiveIcon.readAsStringSync(),
      contains('@mipmap/ic_launcher_foreground'),
    );
    expect(
      adaptiveRoundIcon.readAsStringSync(),
      contains('@color/ic_launcher_background'),
    );
    expect(adaptiveBackground.readAsStringSync(), contains('#730005'));
    expect(xxxhdpiIcon.lengthSync(), greaterThan(10000));
    expect(xxxhdpiForeground.lengthSync(), greaterThan(10000));
    expect(_isNearWhite(cornerPixel), isFalse);
    expect(_isNearMaroon(insetPixel), isTrue);
    expect(whiteTextPixels, lessThan(100));
    expect(maroonBackgroundPixels, greaterThan(4500));
    final foreground = await _decodeImage(xxxhdpiForeground);
    expect(await _alphaAt(foreground, 0, 0), 0);
  });

  test('iOS bundle uses Barom Kagyu Calendar app name and icon', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    final marketingIcon = File(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
    );

    expect(plist, contains('<string>Barom Kagyu Calendar</string>'));
    expect(marketingIcon.lengthSync(), greaterThan(10000));
  });
}

Future<Image> _decodeImage(File file) async {
  final bytes = await file.readAsBytes();
  final codec = await instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}

Future<int> _pixelAt(Image image, int x, int y) async {
  final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
  final pixels = byteData!.buffer.asUint8List();
  final offset = (y * image.width + x) * 4;
  final red = pixels[offset];
  final green = pixels[offset + 1];
  final blue = pixels[offset + 2];
  final alpha = pixels[offset + 3];
  return red << 24 | green << 16 | blue << 8 | alpha;
}

Future<int> _alphaAt(Image image, int x, int y) async {
  final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
  final pixels = byteData!.buffer.asUint8List();
  final offset = (y * image.width + x) * 4;
  return pixels[offset + 3];
}

bool _isNearWhite(int rgba) {
  final red = (rgba >> 24) & 0xff;
  final green = (rgba >> 16) & 0xff;
  final blue = (rgba >> 8) & 0xff;
  return red > 245 && green > 245 && blue > 245;
}

bool _isNearMaroon(int rgba) {
  final red = (rgba >> 24) & 0xff;
  final green = (rgba >> 16) & 0xff;
  final blue = (rgba >> 8) & 0xff;
  return red >= 70 && red <= 130 && green < 20 && blue < 20;
}

Future<int> _nearWhitePixelsInBand(
  Image image, {
  required double topRatio,
  required double bottomRatio,
}) async {
  final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
  final pixels = byteData!.buffer.asUint8List();
  final top = (image.height * topRatio).round();
  final bottom = (image.height * bottomRatio).round();
  var count = 0;
  for (var y = top; y < bottom; y++) {
    for (var x = 0; x < image.width; x++) {
      final offset = (y * image.width + x) * 4;
      final red = pixels[offset];
      final green = pixels[offset + 1];
      final blue = pixels[offset + 2];
      if (red > 245 && green > 245 && blue > 245) count++;
    }
  }
  return count;
}

Future<int> _nearMaroonPixelsInBand(
  Image image, {
  required double topRatio,
  required double bottomRatio,
}) async {
  final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
  final pixels = byteData!.buffer.asUint8List();
  final top = (image.height * topRatio).round();
  final bottom = (image.height * bottomRatio).round();
  var count = 0;
  for (var y = top; y < bottom; y++) {
    for (var x = 0; x < image.width; x++) {
      final offset = (y * image.width + x) * 4;
      final red = pixels[offset];
      final green = pixels[offset + 1];
      final blue = pixels[offset + 2];
      if (red >= 70 && red <= 130 && green < 20 && blue < 20) count++;
    }
  }
  return count;
}
