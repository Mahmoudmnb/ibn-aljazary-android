import 'package:flutter/material.dart';

class CustomListItem {
  final String text;
  final Function() onTap;
  final Color backgroundColor;
  final Color textColor;
  final BorderRadius borderRadius;
  CustomListItem({
    required this.borderRadius,
    required this.onTap,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });
}
