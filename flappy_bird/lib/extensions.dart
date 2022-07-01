
import 'dart:ui';

import 'package:flutter/material.dart';

/// Enables scrolling with mouse in web
class AppScrollBehavior extends MaterialScrollBehavior {

  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}