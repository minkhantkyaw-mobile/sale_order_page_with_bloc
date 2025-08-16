import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget page;

  const NavigationButton({
    super.key,
    required this.icon,
    required this.label,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => Get.to(() => page),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
