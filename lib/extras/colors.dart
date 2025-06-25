import 'package:flutter/material.dart';

const MaterialColor primary = MaterialColor(_primaryPrimaryValue, <int, Color>{
  50: Color(0xFFFEF9EE),
  100: Color(0xFFFCF1D4),
  200: Color(0xFFFAE8B7),
  300: Color(0xFFF7DE9A),
  400: Color(0xFFF6D785),
  500: Color(_primaryPrimaryValue),
  600: Color(0xFFF3CB67),
  700: Color(0xFFF1C45C),
  800: Color(0xFFEFBE52),
  900: Color(0xFFECB340),
});
const int _primaryPrimaryValue = 0xFFF4D06F;

const MaterialColor primaryAccent =
    MaterialColor(_primaryAccentValue, <int, Color>{
  100: Color(0xFFFFFFFF),
  200: Color(_primaryAccentValue),
  400: Color(0xFFFFF1D5),
  700: Color(0xFFFFE8BC),
});
const int _primaryAccentValue = 0xFFFFFFFF;
