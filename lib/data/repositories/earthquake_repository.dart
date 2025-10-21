import 'package:earthquake_mapp/data/models/new_earthquake_model/earthquake_model.dart';
import 'package:earthquake_mapp/data/params/earthquake_params.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/earthquake_service.dart';

final earthquakeRepositoryProvider = Provider<EarthquakeRepository>((ref) {
  final earthquakeService = ref.watch(earthquakeServiceProvider);
  return EarthquakeRepository(earthquakeService);
});

class EarthquakeRepository {
  final EarthquakeService _earthquakeService;

  EarthquakeRepository(this._earthquakeService);

  Future<List<EarthquakeModel>> getEarthquakes([
    EarthquakeParams? params,
  ]) async {
    return await _earthquakeService.getEarthquakes(params);
  }

  Future<EarthquakeModel> getEarthquakeById(int eventId) async {
    return await _earthquakeService.getEarthquakeById(eventId);
  }
}
