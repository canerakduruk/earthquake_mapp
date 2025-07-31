import 'package:earthquake_mapp/presentation/viewmodels/earthquake_viewmodel.dart';
import 'package:earthquake_mapp/presentation/widgets/earthquake_card_shimmer.dart';
import 'package:earthquake_mapp/presentation/widgets/earthquake_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/earthquake_provider.dart';
import '../widgets/earthquake_card.dart';
import '../widgets/loading_widget.dart';
import '../../data/services/earthquake_service.dart';
import '../../core/utils/date_helper.dart';

class EarthquakeListScreen extends ConsumerStatefulWidget {
  const EarthquakeListScreen({super.key});

  @override
  ConsumerState<EarthquakeListScreen> createState() =>
      _EarthquakeListScreenState();
}

class _EarthquakeListScreenState extends ConsumerState<EarthquakeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(earthquakeViewModelProvider.notifier).loadEarthquakes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final earthquakeState = ref.watch(earthquakeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deprem Takip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(earthquakeViewModelProvider.notifier)
                  .refreshEarthquakes();
            },
          ),
        ],
      ),
      body: _buildBody(earthquakeState),
    );
  }

  Widget _buildBody(EarthquakeState state) {
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
                ref
                    .read(earthquakeViewModelProvider.notifier)
                    .loadEarthquakes();
              },
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (state.earthquakes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Deprem verisi bulunamadı',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Filtre ayarlarınızı kontrol edin',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(earthquakeViewModelProvider.notifier)
            .refreshEarthquakes();
      },
      child: Column(
        children: [
          if (state.isLoading)
            Expanded(
              child: ListView.builder(
                itemCount: 8, // Kaç tane shimmer göstermek istediğin
                itemBuilder: (context, index) {
                  return const EarthquakeCardShimmer();
                },
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: state.earthquakes.length,
                itemBuilder: (context, index) {
                  return EarthquakeCard(
                    earthquake: state.earthquakes[index],
                    onTap: () =>
                        _showEarthquakeDetail(state.earthquakes[index]),
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
          Icon(Icons.filter_list, color: Colors.blue[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getFilterDescription(filter),
              style: TextStyle(color: Colors.blue[700], fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(earthquakeViewModelProvider.notifier).clearFilter();
            },
            child: Icon(Icons.close, color: Colors.blue[700], size: 16),
          ),
        ],
      ),
    );
  }

  String _getFilterDescription(EarthquakeFilterParams filter) {
    if ((filter.minMagnitude == null || filter.minMagnitude == 0) &&
        (filter.maxMagnitude == null || filter.maxMagnitude == 0) &&
        (filter.minDepth == null || filter.minDepth == 0) &&
        (filter.maxDepth == null || filter.maxDepth == 0)) {
      return 'Filtre yok';
    }

    List<String> descriptions = [];

    if (filter.minMagnitude != null || filter.maxMagnitude != null) {
      final min = filter.minMagnitude?.toString() ?? '';
      final max = filter.maxMagnitude?.toString() ?? '';
      descriptions.add('Büyüklük: $min-$max');
    }

    if (filter.minDepth != null || filter.maxDepth != null) {
      final min = filter.minDepth?.toString() ?? '';
      final max = filter.maxDepth?.toString() ?? '';
      descriptions.add('Derinlik: $min-$max km');
    }

    return descriptions.join(', ');
  }

  void _showFilterSheet() {
    final currentFilter = ref.read(earthquakeViewModelProvider).currentFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => EarthquakeFilterSheet(
          scrollController: scrollController,
          initialParams: currentFilter,
          onApplyFilter: (params) {
            ref.read(earthquakeViewModelProvider.notifier).applyFilter(params);
            Navigator.pop(context);
          },
        ),
      ),
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
                  DateHelper.formatDateForDisplay(earthquake.dateTime),
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
