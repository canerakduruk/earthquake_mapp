import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:earthquake_mapp/core/utils/date_helper.dart';

class EarthquakeDetailModal extends StatelessWidget {
  final dynamic earthquake;

  const EarthquakeDetailModal({super.key, required this.earthquake});

  Widget _buildDetailTile(IconData icon, String labelKey, String value) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: Colors.grey[700]),
          title: Text(
            labelKey.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(value),
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'earthquake_details'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailTile(
              Icons.speed,
              'magnitude',
              earthquake.magnitudeDisplay ?? '',
            ),
            _buildDetailTile(
              Icons.access_time,
              'date',
              DateHelper.formatDateTimeForDisplay(earthquake.dateTime),
            ),
            _buildDetailTile(
              Icons.location_on,
              'location',
              earthquake.location ?? '',
            ),
            _buildDetailTile(
              Icons.map,
              'coordinates',
              earthquake.coordinatesDisplay ?? '',
            ),
            _buildDetailTile(
              Icons.vertical_align_bottom,
              'depth',
              earthquake.depthDisplay ?? '',
            ),
            if (earthquake.province != null)
              _buildDetailTile(
                Icons.location_city,
                'province',
                earthquake.province!,
              ),
            if (earthquake.district != null)
              _buildDetailTile(
                Icons.apartment,
                'district',
                earthquake.district!,
              ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: Text('close'.tr()),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
