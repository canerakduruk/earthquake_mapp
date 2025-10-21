import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData iconData;
  final String labelText;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.iconData,
    required this.labelText,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle? baseStyle = Theme.of(context).elevatedButtonTheme.style;

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: baseStyle?.copyWith(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        minimumSize: WidgetStateProperty.all<Size>(Size(double.infinity, 56)),
      ),
      icon: isLoading
          ? Container(
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(2.0),
              child: CircularProgressIndicator(
                color: baseStyle?.foregroundColor?.resolve({}) ?? Colors.white,
                strokeWidth: 3,
              ),
            )
          : FaIcon(iconData, size: 18),
      label: Text(labelText),
    );
  }
}
