import 'package:flutter/material.dart';

class DeviceInfo {
  final BuildContext context;
  final double height;
  final double width;

  DeviceInfo(this.context)
      : height = MediaQuery.of(context).size.height,
        width = MediaQuery.of(context).size.width;
}
