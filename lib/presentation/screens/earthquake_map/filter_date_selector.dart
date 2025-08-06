import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final bool isOpen;
  final VoidCallback onTap;

  const FilterDateSelector({
    super.key,
    required this.selectedDate,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(200),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        constraints: const BoxConstraints(minWidth: 140, maxWidth: 180),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.black87),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                DateFormat.yMMMMd().format(selectedDate),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 20,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
