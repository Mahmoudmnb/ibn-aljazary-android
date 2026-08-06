import 'package:flutter/material.dart';

class ProgressBarItem {
  final double maxValue;
  final double value;
  final Color progressColor;
  final Color lastColor;
  final String rightText;
  final String lefText;
  final double width;
  final double height;

  ProgressBarItem({
    required this.maxValue,
    required this.value,
    required this.progressColor,
    required this.lastColor,
    required this.rightText,
    required this.lefText,
    required this.width,
    required this.height,
  });
}
