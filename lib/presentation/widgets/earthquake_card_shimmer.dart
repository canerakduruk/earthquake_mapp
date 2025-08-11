import 'package:flutter/material.dart';
import 'package:fade_shimmer/fade_shimmer.dart';

class EarthquakeCardShimmer extends StatelessWidget {
  const EarthquakeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? Colors.grey.shade900 : Colors.white38;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final boxColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final fadeTheme = isDark ? FadeTheme.dark : FadeTheme.light;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FadeShimmer.round(size: 32, fadeTheme: fadeTheme),
                const SizedBox(width: 12),
                Expanded(
                  child: FadeShimmer(
                    height: 16,
                    width: double.infinity,
                    radius: 4,
                    fadeTheme: fadeTheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: FadeShimmer(
                    height: 14,
                    width: double.infinity,
                    radius: 4,
                    fadeTheme: fadeTheme,
                    millisecondsDelay: 100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildInfoShimmer(fadeTheme, boxColor)),
                Expanded(
                  child: _buildInfoShimmer(fadeTheme, boxColor, delay: 200),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoShimmer(
    FadeTheme fadeTheme,
    Color boxColor, {
    int delay = 0,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeShimmer(
                height: 12,
                width: 50,
                radius: 4,
                fadeTheme: fadeTheme,
                millisecondsDelay: delay,
              ),
              const SizedBox(height: 4),
              FadeShimmer(
                height: 14,
                width: double.infinity,
                radius: 4,
                fadeTheme: fadeTheme,
                millisecondsDelay: delay + 100,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
