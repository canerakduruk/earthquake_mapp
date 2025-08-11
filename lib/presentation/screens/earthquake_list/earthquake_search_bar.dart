import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EarthquakeSearchBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const EarthquakeSearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    // Tema uyumlu renkler
    final backgroundColor = isLight ? Colors.white : Colors.grey[800];
    final iconColor = isLight ? Colors.grey[600] : Colors.grey[300];
    final textColor = isLight ? Colors.black87 : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: TextField(
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: 'search_location'.tr(),
          hintStyle: TextStyle(color: iconColor),
          filled: true,
          fillColor: backgroundColor,
          prefixIcon: Icon(Icons.search, color: iconColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
}
