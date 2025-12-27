import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service untuk mengirim email menggunakan OMailer API
class EmailService {
  static const String _baseUrl = 'https://yusnar.my.id/omailer/send';

  // SMTP Configuration - Ganti dengan kredensial Anda
  static const String _smtpHost = 'smtp.gmail.com';
  static const String _smtpPort = '587';
  static const String _authEmail = 'azharramdhani25@gmail.com';
  static const String _authPassword = 'btht ksde rjmw lkwr';
  static const String _senderName = 'Kespro Event Hub';

  /// Kirim email menggunakan OMailer API
  static Future<bool> sendEmail({
    required String recipient,
    required String subject,
    required String bodyHtml,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      request.fields['smtp_host'] = _smtpHost;
      request.fields['smtp_port'] = _smtpPort;
      request.fields['auth_email'] = _authEmail;
      request.fields['auth_password'] = _authPassword;
      request.fields['sender_name'] = _senderName;
      request.fields['recipient'] = recipient;
      request.fields['subject'] = subject;
      request.fields['body_html'] = bodyHtml;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Email Response: ${response.statusCode} - $responseBody');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending email: $e');
      return false;
    }
  }

  /// Generate HTML template untuk Invoice
  static String generateInvoiceEmailHtml({
    required String invoiceNumber,
    required String customerName,
    required String eventDate,
    required String eventLocation,
    required String durasi,
    required List<Map<String, dynamic>> items,
    required String subtotal,
    required String discount,
    required String total,
    required String paymentStatus,
    bool hasDiscount = false,
  }) {
    final itemRows = items
        .map(
          (item) =>
              '''
      <tr>
        <td style="padding:10px; border-bottom:1px solid #eee;">${item['name']}</td>
        <td style="padding:10px; border-bottom:1px solid #eee; text-align:right;">Rp ${item['price']}</td>
      </tr>
    ''',
        )
        .join('');

    final discountRow = hasDiscount
        ? '''
      <tr>
        <td style="padding:10px; text-align:right;">Diskon:</td>
        <td style="padding:10px; text-align:right; color:#dc3545;">-$discount</td>
      </tr>
    '''
        : '';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: Arial, sans-serif; margin:0; padding:0; background-color:#f6f6f6;">
  <table role="presentation" style="width:100%; border-collapse:collapse;">
    <tr>
      <td align="center" style="padding:20px;">
        <table role="presentation" style="max-width:600px; width:100%; background:#ffffff; border-radius:12px; overflow:hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
          
          <!-- Header -->
          <tr>
            <td style="padding:30px; text-align:center; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color:#fff;">
              <h1 style="margin:0; font-size:28px; font-weight:bold;">INVOICE</h1>
              <p style="margin:10px 0 0; font-size:16px; opacity:0.9;">$invoiceNumber</p>
            </td>
          </tr>

          <!-- Customer Info -->
          <tr>
            <td style="padding:25px;">
              <p style="margin:0 0 5px; color:#666; font-size:14px;">Kepada Yth,</p>
              <p style="margin:0; font-size:18px; font-weight:bold; color:#333;">$customerName</p>
              
              <div style="margin-top:20px; padding:15px; background:#f8f9fa; border-radius:8px;">
                <p style="margin:0 0 8px;"><strong>Tanggal Event:</strong> $eventDate</p>
                <p style="margin:0 0 8px;"><strong>Lokasi:</strong> $eventLocation</p>
                <p style="margin:0;"><strong>Durasi:</strong> $durasi</p>
              </div>
            </td>
          </tr>

          <!-- Items -->
          <tr>
            <td style="padding:0 25px;">
              <table style="width:100%; border-collapse:collapse;">
                <tr style="background:#f8f9fa;">
                  <th style="padding:12px; text-align:left; font-weight:600; color:#333;">Item</th>
                  <th style="padding:12px; text-align:right; font-weight:600; color:#333;">Harga</th>
                </tr>
                $itemRows
              </table>
            </td>
          </tr>

          <!-- Total -->
          <tr>
            <td style="padding:25px;">
              <table style="width:100%; border-collapse:collapse;">
                <tr>
                  <td style="padding:10px; text-align:right;">Subtotal:</td>
                  <td style="padding:10px; text-align:right; width:150px;">$subtotal</td>
                </tr>
                $discountRow
                <tr style="font-size:18px; font-weight:bold; color:#667eea;">
                  <td style="padding:15px 10px; text-align:right; border-top:2px solid #667eea;">Total:</td>
                  <td style="padding:15px 10px; text-align:right; border-top:2px solid #667eea;">$total</td>
                </tr>
              </table>
              
              <div style="margin-top:20px; padding:15px; background:#e8f5e9; border-radius:8px; text-align:center;">
                <p style="margin:0; font-size:14px; color:#2e7d32;">
                  <strong>Status Pembayaran:</strong> $paymentStatus
                </p>
              </div>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="padding:20px; text-align:center; background:#f8f9fa; border-top:1px solid #eee;">
              <p style="margin:0 0 10px; font-size:14px; color:#666;">
                Terima kasih telah mempercayakan event Anda kepada kami.
              </p>
              <p style="margin:0; font-size:12px; color:#999;">
                Kespro Event Hub - Event Property Service
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';
  }

  /// Generate HTML template untuk konfirmasi Request Order
  static String generateOrderConfirmationHtml({
    required String orderId,
    required String customerName,
    required String eventDate,
    required String eventLocation,
    required String durasi,
    required List<Map<String, String>> items,
    required String totalOriginal,
    required String totalFinal,
    required String invoiceNumber,
  }) {
    final itemsList = items
        .map(
          (item) =>
              '''
          <li style="padding:8px 0;">
            <strong>${item['name']}</strong><br>
            <span style="font-size:13px; color:#666;">Harga Awal: ${item['original_price']}</span><br>
            <span style="font-size:13px; color:#667eea; font-weight:bold;">Harga Final: ${item['final_price']}</span>
          </li>
        ''',
        )
        .join('');

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: Arial, sans-serif; margin:0; padding:0; background-color:#f6f6f6;">
  <table role="presentation" style="width:100%; border-collapse:collapse;">
    <tr>
      <td align="center" style="padding:20px;">
        <table role="presentation" style="max-width:600px; width:100%; background:#ffffff; border-radius:12px; overflow:hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
          
          <!-- Header -->
          <tr>
            <td style="padding:30px; text-align:center; background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%); color:#fff;">
              <div style="font-size:48px; margin-bottom:10px;">✓</div>
              <h1 style="margin:0; font-size:24px; font-weight:bold;">Invoice Berhasil Dibuat!</h1>
              <p style="margin:10px 0 0; font-size:14px; opacity:0.9;">Request Order #$orderId</p>
            </td>
          </tr>

          <!-- Content -->
          <tr>
            <td style="padding:25px;">
              <p style="margin:0 0 20px; font-size:16px; color:#333;">
                Halo <strong>$customerName</strong>,
              </p>
              <p style="margin:0 0 20px; color:#666;">
                Invoice untuk request order Anda telah berhasil dibuat. Berikut detail pesanan Anda:
              </p>
              
              <div style="padding:20px; background:#f8f9fa; border-radius:8px; margin-bottom:20px;">
                <p style="margin:0 0 15px;"><strong>No. Invoice:</strong> <span style="color:#667eea; font-weight:bold;">$invoiceNumber</span></p>
                <p style="margin:0 0 8px;"><strong>Tanggal Event:</strong> $eventDate</p>
                <p style="margin:0 0 8px;"><strong>Lokasi:</strong> $eventLocation</p>
                <p style="margin:0;"><strong>Durasi:</strong> $durasi</p>
              </div>

              <p style="margin:0 0 10px; font-weight:bold; color:#333;">Produk yang Dipesan:</p>
              <ul style="margin:0 0 20px; padding-left:20px; color:#666; list-style:none;">
                $itemsList
              </ul>

              <div style="padding:15px; background:#f8f9fa; border-radius:8px;">
                <div style="margin-bottom:8px;">
                  <span style="color:#666;">Total Harga Awal:</span>
                  <span style="float:right; font-weight:bold;">$totalOriginal</span>
                </div>
                <div style="clear:both;"></div>
                <div style="padding-top:8px; border-top:1px solid #dee2e6;">
                  <span style="font-weight:bold; color:#1976d2;">Total Harga Final:</span>
                  <span style="float:right; font-weight:bold; color:#1976d2; font-size:16px;">$totalFinal</span>
                </div>
                <div style="clear:both;"></div>
              </div>
            </td>
          </tr>

          <!-- CTA -->
          <tr>
            <td style="padding:0 25px 25px;">
              <p style="margin:0; color:#666; font-size:14px; text-align:center;">
                Silakan lakukan pembayaran sesuai instruksi yang akan diberikan oleh tim kami melalui WhatsApp.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="padding:20px; text-align:center; background:#f8f9fa; border-top:1px solid #eee;">
              <p style="margin:0 0 10px; font-size:14px; color:#666;">
                Terima kasih telah mempercayakan event Anda kepada kami.
              </p>
              <p style="margin:0; font-size:12px; color:#999;">
                Kespro Event Hub - Event Property Service
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';
  }
}
