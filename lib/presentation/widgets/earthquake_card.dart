import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/earthquake_entity.dart';
import '../../core/utils/date_helper.dart';

class EarthquakeCard extends StatelessWidget {
  final EarthquakeEntity earthquake;
  final VoidCallback? onTap;

  const EarthquakeCard({super.key, required this.earthquake, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Tema moduna göre arka plan rengini seç
    final Color cardBackgroundColor = theme.brightness == Brightness.light
        ? Colors
              .white38 // Açık modda hafif transparan beyaz
        : Colors.grey.shade900; // Koyu modda koyu gri

    // Yazı ve ikon renkleri temaya göre uyumlu
    final Color textAndIconColor = theme.brightness == Brightness.light
        ? Colors.black! // Açık modda koyu gri
        : Colors.grey[300]!; // Koyu modda açık gri

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.brightness == Brightness.light
                  ? Colors.grey.shade300
                  : Colors.grey.shade700,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildMagnitudeChip(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      earthquake.location ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textAndIconColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: textAndIconColor),
                  const SizedBox(width: 4),
                  Text(
                    DateHelper.formatDateTimeForDisplay(earthquake.dateTime),
                    style: TextStyle(color: textAndIconColor, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.vertical_align_bottom,
                      'depth'.tr(),
                      earthquake.depthDisplay,
                      textAndIconColor,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.place,
                      'coordinates'.tr(),
                      earthquake.coordinatesDisplay,
                      textAndIconColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMagnitudeChip() {
    Color backgroundColor = earthquake.magnitudeColor;
    Color textColor = Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        earthquake.magnitudeDisplay,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: color)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
