/// Model untuk data Jadwal Sewa (Rental Schedule)
/// 
/// Corresponds to 'rental_schedules' table in Supabase
/// Fields: id, catalog_id, start_date, end_date, status
class RentalScheduleModel {
  final String id;
  final String catalogId;
  final DateTime startDate;
  final DateTime endDate;
  final RentalStatus status;
  final String? catalogName; // Joined from catalogs table

  RentalScheduleModel({
    required this.id,
    required this.catalogId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.catalogName,
  });

  /// Create from Supabase row (Map)
  /// Supports joined data from catalogs table
  factory RentalScheduleModel.fromJson(Map<String, dynamic> json) {
    // Handle joined catalog data
    String? catalogName;
    if (json['catalogs'] != null && json['catalogs'] is Map) {
      catalogName = json['catalogs']['name'] as String?;
    }

    return RentalScheduleModel(
      id: json['id'] as String,
      catalogId: json['catalog_id'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: RentalStatus.fromString(json['status'] as String),
      catalogName: catalogName,
    );
  }

  /// Convert to Map for Supabase insert
  Map<String, dynamic> toJson() {
    return {
      'catalog_id': catalogId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status.value,
    };
  }

  /// Format date range as readable string
  String get formattedDateRange {
    final start = '${startDate.day}/${startDate.month}/${startDate.year}';
    final end = '${endDate.day}/${endDate.month}/${endDate.year}';
    return '$start - $end';
  }

  /// Calculate duration in days
  int get durationDays {
    return endDate.difference(startDate).inDays + 1;
  }

  RentalScheduleModel copyWith({
    String? id,
    String? catalogId,
    DateTime? startDate,
    DateTime? endDate,
    RentalStatus? status,
    String? catalogName,
  }) {
    return RentalScheduleModel(
      id: id ?? this.id,
      catalogId: catalogId ?? this.catalogId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      catalogName: catalogName ?? this.catalogName,
    );
  }
}

/// Rental status enum
enum RentalStatus {
  scheduled('scheduled'),
  active('active'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const RentalStatus(this.value);

  static RentalStatus fromString(String value) {
    return RentalStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RentalStatus.scheduled,
    );
  }

  String get displayName {
    switch (this) {
      case RentalStatus.scheduled:
        return 'Terjadwal';
      case RentalStatus.active:
        return 'Sedang Disewa';
      case RentalStatus.completed:
        return 'Selesai';
      case RentalStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}
