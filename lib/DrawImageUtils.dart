import 'dart:async';
import 'dart:ui' as flutterUi;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'OriginImage.dart';
import 'UIImageLoader.dart';

class DrawImageUtils {
  /// 通过 frameImage 和 原图,绘制出 被裁剪的图形
  static Future<flutterUi.Image> drawFrameImage(
      String originImageUrl, String frameImageUrl) {
    Completer<flutterUi.Image> completer = new Completer<flutterUi.Image>();
    Future.wait([
      OriginImage.getInstance().loadImage(originImageUrl),
      ImageLoader.load(frameImageUrl)
    ]).then((result) {
      Paint paint = new Paint();
      PictureRecorder recorder = PictureRecorder();
      Canvas canvas = Canvas(recorder);

      int width = result[1].width;
      int height = result[1].height;

      //图片缩放至frame大小，并移动到中央
      double originWidth = 0.0;
      double originHeight = 0.0;
      if (width > height) {
        double scale = height / width.toDouble();
        originWidth = result[0].width.toDouble();
        originHeight = result[0].height.toDouble() * scale;
      } else {
        double scale = width / height.toDouble();
        originWidth = result[0].width.toDouble() * scale;
        originHeight = result[0].height.toDouble();
      }
      canvas.drawImageRect(
          result[0],
          Rect.fromLTWH(
              (result[0].width - originWidth) / 2.0,
              (result[0].height - originHeight) / 2.0,
              originWidth,
              originHeight),
          Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
          paint);
      paint.blendMode = BlendMode.dstIn;
      canvas.drawImage(result[1], Offset(0, 0), paint);
      recorder.endRecording().toImage(width, height).then((image) {
        completer.complete(image);
      });
    }).catchError((e) {
      print("加载error:" + e);
    });
    return completer.future;
  }

  /// mask 图形 和被裁剪的图形 合并
  static Future<flutterUi.Image> drawMaskImage(String originImageUrl,
      String frameImageUrl, String maskImage, Offset offset) {
    Completer<flutterUi.Image> completer = new Completer<flutterUi.Image>();
    Future.wait([
      ImageLoader.load(maskImage),
      drawFrameImage(originImageUrl, frameImageUrl)
    ]).then((result) {
      Paint paint = new Paint();
      PictureRecorder recorder = PictureRecorder();
      Canvas canvas = Canvas(recorder);

      int width = result[0].width;
      int height = result[0].height;

      canvas.drawImage(result[1], offset, paint);
      canvas.drawImageRect(
          result[0],
          Rect.fromLTWH(
              0, 0, result[0].width.toDouble(), result[0].height.toDouble()),
          Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
          paint);
      recorder.endRecording().toImage(width, height).then((image) {
        completer.complete(image);
      });
    }).catchError((e) {
      print("加载error:" + e);
    });
    return completer.future;
  }
}
