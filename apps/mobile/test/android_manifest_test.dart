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

  test(
    'Android launcher uses Barom Kagyu Calendar app name and branded icon',
    () async {
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
      final blueBackgroundPixels = await _nearIconBluePixelsInBand(
        icon,
        topRatio: 0.84,
        bottomRatio: 0.97,
      );

      expect(manifest, contains('android:label="Barom Kagyu Calendar"'));
      expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
      expect(
        manifest,
        contains('android:name="io.flutter.embedding.android.EnableImpeller"'),
      );
      expect(manifest, contains('android:value="false"'));
      expect(
        manifest,
        contains('android:roundIcon="@mipmap/ic_launcher_round"'),
      );
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
      expect(adaptiveBackground.readAsStringSync(), contains('#1F4F8D'));
      expect(xxxhdpiIcon.lengthSync(), greaterThan(10000));
      expect(xxxhdpiForeground.lengthSync(), greaterThan(10000));
      expect(_isNearIconBlue(cornerPixel), isTrue);
      expect(_isNearIconBlue(insetPixel), isTrue);
      expect(blueBackgroundPixels, greaterThan(2000));
      final foreground = await _decodeImage(xxxhdpiForeground);
      expect(await _alphaAt(foreground, 0, 0), 0);
      expect(
        _isNearLogoDeepRed(
          await _pixelAt(
            foreground,
            foreground.width ~/ 2,
            _logoTopInset(foreground.width) + (foreground.width * 0.05).round(),
          ),
        ),
        isTrue,
      );
    },
  );

  test('Today logo asset contains only the circular logo artwork', () async {
    final logo = await _decodeImage(File('assets/images/barom_kagyu_logo.png'));

    expect(await _alphaAt(logo, 0, 0), 0);
    expect(await _alphaAt(logo, 10, 10), 0);
    expect(_isNearLogoGold(await _pixelAt(logo, logo.width ~/ 2, 4)), isTrue);
    expect(
      _isNearLogoDeepRed(await _pixelAt(logo, logo.width ~/ 2, 20)),
      isTrue,
    );
    expect(await _alphaAt(logo, logo.width ~/ 2, logo.height ~/ 2), 255);
  });

  test('iOS bundle uses Barom Kagyu Calendar app name and background sync', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    final appDelegate = File('ios/Runner/AppDelegate.swift').readAsStringSync();
    final marketingIcon = File(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
    );

    expect(plist, contains('<string>Barom Kagyu Calendar</string>'));
    expect(plist, contains('<key>UIBackgroundModes</key>'));
    expect(plist, contains('<string>processing</string>'));
    expect(plist, contains('<key>BGTaskSchedulerPermittedIdentifiers</key>'));
    expect(
      plist,
      contains('<string>barom_kagyu_calendar_background_sync</string>'),
    );
    expect(appDelegate, contains('import workmanager_apple'));
    expect(appDelegate, contains('WorkmanagerPlugin.registerLaunchHandlers()'));
    expect(
      appDelegate,
      contains('WorkmanagerPlugin.setPluginRegistrantCallback'),
    );
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

bool _isNearLogoDeepRed(int rgba) {
  final red = (rgba >> 24) & 0xff;
  final green = (rgba >> 16) & 0xff;
  final blue = (rgba >> 8) & 0xff;
  return red >= 90 && red <= 150 && green <= 25 && blue <= 30;
}

bool _isNearLogoGold(int rgba) {
  final red = (rgba >> 24) & 0xff;
  final green = (rgba >> 16) & 0xff;
  final blue = (rgba >> 8) & 0xff;
  return red >= 220 && green >= 145 && green <= 200 && blue <= 50;
}

bool _isNearIconBlue(int rgba) {
  final red = (rgba >> 24) & 0xff;
  final green = (rgba >> 16) & 0xff;
  final blue = (rgba >> 8) & 0xff;
  return red >= 20 &&
      red <= 42 &&
      green >= 68 &&
      green <= 90 &&
      blue >= 128 &&
      blue <= 152;
}

int _logoTopInset(int size) {
  final logoSize = (size * 0.76).round();
  return ((size - logoSize) / 2).round();
}

Future<int> _nearIconBluePixelsInBand(
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
      if (red >= 20 &&
          red <= 42 &&
          green >= 68 &&
          green <= 90 &&
          blue >= 128 &&
          blue <= 152) {
        count++;
      }
    }
  }
  return count;
}
