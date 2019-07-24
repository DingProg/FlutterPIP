import 'dart:ui' as flutterUi;

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DrawPIPWidget extends StatefulWidget {
  flutterUi.Image _originImage;
  flutterUi.Image _image;

  DrawPIPWidget(this._originImage, this._image);

  @override
  State<StatefulWidget> createState() {
    return new DrawPIPState();
  }
}

class DrawPIPState extends State<DrawPIPWidget> {
  double _width;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _width =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.width;
    return new Container(
        width: _width,
        height: _width,
        child: new Stack(
          children: <Widget>[
            getBackgroundImage(), //底部高斯模糊图片
            //合成后的效果图片，使用CustomPaint 绘制出来
            CustomPaint(
                painter: DrawPainter(widget._image),
                size: Size(_width, _width)),
          ],
        ));
  }

  Widget getBackgroundImage() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
            alignment: Alignment.topLeft,
            child: CustomPaint(
                painter: DrawPainter(widget._originImage),
                size: Size(_width, _width))),
        Center(
          child: ClipRect(
            child: BackdropFilter(
              filter: flutterUi.ImageFilter.blur(
                sigmaX: 5.0,
                sigmaY: 5.0,
              ),
              child: Container(
                alignment: Alignment.topLeft,
                color: Colors.white.withOpacity(0.1),
                width: _width,
                height: _width,
//                child: Text('  '),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DrawPainter extends CustomPainter {
  DrawPainter(this._image);

  flutterUi.Image _image;
  Paint _paint = new Paint();

  @override
  void paint(Canvas canvas, Size size) {
    if (_image != null) {
      print("draw this Image");
      print("width =" + size.width.toString());
      print("height =" + size.height.toString());

      canvas.drawImageRect(
          _image,
          Rect.fromLTWH(
              0, 0, _image.width.toDouble(), _image.height.toDouble()),
          Rect.fromLTWH(0, 0, size.width, size.height),
          _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
