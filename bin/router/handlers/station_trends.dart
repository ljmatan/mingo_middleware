part of '../router.dart';

Future<Response> _stationTrendsHandler(Request req) async {
  Future<List<PriceTrendModel>> getPriceTrendsForStation(Map<String, dynamic> data) async {
    final stationId = data['stationId'];
    final fuels = data['fuels'];
    final response = await MinGOHttpClient.get('https://webservis.mzoe-gor.hr/api/cjenici-postaja/$stationId');
    final trends = <PriceTrendModel>[];
    for (var jsonObject in response) {
      if ((DateTime.tryParse(jsonObject['dat_poc'])?.year ?? 0) > 2014 &&
          jsonObject['cijena'] is num &&
          jsonObject['cijena'] < 50 &&
          jsonObject['cijena'] > 1 &&
          jsonObject['gorivo_id'] != null) {
        try {
          final trend = PriceTrendModel.fromJson(jsonObject);
          final trendFuel = fuels.firstWhere((e) => e.id == trend.fuelId);
          trend.label = trendFuel.name;
          final fuelKindId = trendFuel.fuelKindId!;
          trend.fuelId = fuelKindId == 1 || fuelKindId == 2 || fuelKindId == 5 || fuelKindId == 6
              ? 1
              : fuelKindId == 7 || fuelKindId == 8 || fuelKindId == 11 || fuelKindId == 13
                  ? 2
                  : fuelKindId == 9
                      ? 3
                      : fuelKindId == 10
                          ? 4
                          : -1;
          if (trend.fuelId != -1) trends.add(trend);
        } catch (e) {
          print('$e');
        }
      }
    }
    return trends;
  }

  Future<Map<String, dynamic>> getStationPriceTrends(Map<String, dynamic> data) async {
    final stationId = data['stationId'];
    final fuels = data['fuels'];
    final response = await MinGOHttpClient.get('https://webservis.mzoe-gor.hr/api/cjenici-postaja/$stationId');
    final trends = <PriceTrendModel>[];
    final fuelIds = <int>{};
    for (var jsonObject in response) {
      try {
        final trend = PriceTrendModel.fromJson(jsonObject);
        if (trend.lastUpdated.year > 2013 && trend.price < 40 && trend.price > 1) {
          final trendFuel = fuels.firstWhere((e) => e.id == trend.fuelId);
          trend.label = trendFuel.name!;
          trends.add(trend);
          fuelIds.add(trend.fuelId);
        }
      } catch (e) {
        print('$e');
      }
    }
    final result = {
      'trends': trends.map((e) => e.toJson()).toList(),
      'fuelIds': fuelIds.toList(),
    };
    return result;
  }

  return Response.ok(
    jsonEncode(
      (await MinGORouter.runInIsolate(getStationPriceTrends, {
        'stationId': req.params['stationId'],
        'fuels': MinGOData.instance.fuels,
      })),
    ),
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': '*',
      'Access-Control-Expose-Headers': '*',
      'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE, HEAD, OPTIONS',
    },
  );
}
