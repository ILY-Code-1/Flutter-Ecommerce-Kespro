/// Model untuk data Order
/// 
/// Corresponds to 'orders' table in Supabase
/// Fields: id, customer_name, email, event_date, location, duration, 
///         catalog_items, total_price, notes, status, created_at
class OrderModel {
  final String id;
  final String customerName;
  final String email;
  final DateTime eventDate;
  final String location;
  final String duration;
  final List<String> catalogItems;
  final double totalPrice;
  final String? notes;
  final OrderStatus status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.email,
    required this.eventDate,
    required this.location,
    required this.duration,
    required this.catalogItems,
    required this.totalPrice,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  /// Create from Supabase row (Map)
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      customerName: json['customer_name'] as String,
      email: json['email'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      location: json['location'] as String,
      duration: json['duration'] as String,
      catalogItems: List<String>.from(json['catalog_items'] as List),
      totalPrice: (json['total_price'] as num).toDouble(),
      notes: json['notes'] as String?,
      status: OrderStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to Map for Supabase insert (public user - create order)
  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'email': email,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'duration': duration,
      'catalog_items': catalogItems,
      'total_price': totalPrice,
      'notes': notes,
      'status': status.value,
    };
  }

  /// Format price as Indonesian Rupiah string
  String get formattedPrice {
    final formatted = totalPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  /// Format event date as readable string
  String get formattedEventDate {
    return '${eventDate.day}/${eventDate.month}/${eventDate.year}';
  }

  OrderModel copyWith({
    String? id,
    String? customerName,
    String? email,
    DateTime? eventDate,
    String? location,
    String? duration,
    List<String>? catalogItems,
    double? totalPrice,
    String? notes,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      email: email ?? this.email,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      duration: duration ?? this.duration,
      catalogItems: catalogItems ?? this.catalogItems,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Order status enum
enum OrderStatus {
  pending('pending'),
  confirmed('confirmed'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Menunggu';
      case OrderStatus.confirmed:
        return 'Dikonfirmasi';
      case OrderStatus.inProgress:
        return 'Sedang Berjalan';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}
