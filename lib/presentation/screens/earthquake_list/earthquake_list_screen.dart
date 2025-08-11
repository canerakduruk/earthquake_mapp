import 'package:earthquake_mapp/core/enums/earthquake_enums.dart';
import 'package:earthquake_mapp/core/utils/date_helper.dart';
import 'package:earthquake_mapp/data/services/earthquake_service.dart';
import 'package:earthquake_mapp/presentation/providers/earthquake_provider.dart';
import 'package:earthquake_mapp/presentation/screens/earthquake_list/earthquake_detail_sheet.dart';
import 'package:earthquake_mapp/presentation/screens/earthquake_list/earthquake_empty_state.dart';
import 'package:earthquake_mapp/presentation/screens/earthquake_list/earthquake_error_state.dart';
import 'package:earthquake_mapp/presentation/screens/earthquake_list/earthquake_filter_info.dart';
import 'package:earthquake_mapp/presentation/screens/earthquake_list/earthquake_list_view.dart';
import 'package:earthquake_mapp/presentation/screens/earthquake_list/earthquake_search_bar.dart';
import 'package:earthquake_mapp/presentation/screens/earthquake_list/earthquake_shimmer_list.dart';
import 'package:earthquake_mapp/presentation/viewmodels/earthquake_viewmodel.dart';
import 'package:earthquake_mapp/presentation/widgets/earthquake_filter_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      builder: (context) => EarthquakeDetailSheet(earthquake: earthquake),
    );
  }

  @override
  Widget build(BuildContext context) {
    final earthquakeState = ref.watch(earthquakeListProvider);

    final filteredEarthquakes = earthquakeState.earthquakes.where((e) {
      final q = _searchQuery.toLowerCase();
      return (e.location?.toLowerCase().contains(q) ?? false) ||
          (e.province?.toLowerCase().contains(q) ?? false) ||
          (e.district?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('earthquake_tracking'.tr()),
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: EarthquakeSearchBar(
            searchQuery: _searchQuery,
            onSearchChanged: (value) => setState(() => _searchQuery = value),
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
              ref.read(earthquakeListProvider.notifier).refreshEarthquakes();
            },
          ),
        ],
      ),
      body: _buildBody(earthquakeState, filteredEarthquakes),
    );
  }

  Widget _buildBody(EarthquakeState state, List filteredList) {
    bool isDefaultFilter(EarthquakeFilterParams filter) {
      final defaultStart = DateHelper.getDefaultStartDate();
      final defaultEnd = DateHelper.getDefaultEndDate();

      bool isSameDateTime(DateTime a, DateTime b) =>
          a.year == b.year &&
          a.month == b.month &&
          a.day == b.day &&
          a.hour == b.hour &&
          a.minute == b.minute;

      bool logAndCheckNull(Object? value) => value == null;

      final noOtherFilters =
          logAndCheckNull(filter.minLat) &&
          logAndCheckNull(filter.maxLat) &&
          logAndCheckNull(filter.minLon) &&
          logAndCheckNull(filter.maxLon) &&
          logAndCheckNull(filter.centerLat) &&
          logAndCheckNull(filter.centerLon) &&
          logAndCheckNull(filter.maxRadius) &&
          logAndCheckNull(filter.minRadius) &&
          logAndCheckNull(filter.magnitudeType) &&
          logAndCheckNull(filter.minDepth) &&
          logAndCheckNull(filter.maxDepth) &&
          logAndCheckNull(filter.limit) &&
          logAndCheckNull(filter.offset) &&
          logAndCheckNull(filter.eventId);

      return isSameDateTime(filter.startDate, defaultStart) &&
          isSameDateTime(filter.endDate, defaultEnd) &&
          (filter.minMagnitude == 0.0 || filter.minMagnitude == null) &&
          filter.orderBy == OrderBy.timeDesc &&
          noOtherFilters;
    }

    if (state.isLoading && state.earthquakes.isEmpty) {
      return const EarthquakeCardShimmerList();
    }

    if (state.error != null) {
      return EarthquakeErrorState(
        errorMessage: state.error!,
        onRetry: () =>
            ref.read(earthquakeListProvider.notifier).loadEarthquakes(),
      );
    }

    if (filteredList.isEmpty) {
      return const EarthquakeEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(earthquakeListProvider.notifier).refreshEarthquakes(),
      child: Column(
        children: [
          if (state.currentFilter != null &&
              !isDefaultFilter(state.currentFilter!))
            EarthquakeFilterInfo(
              filter: state.currentFilter!,
              onClearFilter: () =>
                  ref.read(earthquakeListProvider.notifier).clearFilter(),
            ),
          Expanded(
            child: EarthquakeListView(
              earthquakes: filteredList,
              onTap: _showEarthquakeDetail,
              isLoading: state.isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
