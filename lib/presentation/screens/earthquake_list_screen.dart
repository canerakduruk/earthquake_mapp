import 'package:earthquake_mapp/presentation/viewmodels/earthquake_viewmodel.dart';
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
          if (state.isLoading) const LinearProgressIndicator(),
          if (state.currentFilter != null)
            _buildFilterInfo(state.currentFilter!),
          Expanded(
            child: ListView.builder(
              itemCount: state.earthquakes.length,
              itemBuilder: (context, index) {
                return EarthquakeCard(
                  earthquake: state.earthquakes[index],
                  onTap: () => _showEarthquakeDetail(state.earthquakes[index]),
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
          onApplyFilter: (params) {
            ref.read(earthquakeViewModelProvider.notifier).applyFilter(params);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showEarthquakeDetail(earthquake) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deprem Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Büyüklük', earthquake.magnitudeDisplay),
            _buildDetailRow(
              'Tarih',
              DateHelper.formatDateForDisplay(earthquake.dateTime),
            ),
            _buildDetailRow('Konum', earthquake.location),
            _buildDetailRow('Koordinat', earthquake.coordinatesDisplay),
            _buildDetailRow('Derinlik', earthquake.depthDisplay),
            if (earthquake.province != null)
              _buildDetailRow('İl', earthquake.province!),
            if (earthquake.district != null)
              _buildDetailRow('İlçe', earthquake.district!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
