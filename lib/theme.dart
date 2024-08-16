import 'package:flutter/material.dart';
import 'package:vup_chat/constants.dart';

ThemeData getLightTheme() {
  return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: defaultAccentColor,
      scaffoldBackgroundColor: lightBackgroundColor,
      cardColor: lightCardColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: darkBackgroungColor),
        bodyMedium: TextStyle(color: darkBackgroungColor),
      ),
      colorScheme: const ColorScheme.light(
        primary: defaultAccentColor,
        surface: lightCardColor,
        onSurface: Colors.black,
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.grey.withOpacity(.5),
      ));
}

ThemeData getDarkTheme() {
  return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: defaultAccentColor,
      scaffoldBackgroundColor: darkBackgroungColor,
      cardColor: darkCardColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: darkTextColor),
        bodyMedium: TextStyle(color: darkTextColor),
      ),
      colorScheme: const ColorScheme.dark(
        primary: defaultAccentColor,
        surface: darkCardColor,
        onSurface: darkTextColor,
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.grey.withOpacity(.5),
      ));
}
