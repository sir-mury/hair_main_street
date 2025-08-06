import 'package:flutter/material.dart';

class Responsive {
  static const double mobileWidth = 600;
  static const double tabletWidth = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileWidth;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobileWidth &&
        MediaQuery.of(context).size.width < tabletWidth;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletWidth;
  }
}
