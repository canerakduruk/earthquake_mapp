import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class MagnitudeFilterButton extends StatelessWidget {
  final void Function(int?) onSelected;

  const MagnitudeFilterButton({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'magnitude_filter_tools.tooltip'.tr(),
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 8,
          child: Text('magnitude_filter_tools.above_8'.tr()),
        ),
        PopupMenuItem(
          value: 5,
          child: Text('magnitude_filter_tools.above_5'.tr()),
        ),
        PopupMenuItem(
          value: 3,
          child: Text('magnitude_filter_tools.above_3'.tr()),
        ),
        PopupMenuItem(value: 0, child: Text('magnitude_filter_tools.all'.tr())),
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
