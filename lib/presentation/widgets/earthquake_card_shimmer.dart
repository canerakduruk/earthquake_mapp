import 'package:flutter/material.dart';
import 'package:fade_shimmer/fade_shimmer.dart';

class EarthquakeCardShimmer extends StatelessWidget {
  const EarthquakeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white38,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst satır: büyüklük chip'i + konum yazısı yer tutucu
            Row(
              children: [
                // Büyüklük chip'i için oval shimmer
                FadeShimmer.round(size: 32, fadeTheme: FadeTheme.light),
                const SizedBox(width: 12),
                // Konum için geniş dikdörtgen shimmer (width verildi!)
                Expanded(
                  child: FadeShimmer(
                    height: 16,
                    width: double.infinity,
                    radius: 4,
                    fadeTheme: FadeTheme.light,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tarih ve saat ikon + yazı
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: FadeShimmer(
                    height: 14,
                    width: double.infinity,
                    radius: 4,
                    fadeTheme: FadeTheme.light,
                    millisecondsDelay: 100,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // İki bilgi satırı: Derinlik ve Koordinat yer tutucuları
            Row(
              children: [
                Expanded(child: _buildInfoShimmer()),
                Expanded(child: _buildInfoShimmer(delay: 200)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoShimmer({int delay = 0}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
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
                fadeTheme: FadeTheme.light,
                millisecondsDelay: delay,
              ),
              const SizedBox(height: 4),
              FadeShimmer(
                height: 14,
                width: double.infinity,
                radius: 4,
                fadeTheme: FadeTheme.light,
                millisecondsDelay: delay + 100,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
