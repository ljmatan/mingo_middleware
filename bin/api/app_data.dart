import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../data/mingo.dart';
import '../models/app_data.dart';
import '../router/router.dart';

abstract class AppDataApi {
  static Future<List<List<int>>> _getStationsByType(Map<String, dynamic> data) async {
    final stations = data['stations'] as Iterable<Station>;
    print('stations ${stations.runtimeType} ${stations.length}');
    final fuels = data['fuels'] as Iterable<Fuel>;
    print('fuels ${fuels.runtimeType} ${fuels.length}');
    return [
      for (var fuelKindId in <int>{1, 2, 9, 10})
        List<int>.from(
          stations
              .where(
                (station) => station.priceList
                    .where(
                      (price) =>
                          fuelKindId == 1 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 1 ||
                          fuelKindId == 1 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 2 ||
                          fuelKindId == 1 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 5 ||
                          fuelKindId == 1 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 6 ||
                          fuelKindId == 2 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 7 ||
                          fuelKindId == 2 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 8 ||
                          fuelKindId == 2 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 11 ||
                          fuelKindId == 2 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 13 ||
                          fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == fuelKindId,
                    )
                    .isNotEmpty,
              )
              .map((e) => e.id),
        ),
    ];
  }

  static Future<AppDataModel> getAll() async {
    Future<List<List<int>>> getStationsByType() async {
      final data = {
        'stations': MinGOData.instance.stations,
        'fuels': MinGOData.instance.fuels,
      };
      return await MinGORouter.runInIsolate(_getStationsByType, data) as List<List<int>>;
    }

    final http.Response response = await http.get(
      Uri.parse('https://mzoe-gor.hr/data.gz'),
      headers: {
        'Referer': 'https://mzoe-gor.hr',
      },
    );
    print('Data response received');
    final extracted = GZipCodec().decode(response.bodyBytes);
    print('Data response extracted: ${extracted.length}');
    final utf8Decoded = utf8.decode(extracted, allowMalformed: true);
    print('Data response utf8 decoded');
    final jsonDecoded = jsonDecode(utf8Decoded);
    print('Data response JSON decoded');
    final data = AppDataModel.fromJson(jsonDecoded);
    print('Data response serialized');
    MinGOData.input = data;
    MinGOData.stationsByType = await getStationsByType();

    return MinGOData.instance;
  }
}
