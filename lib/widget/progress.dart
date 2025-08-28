
import 'package:flutter/material.dart';

import '../utils/my_colors.dart';
class ProgressStatic {

  static Widget getFlatProgressAccent(int value, double height){
    int rest = 100 - value;
    return Stack(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 100,
              child: Container(height: height, color: MyColors.accentLight,),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: value,
              child: Container(width: 200, height: 20, color: MyColors.accent,),
            ),
            Expanded(
              flex: rest,
              child: Container(),
            ),
          ],
        )
      ],
    );
  }
}