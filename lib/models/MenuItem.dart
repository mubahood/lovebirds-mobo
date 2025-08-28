import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuItem {
  String title;
  Widget Img;
  // Function onTap;
  // MenuItem(this.title, this.Img, this.onTap);
  Color color;
  Function onTap;

  MenuItem(this.title, this.Img, this.color, this.onTap);

}


// FxContainer(
// color: CustomTheme.primary,
// borderRadiusAll: 0,
// padding: const EdgeInsets.symmetric(
// vertical: 5, horizontal: 10),
// child: FxText.bodySmall(
// Utils.to_date(item.created_at),
// fontWeight: 800,
// fontSize: 10,
// color: Colors.white,
// ),
// ),