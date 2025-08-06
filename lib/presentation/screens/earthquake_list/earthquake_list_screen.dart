import 'package:earthquake_mapp/core/enums/earthquake_enums.dart';
import 'package:earthquake_mapp/data/services/earthquake_service.dart';
import 'package:earthquake_mapp/presentation/viewmodels/earthquake_viewmodel.dart';
import 'package:earthquake_mapp/presentation/widgets/earthquake_card_shimmer.dart';
import 'package:earthquake_mapp/presentation/widgets/earthquake_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/earthquake_provider.dart';
import '../../widgets/earthquake_card.dart';
import '../../widgets/loading_widget.dart';
import '../../../core/utils/date_helper.dart';
import 'package:logger/logger.dart';

class EarthquakeListScreen extends ConsumerStatefulWidget {
  const EarthquakeListScreen({super.key});

  @override
  ConsumerState<EarthquakeListScreen> createState() =>
      _EarthquakeListScreenState();
}

class _EarthquakeListScreenState extends ConsumerState<EarthquakeListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(earthquakeListProvider.notifier).loadEarthquakes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final earthquakeState = ref.watch(earthquakeListProvider);

    // Arama filtresi uygulama (location, province, district üzerinde)
    final filteredEarthquakes = earthquakeState.earthquakes.where((e) {
      final q = _searchQuery.toLowerCase();
      return (e.location?.toLowerCase().contains(q) ?? false) ||
          (e.province?.toLowerCase().contains(q) ?? false) ||
          (e.district?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deprem Takip'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Lokasyona göre ara...',
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
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
            onPressed: () {
              ref.read(earthquakeListProvider.notifier).refreshEarthquakes();
            },
          ),
        ],
      ),
      body: _buildBody(earthquakeState, filteredEarthquakes),
    );
  }

  Widget _buildBody(EarthquakeState state, List filteredList) {
    bool logAndCheckNull(Logger logger, String name, Object? value) {
      logger.i("$name: ${value ?? 'null'}");
      return value == null;
    }

    bool isSameDateTime(DateTime a, DateTime b) {
      return a.year == b.year &&
          a.month == b.month &&
          a.day == b.day &&
          a.hour == b.hour &&
          a.minute == b.minute;
    }

    bool isDefaultFilter(EarthquakeFilterParams filter) {
      final Logger logger = Logger();
      final defaultStart = DateHelper.getDefaultStartDate();
      final defaultEnd = DateHelper.getDefaultEndDate();

      logger.i("startDate: ${filter.startDate} | default: $defaultStart");
      logger.i("endDate: ${filter.endDate} | default: $defaultEnd");

      final noOtherFilters =
          logAndCheckNull(logger, 'minLat', filter.minLat) &&
          logAndCheckNull(logger, 'maxLat', filter.maxLat) &&
          logAndCheckNull(logger, 'minLon', filter.minLon) &&
          logAndCheckNull(logger, 'maxLon', filter.maxLon) &&
          logAndCheckNull(logger, 'centerLat', filter.centerLat) &&
          logAndCheckNull(logger, 'centerLon', filter.centerLon) &&
          logAndCheckNull(logger, 'maxRadius', filter.maxRadius) &&
          logAndCheckNull(logger, 'minRadius', filter.minRadius) &&
          logAndCheckNull(logger, 'magnitudeType', filter.magnitudeType) &&
          logAndCheckNull(logger, 'minDepth', filter.minDepth) &&
          logAndCheckNull(logger, 'maxDepth', filter.maxDepth) &&
          logAndCheckNull(logger, 'limit', filter.limit) &&
          logAndCheckNull(logger, 'offset', filter.offset) &&
          logAndCheckNull(logger, 'eventId', filter.eventId);

      final result =
          isSameDateTime(filter.startDate, defaultStart) &&
          isSameDateTime(filter.endDate, defaultEnd) &&
          (filter.minMagnitude == 0.0 || filter.minMagnitude == null) &&
          filter.orderBy == OrderBy.timeDesc &&
          noOtherFilters;

      return result;
    }

    if (state.isLoading && state.earthquakes.isEmpty) {
      return const LoadingWidget(message: 'Deprem verileri yükleniyor...');
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Bir hata oluştu',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(earthquakeListProvider.notifier).loadEarthquakes();
              },
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (filteredList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Deprem verisi bulunamadı',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Arama kriterlerinize uygun veri yok',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(earthquakeListProvider.notifier).refreshEarthquakes();
      },
      child: Column(
        children: [
          if (state.currentFilter != null &&
              !isDefaultFilter(state.currentFilter!))
            _buildFilterInfo(state.currentFilter!),
          if (state.isLoading)
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
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final earthquake = filteredList[index];
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
  }

  Widget _buildFilterInfo(EarthquakeFilterParams filter) {
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
              _getFilterDescription(filter),
              style: TextStyle(color: Colors.blue[700], fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(earthquakeListProvider.notifier).clearFilter();
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

  String _getFilterDescription(EarthquakeFilterParams filter) {
    List<String> descriptions = [];

    if (filter.minMagnitude != null && filter.minMagnitude != 0.0) {
      final min = filter.minMagnitude?.toString() ?? '';
      descriptions.add('Büyüklük: $min');
    }

    if (filter.startDate != DateHelper.getDefaultStartDate()) {
      descriptions.add(
        "Seçilen Tarih: ${DateHelper.formatDateForDisplay(filter.startDate)}",
      );
    }

    if (filter.orderBy != OrderBy.timeDesc) {
      switch (filter.orderBy) {
        case OrderBy.time:
          descriptions.add('Zamana göre (Artan)');
          break;
        case OrderBy.timeDesc:
          descriptions.add('Zamana göre (Azalan)');
          break;
        case OrderBy.magnitude:
          descriptions.add('Büyüklüğe göre (Artan)');
          break;
        case OrderBy.magnitudeDesc:
          descriptions.add('Büyüklüğe göre (Azalan)');
          break;
      }
    }

    return descriptions.join('\n');
  }

  void _showFilterSheet() {
    final currentFilter = ref.read(earthquakeListProvider).currentFilter;

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
            ref.read(earthquakeListProvider.notifier).applyFilter(params);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showEarthquakeDetail(earthquake) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Deprem Detayları',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailTile(
                  Icons.speed,
                  'Büyüklük',
                  earthquake.magnitudeDisplay,
                ),
                _buildDetailTile(
                  Icons.access_time,
                  'Tarih',
                  DateHelper.formatDateTimeForDisplay(earthquake.dateTime),
                ),
                _buildDetailTile(
                  Icons.location_on,
                  'Konum',
                  earthquake.location ?? '',
                ),
                _buildDetailTile(
                  Icons.map,
                  'Koordinat',
                  earthquake.coordinatesDisplay,
                ),
                _buildDetailTile(
                  Icons.vertical_align_bottom,
                  'Derinlik',
                  earthquake.depthDisplay,
                ),
                if (earthquake.province != null)
                  _buildDetailTile(
                    Icons.location_city,
                    'İl',
                    earthquake.province!,
                  ),
                if (earthquake.district != null)
                  _buildDetailTile(
                    Icons.apartment,
                    'İlçe',
                    earthquake.district!,
                  ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Kapat'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: Colors.grey[700]),
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(value),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
