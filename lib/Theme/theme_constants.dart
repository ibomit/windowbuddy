import 'package:flutter/material.dart';

const COLOR_PRIMARY = Colors.deepOrangeAccent;

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: COLOR_PRIMARY,
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.orangeAccent),
  textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: COLOR_PRIMARY,
  colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark)
      .copyWith(secondary: Colors.orangeAccent),
  textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
);
class ThemeConstants {
  static const Color darkPrimaryColor = Colors.black; // Replace with your dark mode primary color
  static const Color lightPrimaryColor = Colors.blue; // Replace with your light mode primary color
  static const Color darkButtonColor = Colors.teal; // Replace with your dark mode button color
  static const Color lightButtonColor = Colors.green; // Replace with your light mode button color
}