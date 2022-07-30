part of '../router.dart';

Future<Response> _stationTrendsHandler(Request req) async {
  final stationId = req.params['stationId'];
  final fuels = MinGOData.instance.fuels;
  final currentTime = DateTime.now();
  final response = await MinGOHttpClient.get('https://webservis.mzoe-gor.hr/api/cjenici-postaja/$stationId');
  final trends = <PriceTrendModel>[];
  for (var jsonObject in response) {
    if (jsonObject['dat_poc'] is String &&
        currentTime.difference(DateTime.tryParse(jsonObject['dat_poc']) ?? DateTime(0)).inDays < 3650 &&
        (jsonObject['cijena'] != null || jsonObject['avg_cijena'] != null) &&
        (jsonObject['cijena'] ?? jsonObject['avg_cijena']) < 50 &&
        (jsonObject['cijena'] ?? jsonObject['avg_cijena']) > 1 &&
        (jsonObject['tip_goriva_id'] != null || jsonObject['gorivo_id'] != null)) {
      try {
        final trend = PriceTrendModel.fromJson(jsonObject);
        try {
          trend.label = fuels.firstWhere((e) => e.id == trend.fuelId).name;
        } catch (e) {
          print('$e');
        }
        try {
          final fuelKindId = fuels.firstWhere((f) => f.id == trend.fuelId).fuelKindId!;
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
      } catch (e) {
        print('$e');
      }
    }
  }
  final averaged = <PriceTrendModel>[];
  for (var trend in trends) {
    if (averaged
        .where(
          (e) => e.fuelId == trend.fuelId && e.price == trend.price && DateTimeUtil.isSameDate(e.lastUpdated, trend.lastUpdated),
        )
        .isEmpty) {
      final onSameDate = trends.where(
        (e) => e.fuelId == trend.fuelId && DateTimeUtil.isSameDate(e.lastUpdated, trend.lastUpdated),
      );
      if (onSameDate.length > 1) {
        double average = 0;
        for (var trend in onSameDate) {
          average += trend.price;
        }
        average = average / onSameDate.length;
        for (var trend in onSameDate) {
          trend.price = average;
        }
        averaged.add(trend);
      }
    }
  }
  final uniqueDates = <PriceTrendModel>[];
  for (var trend in averaged) {
    trends.removeWhere(
      (e) => trend.fuelId == e.fuelId && trend.price == e.price && DateTimeUtil.isSameDate(e.lastUpdated, trend.lastUpdated),
    );
    uniqueDates.add(trend);
  }
  trends
    ..addAll(uniqueDates)
    ..sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
  return Response.ok(
    jsonEncode(trends.map((e) => e.toJson()).toList()),
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': '*',
      'Access-Control-Expose-Headers': '*',
      'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE, HEAD, OPTIONS',
    },
  );
}
