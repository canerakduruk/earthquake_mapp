import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/earthquake_entity.dart';
import '../../domain/repositories/earthquake_repository_interface.dart';
import '../../data/services/earthquake_service.dart';

class EarthquakeState {
  final bool isLoading;
  final List<EarthquakeEntity> earthquakes;
  final String? error;
  final EarthquakeFilterParams? currentFilter;

  EarthquakeState({
    this.isLoading = false,
    this.earthquakes = const [],
    this.error,
    this.currentFilter,
  });

  EarthquakeState copyWith({
    bool? isLoading,
    List<EarthquakeEntity>? earthquakes,
    String? error,
    EarthquakeFilterParams? currentFilter,
  }) {
    return EarthquakeState(
      isLoading: isLoading ?? this.isLoading,
      earthquakes: earthquakes ?? this.earthquakes,
      error: error,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class EarthquakeViewModel extends StateNotifier<EarthquakeState> {
  final EarthquakeRepositoryInterface _earthquakeRepository;

  EarthquakeViewModel(this._earthquakeRepository) : super(EarthquakeState());

  Future<void> loadEarthquakes([EarthquakeFilterParams? params]) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final earthquakes = await _earthquakeRepository.getEarthquakes(params);
      state = state.copyWith(
        isLoading: false,
        earthquakes: earthquakes,
        currentFilter: params,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Bağlantı zaman aşımı oldu. Lütfen internetinizi kontrol edin ve tekrar deneyin.',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyin.',
        );
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Beklenmeyen bir hata oluştu.',
      );
    }
  }

  Future<void> refreshEarthquakes() async {
    await loadEarthquakes(state.currentFilter);
  }

  Future<void> applyFilter(EarthquakeFilterParams params) async {
    await loadEarthquakes(params);
  }

  void clearFilter() {
    loadEarthquakes();
  }
}
