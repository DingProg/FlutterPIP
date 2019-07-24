import 'dart:ui' as flutterUi;

import 'UIImageLoader.dart';

/// 单例模式持有原图,切换效果，不在次加载原图
class OriginImage {
  String _url;
  flutterUi.Image _image;

  OriginImage._();

  static OriginImage _instance;

  static OriginImage getInstance() {
    if (_instance == null) {
      _instance = OriginImage._();
    }
    return _instance;
  }

  /// 如果内存已经有，就不在decode
  Future<flutterUi.Image> loadImage(String url) {
    if (_url != null && _url.endsWith(url) && _image != null) {
      return Future.value(_image);
    }

    _url = url;
    return ImageLoader.load(url).then((getImage) {
      return ImageLoader.clipImage1to1(getImage).then((clipImage) {
        _image = clipImage;
        return _image;
      });
    });
  }

  /// 销毁原图片
  void destroy() {
    _image = null;
    _url = null;
  }
}
