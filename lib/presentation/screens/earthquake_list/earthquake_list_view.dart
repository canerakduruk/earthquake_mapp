import 'package:earthquake_mapp/presentation/widgets/earthquake_card.dart';
import 'package:earthquake_mapp/presentation/widgets/earthquake_card_shimmer.dart';
import 'package:flutter/material.dart';

class EarthquakeListView extends StatelessWidget {
  final List earthquakes;
  final void Function(dynamic earthquake) onTap;
  final bool isLoading;

  const EarthquakeListView({
    super.key,
    required this.earthquakes,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) => const EarthquakeCardShimmer(),
      );
    }

    return ListView.builder(
      itemCount: earthquakes.length,
      itemBuilder: (context, index) {
        final earthquake = earthquakes[index];
        return EarthquakeCard(
          earthquake: earthquake,
          onTap: () => onTap(earthquake),
        );
      },
    );
  }
}
