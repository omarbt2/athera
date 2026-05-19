import '../../domain/entities/monument.dart';

class MonumentModel extends Monument {
  const MonumentModel({
    required super.id,
    required super.name,
    required super.description,
    required super.wilaya,
    required super.region,
    required super.category,
    super.isUNESCO = false,
    super.isPremium = false,
    super.rating = 0.0,
    required super.latitude,
    required super.longitude,
    super.images = const [],
    required super.historicalEra,
    required super.yearBuilt,
  });

  factory MonumentModel.fromJson(Map<String, dynamic> json) {
    return MonumentModel(
      id: json['id'],
      name: LocalizedText(
        ar: json['name']['ar'],
        arDz: json['name']['ar_dz'] ?? json['name']['ar'],
        fr: json['name']['fr'],
        en: json['name']['en'],
      ),
      description: LocalizedText(
        ar: json['description']['ar'],
        arDz: json['description']['ar_dz'] ?? json['description']['ar'],
        fr: json['description']['fr'],
        en: json['description']['en'],
      ),
      wilaya: json['wilaya'],
      region: Region.values.firstWhere((e) => e.name == json['region']),
      category: MonumentCategory.values.firstWhere((e) => e.name == json['category']),
      isUNESCO: json['isUNESCO'] ?? false,
      isPremium: json['isPremium'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      historicalEra: json['historicalEra'],
      yearBuilt: json['yearBuilt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': {
        'ar': name.ar,
        'ar_dz': name.arDz,
        'fr': name.fr,
        'en': name.en,
      },
      'description': {
        'ar': description.ar,
        'ar_dz': description.arDz,
        'fr': description.fr,
        'en': description.en,
      },
      'wilaya': wilaya,
      'region': region.name,
      'category': category.name,
      'isUNESCO': isUNESCO,
      'isPremium': isPremium,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'historicalEra': historicalEra,
      'yearBuilt': yearBuilt,
    };
  }
}
