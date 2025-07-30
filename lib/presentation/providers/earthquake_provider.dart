import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../data/services/earthquake_service.dart';
import '../../data/repositories/earthquake_repository.dart';
import '../../domain/repositories/earthquake_repository_interface.dart';
import '../viewmodels/earthquake_viewmodel.dart';

// DioClient provider
final dioClientProvider = Provider<DioClient>((ref) {
  final dioClient = DioClient();
  dioClient.init();
  return dioClient;
});

// Service provider
final earthquakeServiceProvider = Provider<EarthquakeService>((ref) {
  ref.watch(dioClientProvider);
  return EarthquakeService();
});

// Repository provider
final earthquakeRepositoryProvider = Provider<EarthquakeRepositoryInterface>((
  ref,
) {
  final earthquakeService = ref.watch(earthquakeServiceProvider);
  return EarthquakeRepository(earthquakeService);
});

// ViewModel provider
final earthquakeViewModelProvider =
    StateNotifierProvider<EarthquakeViewModel, EarthquakeState>((ref) {
      final earthquakeRepository = ref.watch(earthquakeRepositoryProvider);
      return EarthquakeViewModel(earthquakeRepository);
    });
