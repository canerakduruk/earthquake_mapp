import '../../domain/entities/earthquake_entity.dart';
import '../../domain/repositories/earthquake_repository_interface.dart';
import '../services/earthquake_service.dart';

class EarthquakeRepository implements EarthquakeRepositoryInterface {
  final EarthquakeService _earthquakeService;

  EarthquakeRepository(this._earthquakeService);

  @override
  Future<List<EarthquakeEntity>> getEarthquakes([
    EarthquakeFilterParams? params,
  ]) async {
    final earthquakes = await _earthquakeService.getEarthquakes(params);
    return earthquakes
        .map(
          (earthquake) => EarthquakeEntity(
            eventId: earthquake.eventId,
            magnitude: earthquake.magnitude,
            magnitudeType: earthquake.magnitudeType,
            dateTime: earthquake.dateTime,
            latitude: earthquake.latitude,
            longitude: earthquake.longitude,
            depth: earthquake.depth,
            location: earthquake.location,
            province: earthquake.province,
            district: earthquake.district,
          ),
        )
        .toList();
  }

  @override
  Future<EarthquakeEntity> getEarthquakeById(int eventId) async {
    final earthquake = await _earthquakeService.getEarthquakeById(eventId);
    return EarthquakeEntity(
      eventId: earthquake.eventId,
      magnitude: earthquake.magnitude,
      magnitudeType: earthquake.magnitudeType,
      dateTime: earthquake.dateTime,
      latitude: earthquake.latitude,
      longitude: earthquake.longitude,
      depth: earthquake.depth,
      location: earthquake.location,
      province: earthquake.province,
      district: earthquake.district,
    );
  }
}
