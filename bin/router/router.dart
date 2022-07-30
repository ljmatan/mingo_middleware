import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../api/client.dart';
import '../data/mingo.dart';
import '../models/price_trend.dart';
import '../utils/datetime/dt.dart';

part 'handlers/penalised_providers.dart';
part 'handlers/stations_by_type.dart';
part 'handlers/station_trends.dart';

abstract class MinGORouter {
  static final instance = Router()
    ..get('/penalised-providers', _penalisedProviderHandler)
    ..get('/stations-by-type', _stationsByTypeHandler)
    ..get('/station-pricing/<stationId>', _stationTrendsHandler);
}
