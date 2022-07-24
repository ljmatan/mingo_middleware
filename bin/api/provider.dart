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
    final List<Map<String, dynamic>> trends = [];
    for (int i = 0; i < MinGOData.instance.stations.length; i++) {
      try {
        final stationTrends = await getStationTrends(MinGOData.instance.stations[i].id);
        stationTrends.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
        print(stationTrends.first.lastUpdated.difference(DateTime.now()).inDays.toString());
        if (stationTrends.first.lastUpdated.difference(DateTime.now()).inDays < -44) {
          trends.add({
            'stationId': MinGOData.instance.stations[i].id,
            'lastUpdated': stationTrends[0].lastUpdated.toIso8601String(),
          });
        }
      } catch (e) {
        print('Failed to get for ${MinGOData.instance.stations[i].id}: $e');
      }
    }
    MinGOData.penalisedProviders.clear();
    MinGOData.penalisedProviders.addAll(trends.map((e) => PenalisedProviderModel.fromJson(e)));
    print('Pricing info set at ${DateTime.now()}');
  }
}
