import '../models/app_data.dart';
import '../models/penalised_provider.dart';

abstract class MinGOData {
  static late AppDataModel instance;

  static set input(AppDataModel value) {
    value.stations.removeWhere(
      (e) {
        final lat = double.tryParse(e.lat ?? '');
        final lng = double.tryParse(e.lng ?? '');
        if (lat == null || lng == null) return true;
        if (lat < 40 || lat > 50) return true;
        if (lng < 10 || lng > 20) return true;
        return false;
      },
    );
    value.fuels.removeWhere((e) => e.name == null || e.providerId == null || e.fuelKindId == null);
    value.fuels.removeWhere((f) => value.stations.where((s) => s.priceList.where((p) => p.fuelId == f.id).isNotEmpty).isEmpty);
    value.providers.removeWhere((p) => value.stations.where((s) => s.providerId == p.id).isEmpty);
    value.fuelTypes.removeWhere((e) => e.fuelKindId > 4);
    for (var station in value.stations) {
      station.priceList.sort(
        (a, b) => value.fuels
            .firstWhere((e) => e.id == a.fuelId)
            .fuelKindId!
            .compareTo(value.fuels.firstWhere((e) => e.id == b.fuelId).fuelKindId!),
      );
    }
    instance = value;
  }

  static final List<PenalisedProviderModel> penalisedProviders = [];
}
