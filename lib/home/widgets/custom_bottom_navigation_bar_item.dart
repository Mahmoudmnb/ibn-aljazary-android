import 'package:flutter/material.dart';

class CustomBottomNavigationBarItem {
  final IconData icon;
  final Future<bool> Function() onTap;
  const CustomBottomNavigationBarItem({
    required this.onTap,
    required this.icon,
  });
}
