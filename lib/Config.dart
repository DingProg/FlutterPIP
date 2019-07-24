import 'dart:ui';

class Config {
  static List<String> getImageListIcon() {
    List<String> listImageIcon = [];
    for (int i = 0; i < 13; i++) {
      String imageUrl = "images/icon/" + (i + 1).toString() + ".jpg";
      listImageIcon.add(imageUrl);
    }
    return listImageIcon;
  }

  static List<Offset> getOffsetList() {
    List<Offset> offsetList = [
      Offset(61, 62), //1
      Offset(69, 42), //2
      Offset(50, 50), //3
      Offset(60, 120), //4
      Offset(130, 212), //5
      Offset(73, 125), //6
      Offset(317, 85), //7
      Offset(98, 48), //8
      Offset(52, 222), //9
      Offset(81, 79), //10
      Offset(109, 50), //11
      Offset(200, 85), //12
      Offset(249, 89), //13
    ];

    return offsetList;
  }
}
