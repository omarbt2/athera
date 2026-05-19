import 'monument.dart';

class FilterParams {
  final Region? region;
  final MonumentCategory? category;
  final bool onlyUNESCO;
  final bool onlyPremium;

  const FilterParams({
    this.region,
    this.category,
    this.onlyUNESCO = false,
    this.onlyPremium = false,
  });
}
