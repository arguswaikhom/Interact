import 'dart:io';

import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final imagePath;

  const ImageView({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: imagePath,
      child: Image.file(
        File(imagePath),
        fit: BoxFit.contain,
      ),
    );
  }
}
