import 'package:flutter/material.dart';

class CircleImage extends StatelessWidget {

  final double? size;
  final Color? backgroundColor;
  final ImageProvider imageProvider;

  const CircleImage({
    Key? key,
    required this.imageProvider,
    this.size,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    return Container(
      padding: EdgeInsets.zero,
        width: size ?? 60,
        height: size ?? 60,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
           color: backgroundColor ?? Colors.transparent,
            image: DecorationImage(
                fit: BoxFit.fill,
                image: imageProvider
            )
        )
    );
  }
}
