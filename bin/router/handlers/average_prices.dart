part of '../router.dart';

Future<Response> _averagePricesHandler(Request req) async {
  Future<List<Map<String, dynamic>>> getAveragePrices(Map<String, dynamic> data) async {
    final response = await MinGOHttpClient.get('https://webservis.mzoe-gor.hr/api/trend-cijena');
    final trends = <PriceTrendModel>[];
    for (var jsonObject in response) {
      try {
        final trend = PriceTrendModel.fromJson(jsonObject);
        if (trend.lastUpdated.year > 2013 && trend.price < 40 && trend.price > 1) {
          trend.label = trend.fuelId == 1
              ? 'Benzin'
              : trend.fuelId == 2
                  ? 'Dizel'
                  : trend.fuelId == 3
                      ? 'Autoplin'
                      : trend.fuelId == 4
                          ? 'Plinsko ulje'
                          : null;
          if (trend.label != null) trends.add(trend);
        }
      } catch (e) {
        print('$e');
      }
    }
    return trends.map((e) => e.toJson()).toList();
  }

  return Response.ok(
    jsonEncode(await MinGORouter.runInIsolate(getAveragePrices, <String, dynamic>{})),
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': '*',
      'Access-Control-Expose-Headers': '*',
      'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE, HEAD, OPTIONS',
    },
  );
}
