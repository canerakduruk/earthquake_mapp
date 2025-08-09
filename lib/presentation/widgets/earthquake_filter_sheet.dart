import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../data/services/earthquake_service.dart';
import '../../core/enums/earthquake_enums.dart';
import '../../core/utils/date_helper.dart';

class EarthquakeFilterSheet extends StatefulWidget {
  final ScrollController scrollController;
  final Function(EarthquakeFilterParams) onApplyFilter;

  final EarthquakeFilterParams? initialParams;

  const EarthquakeFilterSheet({
    super.key,
    required this.scrollController,
    required this.onApplyFilter,
    this.initialParams,
  });

  @override
  State<EarthquakeFilterSheet> createState() => _EarthquakeFilterSheetState();
}

class _EarthquakeFilterSheetState extends State<EarthquakeFilterSheet> {
  DateTime selectedDate = DateHelper.getDefaultStartDate();
  double? minMagnitude;
  OrderBy orderBy = OrderBy.timeDesc;

  @override
  void initState() {
    super.initState();

    final p = widget.initialParams;
    selectedDate = p?.startDate ?? DateHelper.getDefaultStartDate();
    minMagnitude = p?.minMagnitude;
    orderBy = p?.orderBy ?? OrderBy.timeDesc;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView(
        controller: widget.scrollController,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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

          Text(
            'earthquake_filter'.tr(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('date'.tr()),
          const SizedBox(height: 12),
          _buildDateField(
            'select_date'.tr(),
            selectedDate,
            (date) => setState(() => selectedDate = date),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('magnitude'.tr()),
          const SizedBox(height: 12),
          _buildNumberField(
            'min_magnitude'.tr(),
            minMagnitude,
            (value) => setState(() => minMagnitude = value),
            min: 0.0,
            max: 10.0,
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('order_by'.tr()),
          const SizedBox(height: 12),
          _buildOrderBySelector(orderBy),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  child: Text('reset'.tr()),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: Text('apply'.tr()),
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
              helpText: 'select_date'.tr(), // Tarih seçici başlığı da çevrildi
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

  // Diğer methodlarda da sabit metinler çevrilmeli:

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
            hintText: 'enter_value'.tr(), // Değer girin -> çeviri anahtarı
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

  Widget _buildOrderBySelector(OrderBy currentOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'order_by'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showOrderByModal(currentOrder),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_getOrderByDisplayName(currentOrder)),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showOrderByModal(OrderBy selected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'select_order'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...OrderBy.values.map((order) {
                return RadioListTile<OrderBy>(
                  title: Text(_getOrderByDisplayName(order)),
                  value: order,
                  groupValue: selected,
                  onChanged: (value) {
                    setState(() {
                      orderBy = value!;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _getOrderByDisplayName(OrderBy order) {
    switch (order) {
      case OrderBy.time:
        return 'order_time_asc'.tr();
      case OrderBy.timeDesc:
        return 'order_time_desc'.tr();
      case OrderBy.magnitude:
        return 'order_magnitude_asc'.tr();
      case OrderBy.magnitudeDesc:
        return 'order_magnitude_desc'.tr();
    }
  }

  void _resetFilters() {
    setState(() {
      selectedDate = DateHelper.getDefaultStartDate();
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
