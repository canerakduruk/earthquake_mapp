import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/enums/earthquake_enums.dart';
import '../../core/utils/date_helper.dart';
import '../models/earthquake_model.dart';

class EarthquakeFilterParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minLat;
  final double? maxLat;
  final double? minLon;
  final double? maxLon;
  final double? centerLat;
  final double? centerLon;
  final double? maxRadius;
  final double? minRadius;
  final double? minMagnitude;
  final double? maxMagnitude;
  final MagnitudeType? magnitudeType;
  final int? minDepth;
  final int? maxDepth;
  final int? limit;
  final int? offset;
  final OrderBy? orderBy;
  final int? eventId;

  EarthquakeFilterParams({
    this.startDate,
    this.endDate,
    this.minLat,
    this.maxLat,
    this.minLon,
    this.maxLon,
    this.centerLat,
    this.centerLon,
    this.maxRadius,
    this.minRadius,
    this.minMagnitude,
    this.maxMagnitude,
    this.magnitudeType,
    this.minDepth,
    this.maxDepth,
    this.limit,
    this.offset,
    this.orderBy,
    this.eventId,
  });
}

class EarthquakeService {
  final Dio _dio = DioClient().dio;

  Future<List<EarthquakeModel>> getEarthquakes([
    EarthquakeFilterParams? params,
  ]) async {
    try {
      final queryParams = _buildQueryParams(params);
      final response = await _dio.get(
        ApiConstants.earthquakeFilter,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          final List<dynamic> data = response.data;
          return data.map((json) => EarthquakeModel.fromJson(json)).toList();
        } else if (response.data is Map) {
          final earthquakeResponse = EarthquakeResponse.fromJson(response.data);
          return earthquakeResponse.earthquakes;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load earthquakes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<EarthquakeModel> getEarthquakeById(int eventId) async {
    try {
      final response = await _dio.get(
        ApiConstants.earthquakeFilter,
        queryParameters: {
          'eventid': eventId,
          'format': ApiConstants.defaultFormat,
        },
      );

      if (response.statusCode == 200) {
        if (response.data is List && response.data.isNotEmpty) {
          return EarthquakeModel.fromJson(response.data[0]);
        } else {
          throw Exception('Earthquake not found');
        }
      } else {
        throw Exception('Failed to load earthquake');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Map<String, dynamic> _buildQueryParams(EarthquakeFilterParams? params) {
    final Map<String, dynamic> queryParams = {};

    if (params != null) {
      // Zaman parametreleri (zorunlu)
      if (params.startDate != null) {
        queryParams['start'] = DateHelper.formatDateForApi(params.startDate!);
      } else {
        queryParams['start'] = DateHelper.formatDateForApi(
          DateHelper.getDefaultStartDate(),
        );
      }

      if (params.endDate != null) {
        queryParams['end'] = DateHelper.formatDateForApi(params.endDate!);
      } else {
        queryParams['end'] = DateHelper.formatDateForApi(
          DateHelper.getDefaultEndDate(),
        );
      }

      // Coğrafik sınırlamalar - Dikdörtgen
      if (params.minLat != null) queryParams['minlat'] = params.minLat;
      if (params.maxLat != null) queryParams['maxlat'] = params.maxLat;
      if (params.minLon != null) queryParams['minlon'] = params.minLon;
      if (params.maxLon != null) queryParams['maxlon'] = params.maxLon;

      // Coğrafik sınırlamalar - Radyal
      if (params.centerLat != null) queryParams['lat'] = params.centerLat;
      if (params.centerLon != null) queryParams['lon'] = params.centerLon;
      if (params.maxRadius != null) queryParams['maxrad'] = params.maxRadius;
      if (params.minRadius != null) queryParams['minrad'] = params.minRadius;

      // Büyüklük sınırlamaları
      if (params.minMagnitude != null)
        queryParams['minmag'] = params.minMagnitude;
      if (params.maxMagnitude != null)
        queryParams['maxmag'] = params.maxMagnitude;
      if (params.magnitudeType != null)
        queryParams['magtype'] = params.magnitudeType!.value;

      // Derinlik sınırlamaları
      if (params.minDepth != null) queryParams['mindepth'] = params.minDepth;
      if (params.maxDepth != null) queryParams['maxdepth'] = params.maxDepth;

      // Diğer parametreler
      if (params.limit != null) queryParams['limit'] = params.limit;
      if (params.offset != null) queryParams['offset'] = params.offset;
      if (params.orderBy != null)
        queryParams['orderby'] = params.orderBy!.value;
      if (params.eventId != null) queryParams['eventid'] = params.eventId;
    } else {
      // Varsayılan parametreler
      queryParams['start'] = DateHelper.formatDateForApi(
        DateHelper.getDefaultStartDate(),
      );
      queryParams['end'] = DateHelper.formatDateForApi(
        DateHelper.getDefaultEndDate(),
      );
    }

    // Format her zaman JSON
    queryParams['format'] = ApiConstants.defaultFormat;

    if (!queryParams.containsKey('orderby')) {
      queryParams['orderby'] = ApiConstants.defaultOrderBy;
    }

    return queryParams;
  }
}
