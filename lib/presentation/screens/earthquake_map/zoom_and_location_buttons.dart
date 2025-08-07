import 'package:flutter/material.dart';

class ZoomAndLocationButtons extends StatelessWidget {
  final VoidCallback onCenter;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const ZoomAndLocationButtons({
    super.key,
    required this.onCenter,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          mini: true,
          heroTag: "centerMap",
          onPressed: onCenter,
          child: const Icon(Icons.my_location),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          mini: true,
          heroTag: "zoomIn",
          onPressed: onZoomIn,
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          mini: true,
          heroTag: "zoomOut",

          onPressed: onZoomOut,
          child: const Icon(Icons.remove),
        ),
      ],
    );
  }
}
