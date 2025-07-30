import 'package:flutter/material.dart';
import '../../domain/entities/earthquake_entity.dart';
import '../../core/utils/date_helper.dart';

class EarthquakeCard extends StatelessWidget {
  final EarthquakeEntity earthquake;
  final VoidCallback? onTap;

  const EarthquakeCard({super.key, required this.earthquake, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white38, // düz arka plan
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
            ), // opsiyonel ince kenarlık
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateHelper.formatDateForDisplay(earthquake.dateTime),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.vertical_align_bottom,
                      'Derinlik',
                      earthquake.depthDisplay,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.place,
                      'Konum',
                      earthquake.coordinatesDisplay,
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
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (earthquake.magnitudeColor) {
      case 'critical':
        backgroundColor = Colors.red[800]!;
        break;
      case 'high':
        backgroundColor = Colors.orange[700]!;
        break;
      case 'medium':
        backgroundColor = Colors.yellow[700]!;
        textColor = Colors.black;
        break;
      default:
        backgroundColor = Colors.green[600]!;
    }

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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
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
