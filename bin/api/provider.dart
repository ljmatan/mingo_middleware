import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/mingo.dart';
import '../models/penalised_provider.dart';
import '../models/station_price_trend.dart';

abstract class ProvidersApi {
  static Future<List<StationPriceTrendModel>> getStationTrends(int stationId) async {
    final response = await http.get(Uri.parse('https://webservis.mzoe-gor.hr/api/cjenici-postaja/$stationId'));
    final trends = <StationPriceTrendModel>[];
    for (var jsonObject in jsonDecode(response.body)) {
      if (jsonObject['cijena'] != null && jsonObject['gorivo_id'] != null && jsonObject['dat_poc'] != null) {
        trends.add(StationPriceTrendModel.fromJson(jsonObject));
      }
    }
    return trends;
  }

  static Future<void> setAllPricingInfo() async {
    final trends = <Map<String, dynamic>>[];
    for (int i = 0; i < MinGOData.instance.stations.length; i++) {
      try {
        final stationTrends = await getStationTrends(MinGOData.instance.stations[i].id);
        for (var trend in stationTrends) {
          try {
            final fuelKindId = MinGOData.instance.fuels.firstWhere((f) => f.id == trend.fuelId).fuelKindId;
            trend.fuelId = fuelKindId == 1 || fuelKindId == 2 || fuelKindId == 5 || fuelKindId == 6
                ? 1
                : fuelKindId == 7 || fuelKindId == 8 || fuelKindId == 11 || fuelKindId == 13
                    ? 2
                    : fuelKindId == 9
                        ? 3
                        : fuelKindId == 10
                            ? 4
                            : -1;
          } catch (e) {
            trend.fuelId = -1;
          }
        }
        stationTrends.removeWhere((e) => e.fuelId == -1);
        int minDifference = 0;
        DateTime dateOfLastChange = DateTime.now();
        for (var fuelKindId in const <int>{1, 2, 3, 4}) {
          try {
            final filtered = stationTrends.where((e) => e.fuelId == fuelKindId).toList();
            filtered.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
            final difference = filtered.first.lastUpdated.difference(DateTime.now()).inDays;
            if (difference < minDifference) {
              minDifference = difference;
              dateOfLastChange = filtered.first.lastUpdated;
            }
          } catch (e) {
            continue;
          }
        }
        if (minDifference < -44) {
          trends.add({
            'stationId': MinGOData.instance.stations[i].id,
            'lastUpdated': dateOfLastChange.toIso8601String(),
          });
        }
      } catch (e) {
        print('Failed to get for ${MinGOData.instance.stations[i].id}: $e');
      }
    }
    MinGOData.penalisedProviders = List<PenalisedProviderModel>.from(trends.map((e) => PenalisedProviderModel.fromJson(e)));
    print('Pricing info set at ${DateTime.now()}');
  }
}
