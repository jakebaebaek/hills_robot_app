import 'package:flutter/material.dart';
import 'dart:developer';


void callback(displaySize, physicalSize, height, width, pixelRatio, paddingTop) {
  log('$displaySize $physicalSize $height $width $pixelRatio $paddingTop');
}

class DeviceInfo{
  final BuildContext context;
  DeviceInfo({
    required this.context,
    }
  );

  late final Size _displaySize = MediaQuery.of(context).size;
  late final Size _physicalSize = View.of(context).physicalSize;
  late final double _height = MediaQuery.of(context).size.height;
  late final double _width = MediaQuery.of(context).size.width;
  late final double _pixelRatio = MediaQuery.of(context).devicePixelRatio;
  late final double _paddingTop = MediaQuery.of(context).padding.top;
  
  Size get displaySize => _displaySize;
  Size get physicalSize => _physicalSize;
  double get height => _height;
  double get width => _width;
  double get pixelRatio => _pixelRatio;
  double get paddingTop => _paddingTop;
}