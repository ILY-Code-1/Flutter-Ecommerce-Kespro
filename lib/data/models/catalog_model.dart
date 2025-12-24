/// Model untuk data Katalog
/// 
/// Corresponds to 'catalogs' table in Supabase
/// Mendukung soft delete dengan field deleted_at
class CatalogModel {
  final String id;
  final String name;
  final double priceEstimation;
  final String? imageUrl;
  final String? description;
  final bool isActive;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  CatalogModel({
    required this.id,
    required this.name,
    required this.priceEstimation,
    this.imageUrl,
    this.description,
    this.isActive = true,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Supabase row (Map)
  factory CatalogModel.fromJson(Map<String, dynamic> json) {
    return CatalogModel(
      id: json['id'] as String,
      name: json['name'] as String,
      priceEstimation: (json['price_estimation'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      deletedAt: json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at'] as String) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to Map for Supabase insert
  Map<String, dynamic> toJsonForInsert() {
    return {
      'name': name,
      'price_estimation': priceEstimation,
      'image_url': imageUrl,
      'description': description,
      'is_active': isActive,
    };
  }

  /// Convert to Map for Supabase update
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'name': name,
      'price_estimation': priceEstimation,
      'image_url': imageUrl,
      'description': description,
      'is_active': isActive,
    };
  }

  /// Format price as Indonesian Rupiah string
  String get formattedPrice {
    final formatted = priceEstimation.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  /// Check if catalog is deleted (soft delete)
  bool get isDeleted => deletedAt != null;

  /// Get status string
  String get status {
    if (isDeleted) return 'deleted';
    if (!isActive) return 'inactive';
    return 'active';
  }

  CatalogModel copyWith({
    String? id,
    String? name,
    double? priceEstimation,
    String? imageUrl,
    String? description,
    bool? isActive,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CatalogModel(
      id: id ?? this.id,
      name: name ?? this.name,
      priceEstimation: priceEstimation ?? this.priceEstimation,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
