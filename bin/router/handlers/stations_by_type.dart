part of '../router.dart';

Future<Response> _stationsByTypeHandler(Request req) async {
  Future<List<List<int>>> filterData(Map<String, dynamic> data) async {
    final stations = data['stations'];
    final fuels = data['fuels'];
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

  Future<List<List<int>>> filteredData() async {
    final data = <String, dynamic>{};
    data['stations'] = MinGOData.instance.stations;
    data['fuels'] = MinGOData.instance.fuels;
    return await MinGORouter.compute(filterData, data);
  }

  return Response.ok(
    jsonEncode(await filteredData()),
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': '*',
      'Access-Control-Expose-Headers': '*',
      'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE, HEAD, OPTIONS',
    },
  );
}
