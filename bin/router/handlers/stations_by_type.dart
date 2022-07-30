part of '../router.dart';

Response _stationsByTypeHandler(Request req) {
  return Response.ok(
    jsonEncode(
      [
        for (var fuelKindId in <int>{1, 2, 9, 10})
          List<int>.from(
            MinGOData.instance.stations
                .where(
                  (station) => station.priceList
                      .where(
                        (price) =>
                            fuelKindId == 1 && MinGOData.instance.fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 1 ||
                            fuelKindId == 1 && MinGOData.instance.fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 2 ||
                            fuelKindId == 1 && MinGOData.instance.fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 5 ||
                            fuelKindId == 1 && MinGOData.instance.fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 6 ||
                            fuelKindId == 2 && MinGOData.instance.fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 7 ||
                            fuelKindId == 2 && MinGOData.instance.fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 8 ||
                            fuelKindId == 2 && MinGOData.instance.fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 11 ||
                            fuelKindId == 2 && MinGOData.instance.fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 13 ||
                            MinGOData.instance.fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == fuelKindId,
                      )
                      .isNotEmpty,
                )
                .map((e) => e.id),
          ),
      ],
    ),
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': '*',
      'Access-Control-Expose-Headers': '*',
      'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE, HEAD, OPTIONS',
    },
  );
}
