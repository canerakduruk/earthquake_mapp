import 'package:earthquake_mapp/core/enums/earthquake_enums.dart';
import 'package:earthquake_mapp/core/utils/date_helper.dart';
import 'package:earthquake_mapp/data/models/new_earthquake_model/earthquake_model.dart';
import 'package:earthquake_mapp/data/params/earthquake_params.dart';
import 'package:earthquake_mapp/features/providers/earthquake_provider.dart';
import 'package:earthquake_mapp/shared/widgets/item/earthquake_card.dart';
import 'package:earthquake_mapp/shared/widgets/loading/earthquake_card_shimmer.dart';
import 'package:earthquake_mapp/shared/widgets/loading/loading_widget.dart';
import 'package:earthquake_mapp/shared/widgets/modal/earthquake_detail_modal.dart';
import 'package:earthquake_mapp/shared/widgets/view/earthquake_list/earthquake_filter_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';

class EarthquakeListScreen extends ConsumerStatefulWidget {
  const EarthquakeListScreen({super.key});

  @override
  ConsumerState<EarthquakeListScreen> createState() =>
      _EarthquakeListScreenState();
}

class _EarthquakeListScreenState extends ConsumerState<EarthquakeListScreen> {
  String _searchQuery = '';
  final Logger _logger = Logger(); // Logger'ı state içinde tanımla

  @override
  void initState() {
    super.initState();
    // 'ref.watch' bunu 'build' metodunda otomatik olarak halledecek.
  }

  // Helper fonksiyonları 'build' dışına taşıyarak daha temiz hale getirelim
  bool _logAndCheckNull(String name, Object? value) {
    _logger.i("$name: ${value ?? 'null'}");
    return value == null;
  }

  bool _isSameDateTime(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

  bool _isDefaultFilter(EarthquakeParams filter) {
    final defaultStart = DateHelper.getDefaultStartDate();
    final defaultEnd = DateHelper.getDefaultEndDate();

    _logger.i("startDate: ${filter.startDate} | default: $defaultStart");
    _logger.i("endDate: ${filter.endDate} | default: $defaultEnd");

    final noOtherFilters =
        _logAndCheckNull('minLat', filter.minLat) &&
            _logAndCheckNull('maxLat', filter.maxLat) &&
            _logAndCheckNull('minLon', filter.minLon) &&
            _logAndCheckNull('maxLon', filter.maxLon) &&
            _logAndCheckNull('centerLat', filter.centerLat) &&
            _logAndCheckNull('centerLon', filter.centerLon) &&
            _logAndCheckNull('maxRadius', filter.maxRadius) &&
            _logAndCheckNull('minRadius', filter.minRadius) &&
            _logAndCheckNull('magnitudeType', filter.magnitudeType) &&
            _logAndCheckNull('minDepth', filter.minDepth) &&
            _logAndCheckNull('maxDepth', filter.maxDepth) &&
            _logAndCheckNull('limit', filter.limit) &&
            _logAndCheckNull('offset', filter.offset) &&
            _logAndCheckNull('eventId', filter.eventId);

    final result =
        _isSameDateTime(filter.startDate, defaultStart) &&
            _isSameDateTime(filter.endDate, defaultEnd) &&
            (filter.minMagnitude == 0.0 || filter.minMagnitude == null) &&
            filter.orderBy == OrderBy.timeDesc &&
            noOtherFilters;

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final currentFilter = ref.watch(earthquakeFilterProvider);
    final asyncEarthquakes = ref.watch(earthquakeProvider(currentFilter));

    return Scaffold(
      appBar: AppBar(
        title: Text('earthquake_tracking'.tr()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search_location'.tr(),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.filter),
            tooltip: 'filter'.tr(),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
            tooltip: 'refresh'.tr(),
            onPressed: () {
              // YENİ YÖNTEM: Yenilemek için 'invalidate' kullanılır
              ref.invalidate(earthquakeProvider(currentFilter));
            },
          ),
        ],
      ),
      // 3. 'body' artık 'AsyncValue.when()' ile çizilir
      body: asyncEarthquakes.when(
        // İlk yükleme
        loading: () => LoadingWidget(message: 'loading_earthquake_data'.tr()),

        // Hata durumu
        error: (error, stack) =>
            _buildErrorWidget(error.toString(), currentFilter),

        // Veri başarıyla geldiğinde
        data: (earthquakes) {
          // Arama filtresi (location, province, district üzerinde)
          final filteredEarthquakes = earthquakes.where((e) {
            final q = _searchQuery.toLowerCase();
            return e.location.toLowerCase().contains(q) ||
                e.province.toLowerCase().contains(q) ||
                e.district.toLowerCase().contains(q);
          }).toList();

          if (filteredEarthquakes.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              // YENİ YÖNTEM: 'invalidate'
              ref.invalidate(earthquakeProvider(currentFilter));
            },
            child: Column(
              children: [
                if (!_isDefaultFilter(currentFilter))
                  _buildFilterInfo(currentFilter),

                // Yenileme sırasında (eski veri varken) Shimmer göster
                if (asyncEarthquakes.isRefreshing)
                  Expanded(
                    child: ListView.builder(
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return const EarthquakeCardShimmer();
                      },
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredEarthquakes.length,
                      itemBuilder: (context, index) {
                        final earthquake = filteredEarthquakes[index];
                        return EarthquakeCard(
                          earthquake: earthquake,
                          onTap: () => _showEarthquakeDetail(earthquake),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error, EarthquakeParams currentFilter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'error_occurred'.tr(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // YENİ YÖNTEM:
              ref.invalidate(earthquakeProvider(currentFilter));
            },
            child: Text('try_again'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(Icons.info_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'no_earthquake_data'.tr(),
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'no_data_for_search'.tr(),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterInfo(EarthquakeParams filter) {
    List<String> descriptions = [];

    if (filter.minMagnitude != null && filter.minMagnitude != 0.0) {
      final min = filter.minMagnitude?.toString() ?? '';
      descriptions.add('magnitude_filter'.tr(namedArgs: {'min': min}));
    }

    if (filter.startDate != DateHelper.getDefaultStartDate()) {
      final formattedDate = DateHelper.formatDateForDisplay(filter.startDate);
      descriptions.add('selected_date'.tr(namedArgs: {'date': formattedDate}));
    }

    if (filter.orderBy != OrderBy.timeDesc) {
      switch (filter.orderBy) {
        case OrderBy.time:
          descriptions.add('order_time_asc'.tr());
          break;
        case OrderBy.timeDesc:
          descriptions.add('order_time_desc'.tr());
          break;
        case OrderBy.magnitude:
          descriptions.add('order_magnitude_asc'.tr());
          break;
        case OrderBy.magnitudeDesc:
          descriptions.add('order_magnitude_desc'.tr());
          break;
      }
    }


    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          FaIcon(FontAwesomeIcons.filter, color: Colors.blue[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              descriptions.isEmpty ? "Filtreler Aktif" : descriptions.join('\n'),
              style: TextStyle(color: Colors.blue[700], fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.invalidate(earthquakeFilterProvider);
            },
            child: FaIcon(
              FontAwesomeIcons.xmark,
              color: Colors.blue[700],
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    final currentFilter = ref.read(earthquakeFilterProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return EarthquakeFilterSheet(
          scrollController: ScrollController(),
          initialParams: currentFilter,
          onApplyFilter: (params) {
            ref.read(earthquakeFilterProvider.notifier).state = params;
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showEarthquakeDetail(EarthquakeModel earthquake) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => EarthquakeDetailModal(earthquake: earthquake),
    );
  }

}