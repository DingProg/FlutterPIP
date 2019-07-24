import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as flutterUi;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import 'Config.dart';
import 'DrawImageUtils.dart';
import 'DrawPIPWidget.dart';
import 'OriginImage.dart';

class ShowImagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new PreviewImageWidget();
  }
}

class PreviewImageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new PreviewImageState();
  }
}

class PreviewImageState extends State<PreviewImageWidget> {
  final GlobalKey pipCaptureKey = new GlobalKey();

  List<String> _listImageIcon = [];
  List<Offset> _imageOffset = [];

  int currentIndex = 0;
  flutterUi.Image _originImage;
  flutterUi.Image _image;

  @override
  void initState() {
    super.initState();
    _listImageIcon = Config.getImageListIcon();
    _imageOffset = Config.getOffsetList();
    reLoadRes();
  }

  @override
  void dispose() {
    super.dispose();
    OriginImage.getInstance().destroy();
  }

  void reLoadRes() {
//    String originImageUrl = "images/test.jpg";
    String originImageUrl = "images/test1.jpeg";
    Future.wait([
      DrawImageUtils.drawMaskImage(
          originImageUrl,
          "images/" + (currentIndex + 1).toString() + "/frame.png",
          "images/" + (currentIndex + 1).toString() + "/mask.png",
          _imageOffset[currentIndex]),
      OriginImage.getInstance().loadImage(originImageUrl)
    ]).then((results) {
      _originImage = results[1];
      _image = results[0];
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("PIP"),
        ),
        body: new SafeArea(
            child: new Container(
                child: new Column(children: <Widget>[
          new Expanded(child: getPIPImageWidget()),
          getBottomListView()
        ]))),
        floatingActionButton: FloatingActionButton(
          onPressed: _captureImage,
          tooltip: 'save',
          child: Icon(Icons.save),
        ));
  }

  Widget getPIPImageWidget() {
    return RepaintBoundary(
      key: pipCaptureKey,
      child: new Center(child: new DrawPIPWidget(_originImage, _image)),
    );
  }

  Widget getBottomListView() {
    ListView listView = ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _listImageIcon.length,
        itemBuilder: (context, index) {
          Widget imageWidget = new Container(
              margin: EdgeInsets.only(right: 8),
              width: 100,
              height: 118,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                      image: AssetImage(_listImageIcon[index]),
                      fit: BoxFit.fill)));

          Widget childWidget;
          if (currentIndex == index) {
            childWidget = new Container(
                child: new Stack(children: <Widget>[
              imageWidget,
              new Container(
                  width: 100,
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.orange),
                      borderRadius: BorderRadius.circular(10)))
            ]));
          } else {
            childWidget = imageWidget;
          }
          return GestureDetector(
              child: childWidget,
              onTap: () {
                setState(() {
                  currentIndex = index;
                });
                reLoadRes();
              });
        });

    return new Container(
        padding: EdgeInsets.all(20), height: 140, child: listView);
  }

  Future<void> _captureImage() async {
    RenderRepaintBoundary boundary =
        pipCaptureKey.currentContext.findRenderObject();
    var image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    getApplicationDocumentsDirectory().then((dir) {
      String path = dir.path + "/pip.png";
      new File(path).writeAsBytesSync(pngBytes);
      _showPathDialog(path);
    });
  }

  Future<void> _showPathDialog(String path) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('PIP Path'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Image is save in $path'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('退出'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
