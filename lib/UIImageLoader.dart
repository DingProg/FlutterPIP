import 'dart:async';
import 'dart:ui' as flutterUi;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageLoader {
  static AssetBundle getAssetBundle() => (rootBundle != null)
      ? rootBundle
      : new NetworkAssetBundle(new Uri.directory(Uri.base.origin));

  static Future<flutterUi.Image> load(String url) async {
    ImageStream stream = new AssetImage(url, bundle: getAssetBundle())
        .resolve(ImageConfiguration.empty);
    Completer<flutterUi.Image> completer = new Completer<flutterUi.Image>();
    void listener(ImageInfo frame, bool synchronousCall) {
      final flutterUi.Image image = frame.image;
      completer.complete(image);
      stream.removeListener(new ImageStreamListener(listener));
    }

    stream.addListener(new ImageStreamListener(listener));
    return completer.future;
  }

  /// 裁剪为 1:1 的图
  static Future<flutterUi.Image> clipImage1to1(flutterUi.Image image) {
    PictureRecorder recorder = PictureRecorder();
    Paint paint = new Paint();
    Canvas canvas = Canvas(recorder);
    int sizeBord = image.width > image.height ? image.height : image.width;
    bool widthMore = image.width > image.height;
    canvas.drawImageRect(
        image,
        Rect.fromLTWH(
            widthMore ? (image.width - sizeBord) / 2 : 0,
            widthMore ? 0 : (image.height - sizeBord) / 2,
            sizeBord.toDouble(),
            sizeBord.toDouble()),
        Rect.fromLTWH(0, 0, sizeBord.toDouble(), sizeBord.toDouble()),
        paint);

    return recorder.endRecording().toImage(sizeBord, sizeBord);
  }
}
