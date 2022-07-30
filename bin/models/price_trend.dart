class PriceTrendModel {
  final DateTime lastUpdated;
  int fuelId;
  double price;
  String? label;

  PriceTrendModel({
    required this.lastUpdated,
    required this.fuelId,
    required this.price,
    this.label,
  });

  factory PriceTrendModel.fromJson(Map<String, dynamic> json) => PriceTrendModel(
        lastUpdated: DateTime.parse(json['dat_poc']),
        fuelId: json['tip_goriva_id'],
        price: json['avg_cijena'].toDouble(),
        label: json['label'],
      );

  Map<String, dynamic> toJson() => {
        'dat_poc': lastUpdated.toIso8601String(),
        'tip_goriva_id': fuelId,
        'avg_cijena': price,
        'label': label,
      };
}
