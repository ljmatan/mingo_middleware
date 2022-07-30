import 'dart:convert';
import 'dart:isolate';

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

  static Future _runInIsolate(Map<String, dynamic> data) async {
    final function = data['function'];
    final sendPort = data['sendPort'];
    final result = await function(data);
    Isolate.exit(sendPort, result);
  }

  static Future runInIsolate(
    Function(Map<String, dynamic>) function,
    Map<String, dynamic> data,
  ) async {
    print('Isolate initiated');
    final port = ReceivePort();
    print('Isolate port opened');
    final isolateData = <String, dynamic>{
      'sendPort': port.sendPort,
      'function': function,
    }..addAll(data);
    print('Data assigned to isolate');
    await Isolate.spawn(_runInIsolate, isolateData);
    print('Isolate spawned');
    return await port.first;
  }
}
