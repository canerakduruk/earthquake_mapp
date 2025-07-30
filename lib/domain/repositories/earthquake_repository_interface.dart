import '../entities/earthquake_entity.dart';
import '../../data/services/earthquake_service.dart';

abstract class EarthquakeRepositoryInterface {
  Future<List<EarthquakeEntity>> getEarthquakes([
    EarthquakeFilterParams? params,
  ]);
  Future<EarthquakeEntity> getEarthquakeById(int eventId);
}
