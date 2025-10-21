import 'package:dio/dio.dart';
import 'package:earthquake_mapp/core/enums/earthquake_enums.dart';
import 'package:earthquake_mapp/core/utils/date_helper.dart';
import 'package:earthquake_mapp/core/utils/logger_helper.dart';
import 'package:earthquake_mapp/data/models/new_earthquake_model/earthquake_model.dart';
import 'package:earthquake_mapp/data/params/earthquake_params.dart';
import 'package:earthquake_mapp/data/repositories/earthquake_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final earthquakeFilterProvider = StateProvider<EarthquakeParams>((ref) {
  return EarthquakeParams(
    startDate: DateHelper.getDefaultStartDate(),
    endDate: DateHelper.getDefaultEndDate(),
    minMagnitude: 0.0,
    orderBy: OrderBy.timeDesc,
  );
});

final earthquakeProvider =
    FutureProvider.family<List<EarthquakeModel>, EarthquakeParams>((
      ref,
      params,
    ) async {
      final repository = ref.watch(earthquakeRepositoryProvider);

      LoggerHelper.debug("FutureProvider", "Parametre: $params");

      try {
        final earthquakes = await repository.getEarthquakes(params);
        return earthquakes;
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout) {
          throw 'Bağlantı zaman aşımı oldu. Lütfen internetinizi kontrol edin ve tekrar deneyin.';
        } else {
          throw 'Bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
        }
      } catch (e) {
        throw 'Beklenmeyen bir hata oluştu: $e';
      }
    });
