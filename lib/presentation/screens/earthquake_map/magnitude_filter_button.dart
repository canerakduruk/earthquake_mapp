import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MagnitudeFilterButton extends StatelessWidget {
  final void Function(int?) onSelected;

  const MagnitudeFilterButton({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Büyüklük Seçenekleri',
      onSelected: onSelected,
      itemBuilder: (context) => const [
        PopupMenuItem(value: 8, child: Text('8 üstü')),
        PopupMenuItem(value: 5, child: Text('5 üstü')),
        PopupMenuItem(value: 3, child: Text('3 üstü')),
        PopupMenuItem(value: 0, child: Text('Hepsi')),
      ],
      icon: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(150),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: const FaIcon(
          FontAwesomeIcons.ellipsisVertical,
          color: Colors.black87,
        ),
      ),
    );
  }
}
