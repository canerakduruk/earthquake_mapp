import 'package:earthquake_mapp/core/enums/earthquake_enums.dart';
import 'package:earthquake_mapp/core/utils/date_helper.dart';
import 'package:earthquake_mapp/data/services/earthquake_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EarthquakeFilterInfo extends StatelessWidget {
  final EarthquakeFilterParams filter;
  final VoidCallback onClearFilter;

  const EarthquakeFilterInfo({
    super.key,
    required this.filter,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    List<String> descriptions = [];

    if (filter.minMagnitude != null && filter.minMagnitude != 0.0) {
      final min = filter.minMagnitude?.toString() ?? '';
      descriptions.add('magnitude_filter'.tr(namedArgs: {'min': min}));
    }

    if (filter.startDate != DateHelper.getDefaultStartDate()) {
      final formattedDate = DateHelper.formatDateForDisplay(filter.startDate);
      descriptions.add('selected_date'.tr(namedArgs: {'date': formattedDate}));
    }

    if (filter.orderBy != OrderBy.timeDesc) {
      switch (filter.orderBy) {
        case OrderBy.time:
          descriptions.add('order_time_asc'.tr());
          break;
        case OrderBy.timeDesc:
          descriptions.add('order_time_desc'.tr());
          break;
        case OrderBy.magnitude:
          descriptions.add('order_magnitude_asc'.tr());
          break;
        case OrderBy.magnitudeDesc:
          descriptions.add('order_magnitude_desc'.tr());
          break;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          FaIcon(FontAwesomeIcons.filter, color: Colors.blue[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              descriptions.join('\n'),
              style: TextStyle(color: Colors.blue[700], fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: onClearFilter,
            child: FaIcon(
              FontAwesomeIcons.xmark,
              color: Colors.blue[700],
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
