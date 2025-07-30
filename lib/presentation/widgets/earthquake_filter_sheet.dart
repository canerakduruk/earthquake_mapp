import 'package:flutter/material.dart';
import '../../data/services/earthquake_service.dart';
import '../../core/enums/earthquake_enums.dart';
import '../../core/utils/date_helper.dart';

class EarthquakeFilterSheet extends StatefulWidget {
  final ScrollController scrollController;
  final Function(EarthquakeFilterParams) onApplyFilter;

  const EarthquakeFilterSheet({
    super.key,
    required this.scrollController,
    required this.onApplyFilter,
  });

  @override
  State<EarthquakeFilterSheet> createState() => _EarthquakeFilterSheetState();
}

class _EarthquakeFilterSheetState extends State<EarthquakeFilterSheet> {
  DateTime selectedDate = DateHelper.getDefaultEndDate();
  double? minMagnitude;
  OrderBy orderBy = OrderBy.timeDesc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView(
        controller: widget.scrollController,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Deprem Filtresi',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Tarih'),
          const SizedBox(height: 12),
          _buildDateField(
            'Tarih Seç',
            selectedDate,
            (date) => setState(() => selectedDate = date),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Büyüklük'),
          const SizedBox(height: 12),
          _buildNumberField(
            'Min Büyüklük',
            minMagnitude,
            (value) => setState(() => minMagnitude = value),
            min: 0.0,
            max: 10.0,
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Sıralama'),
          const SizedBox(height: 12),
          _buildDropdownField<OrderBy>(
            'Sıralama',
            orderBy,
            OrderBy.values,
            (value) => setState(() => orderBy = value ?? OrderBy.timeDesc),
            (order) => _getOrderByDisplayName(order),
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  child: const Text('Sıfırla'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Uygula'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime date,
    Function(DateTime) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(1999, 1, 1),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(DateHelper.formatDateForDisplay(date)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(
    String label,
    double? value,
    Function(double?) onChanged, {
    double? min,
    double? max,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value?.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            hintText: 'Değer girin',
          ),
          onChanged: (text) {
            if (text.isEmpty) {
              onChanged(null);
            } else {
              final parsedValue = double.tryParse(text);
              if (parsedValue != null) {
                if (min != null && parsedValue < min) return;
                if (max != null && parsedValue > max) return;
                onChanged(parsedValue);
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>(
    String label,
    T? value,
    List<T> items,
    Function(T?) onChanged,
    String Function(T) getDisplayName,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(getDisplayName(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _getOrderByDisplayName(OrderBy order) {
    switch (order) {
      case OrderBy.time:
        return 'Zamana göre (Artan)';
      case OrderBy.timeDesc:
        return 'Zamana göre (Azalan)';
      case OrderBy.magnitude:
        return 'Büyüklüğe göre (Artan)';
      case OrderBy.magnitudeDesc:
        return 'Büyüklüğe göre (Azalan)';
    }
  }

  void _resetFilters() {
    setState(() {
      selectedDate = DateHelper.getDefaultEndDate();
      minMagnitude = null;
      orderBy = OrderBy.timeDesc;
    });
  }

  void _applyFilters() {
    final startDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      0,
      0,
      0,
    );

    final endDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );

    final params = EarthquakeFilterParams(
      startDate: startDate,
      endDate: endDate,
      minMagnitude: minMagnitude,
      maxMagnitude: null,
      magnitudeType: null,
      minDepth: null,
      maxDepth: null,
      limit: null,
      orderBy: orderBy,
    );

    widget.onApplyFilter(params);
  }
}
