import 'package:earthquake_mapp/presentation/widgets/earthquake_card_shimmer.dart';
import 'package:flutter/material.dart';

class EarthquakeCardShimmerList extends StatelessWidget {
  const EarthquakeCardShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8, // kaç tane shimmer kart göstermek istersen
      itemBuilder: (context, index) => const EarthquakeCardShimmer(),
    );
  }
}
