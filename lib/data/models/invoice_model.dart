/// Model untuk data Invoice
/// 
/// Corresponds to 'invoices' table in Supabase
/// Fields: id, order_id, invoice_number, amount, payment_status, issued_date
class InvoiceModel {
  final String id;
  final String orderId;
  final String invoiceNumber;
  final double amount;
  final PaymentStatus paymentStatus;
  final DateTime issuedDate;

  InvoiceModel({
    required this.id,
    required this.orderId,
    required this.invoiceNumber,
    required this.amount,
    required this.paymentStatus,
    required this.issuedDate,
  });

  /// Create from Supabase row (Map)
  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentStatus: PaymentStatus.fromString(json['payment_status'] as String),
      issuedDate: DateTime.parse(json['issued_date'] as String),
    );
  }

  /// Convert to Map for Supabase insert
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'invoice_number': invoiceNumber,
      'amount': amount,
      'payment_status': paymentStatus.value,
      'issued_date': issuedDate.toIso8601String(),
    };
  }

  /// Format amount as Indonesian Rupiah string
  String get formattedAmount {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  /// Format issued date as readable string
  String get formattedIssuedDate {
    return '${issuedDate.day}/${issuedDate.month}/${issuedDate.year}';
  }

  InvoiceModel copyWith({
    String? id,
    String? orderId,
    String? invoiceNumber,
    double? amount,
    PaymentStatus? paymentStatus,
    DateTime? issuedDate,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      amount: amount ?? this.amount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      issuedDate: issuedDate ?? this.issuedDate,
    );
  }
}

/// Payment status enum
enum PaymentStatus {
  unpaid('unpaid'),
  partiallyPaid('partially_paid'),
  paid('paid'),
  refunded('refunded');

  final String value;
  const PaymentStatus(this.value);

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'Belum Dibayar';
      case PaymentStatus.partiallyPaid:
        return 'Sebagian Dibayar';
      case PaymentStatus.paid:
        return 'Lunas';
      case PaymentStatus.refunded:
        return 'Dikembalikan';
    }
  }
}
