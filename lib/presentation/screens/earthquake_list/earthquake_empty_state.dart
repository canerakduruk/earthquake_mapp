import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EarthquakeEmptyState extends StatelessWidget {
  const EarthquakeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(Icons.info_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'no_earthquake_data'.tr(),
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'no_data_for_search'.tr(),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
