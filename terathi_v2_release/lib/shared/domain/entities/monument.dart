enum Region { north, south, east, west, center }

enum MonumentCategory {
  archaeological,
  islamic,
  natural,
  museum,
  military,
  modern
}

class LocalizedText {
  final String ar;
  final String arDz;
  final String fr;
  final String en;

  const LocalizedText({
    required this.ar,
    required this.arDz,
    required this.fr,
    required this.en,
  });

  String get(String lang) {
    switch (lang) {
      case 'ar_dz':
        return arDz;
      case 'fr':
        return fr;
      case 'en':
        return en;
      default:
        return ar;
    }
  }

  Map<String, dynamic> toJson() =>
      {'ar': ar, 'arDz': arDz, 'fr': fr, 'en': en};

  factory LocalizedText.fromJson(dynamic json) {
    if (json is String) {
      return LocalizedText(ar: json, arDz: json, fr: json, en: json);
    }
    if (json is Map<String, dynamic>) {
      return LocalizedText(
        ar: json['ar'] as String? ?? '',
        arDz: json['arDz'] as String? ?? '',
        fr: json['fr'] as String? ?? '',
        en: json['en'] as String? ?? '',
      );
    }
    return const LocalizedText(ar: '', arDz: '', fr: '', en: '');
  }
}

class Monument {
  final String id;
  final LocalizedText name;
  final LocalizedText description;
  final String wilaya;
  final Region region;
  final MonumentCategory category;
  final bool isPremium;
  final bool isUNESCO;
  final double rating;
  final double visitDurationHours;
  final double latitude;
  final double longitude;
  final List<String> images;
  final String historicalEra;
  final String yearBuilt;

  const Monument({
    required this.id,
    required this.name,
    required this.description,
    required this.wilaya,
    required this.region,
    required this.category,
    this.isPremium = false,
    this.isUNESCO = false,
    this.rating = 0.0,
    this.visitDurationHours = 1.0,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.historicalEra,
    required this.yearBuilt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name.toJson(),
        'description': description.toJson(),
        'wilaya': wilaya,
        'region': region.index,
        'category': category.index,
        'isPremium': isPremium,
        'isUNESCO': isUNESCO,
        'rating': rating,
        'visitDurationHours': visitDurationHours,
        'latitude': latitude,
        'longitude': longitude,
        'images': images,
        'historicalEra': historicalEra,
        'yearBuilt': yearBuilt,
      };

  factory Monument.fromJson(Map<String, dynamic> json) {
    // Handle region conversion from String or Int
    Region regionVal = Region.center;
    if (json['region'] is int) {
      regionVal = Region.values[json['region'] as int];
    } else if (json['region'] is String) {
      regionVal = Region.values.firstWhere(
        (e) => e.name == (json['region'] as String).toLowerCase(),
        orElse: () => Region.center,
      );
    }

    // Handle category conversion from String or Int
    // Fix: Handle Arabic category strings directly from Supabase
    MonumentCategory categoryVal = MonumentCategory.archaeological;
    if (json['category'] is int) {
      categoryVal = MonumentCategory.values[json['category'] as int];
    } else if (json['category'] is String) {
      final catStr = (json['category'] as String).toLowerCase();
      if (catStr.contains('أثري') || catStr.contains('روماني') || catStr.contains('archaeological')) {
        categoryVal = MonumentCategory.archaeological;
      } else if (catStr.contains('إسلامي') || catStr.contains('islamic')) {
        categoryVal = MonumentCategory.islamic;
      } else if (catStr.contains('طبيعي') || catStr.contains('natural')) {
        categoryVal = MonumentCategory.natural;
      } else if (catStr.contains('متحف') || catStr.contains('museum')) {
        categoryVal = MonumentCategory.museum;
      } else {
        categoryVal = MonumentCategory.values.firstWhere(
          (e) => e.name == catStr,
          orElse: () => MonumentCategory.archaeological,
        );
      }
    }

    // Handle images which might be a comma-separated string or a list
    List<String> imagesList = [];
    if (json['images'] is List) {
      imagesList = List<String>.from(json['images'] as List);
    } else if (json['images'] is String) {
      imagesList = (json['images'] as String).split(',').map((e) => e.trim()).toList();
    } else if (json['image_url'] != null) {
      // Fallback for single image_url column often used in Supabase
      imagesList = [json['image_url'] as String];
    }

    return Monument(
      id: (json['id'] ?? '').toString(),
      name: LocalizedText.fromJson(json['name']),
      description: LocalizedText.fromJson(json['description']),
      wilaya: json['wilaya'] as String? ?? json['location'] as String? ?? '',
      region: regionVal,
      category: categoryVal,
      isPremium: json['isPremium'] as bool? ?? json['is_premium'] as bool? ?? false,
      isUNESCO: json['isUNESCO'] as bool? ?? json['unesco'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      visitDurationHours: (json['visitDurationHours'] as num?)?.toDouble() ?? (json['visiting_hours'] != null ? 2.0 : 1.0),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      images: imagesList,
      historicalEra: json['historicalEra'] as String? ?? json['period'] as String? ?? '',
      yearBuilt: (json['yearBuilt'] ?? json['created_at'] ?? '').toString().split(' ')[0],
    );
  }
}
