# CHANGELOG - Invoice Detail Product Display

## 🎯 Tujuan
Menampilkan detail produk per item dengan harga original dan final di:
- Invoice detail page (web UI)
- PDF invoice  
- Email invoice

## 🔧 Perubahan Yang Dilakukan

### 1. **invoice_ui_controller.dart**

#### A. Import dart:convert
```dart
import 'dart:convert';  // ← TAMBAH untuk jsonDecode
```

#### B. Update InvoiceModel.fromJson()
**Sebelum:** Hanya cek `catalog_details`
**Sesudah:** 
- Cek `catalog_details` DAN `catalog_items`
- Support parsing JSON string
- Fallback handling

```dart
// Try to parse catalog_details or catalog_items
dynamic catalogData = json['catalog_details'] ?? json['catalog_items'];

if (catalogData != null) {
  if (catalogData is List) {
    catalogDetails = catalogData.map((e) => e as Map<String, dynamic>).toList();
  } else if (catalogData is String) {
    // Decode JSON string
    final decoded = jsonDecode(catalogData);
    if (decoded is List) {
      catalogDetails = decoded.map((e) => e as Map<String, dynamic>).toList();
    }
  }
}
```

#### C. Tambah Helper Methods ke InvoiceModel
```dart
/// Format price helper
String formatPrice(double price) {
  final formatted = price.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
  return 'Rp $formatted';
}

/// Get catalog items with price details
List<Map<String, dynamic>> get catalogItemsWithPrice {
  if (catalogDetails == null || catalogDetails!.isEmpty) return [];
  
  return catalogDetails!.map((item) {
    final originalPrice = (item['original_price'] as num?)?.toDouble() ?? 
                         (item['price_estimation'] as num?)?.toDouble() ?? 0;
    final finalPrice = (item['final_price'] as num?)?.toDouble() ?? originalPrice;
    
    return {
      'name': item['name'] ?? '-',
      'original_price': originalPrice,
      'final_price': finalPrice,
      'formatted_original_price': formatPrice(originalPrice),
      'formatted_final_price': formatPrice(finalPrice),
    };
  }).toList();
}
```

#### D. Update loadInvoiceDetail()
**PENTING:** Fetch catalog_items dari request_orders

```dart
Future<void> loadInvoiceDetail(String invoiceId) async {
  // 1. Fetch invoice dari v_invoices_full
  final invoiceResponse = await _supabase
      .from('v_invoices_full')
      .select()
      .eq('id', invoiceId)
      .single();
  
  // 2. Fetch catalog_items dari request_orders
  if (invoiceResponse['request_order_id'] != null) {
    final requestOrderResponse = await _supabase
        .from('request_orders')
        .select('catalog_items')
        .eq('id', invoiceResponse['request_order_id'])
        .single();
    
    // 3. Merge ke invoice response
    invoiceResponse['catalog_items'] = requestOrderResponse['catalog_items'];
  }
  
  // 4. Parse menjadi InvoiceModel
  selectedInvoice.value = InvoiceModel.fromJson(invoiceResponse);
}
```

#### E. Update PDF Generation
**Sebelum:** Simple list
**Sesudah:** Table dengan 3 kolom

```dart
pw.Table(
  border: pw.TableBorder.all(color: PdfColors.grey300),
  children: [
    // Header
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        pw.Text('Nama Produk'),
        pw.Text('Harga Awal'),
        pw.Text('Harga Final'),
      ],
    ),
    // Items
    ...invoice.catalogItemsWithPrice.map((item) {
      return pw.TableRow(
        children: [
          pw.Text(item['name']),
          pw.Text(item['formatted_original_price'], 
            decoration: hasDiscount ? lineThrough : null),
          pw.Text(item['formatted_final_price'], 
            fontWeight: bold),
        ],
      );
    }),
  ],
)
```

#### F. Update Email Data
```dart
final items = invoice.catalogItemsWithPrice.map((item) => {
  'name': item['name'],
  'original_price': item['formatted_original_price'],
  'final_price': item['formatted_final_price'],
  'has_discount': item['final_price'] < item['original_price'],
}).toList();
```

### 2. **invoice_detail_page.dart**

#### Tambah _buildProductDetails()
Menampilkan tabel produk dengan:
- Header: Nama Produk | Harga Awal | Harga Final
- Responsive (mobile & desktop)
- Visual indicator untuk discount

```dart
Widget _buildProductDetails(InvoiceModel invoice, bool isMobile) {
  final items = invoice.catalogItemsWithPrice;
  
  return Container(
    decoration: BoxDecoration(...),
    child: Column(
      children: [
        // Header row
        Row(
          children: [
            Text('Nama Produk'),
            if (!isMobile) Text('Harga Awal'),
            Text('Harga Final'),
          ],
        ),
        // Item rows
        ...items.map((item) {
          final hasDiscount = item['final_price'] < item['original_price'];
          return Row(
            children: [
              Text(item['name']),
              if (!isMobile) 
                Text(item['formatted_original_price'], 
                  decoration: hasDiscount ? lineThrough : null),
              Text(item['formatted_final_price'],
                color: hasDiscount ? green : primary),
            ],
          );
        }),
      ],
    ),
  );
}
```

### 3. **email_service.dart**

#### Update generateInvoiceEmailHtml()
**Sebelum:** 2 kolom (Item | Harga)
**Sesudah:** 3 kolom (Item | Harga Awal | Harga Final)

```dart
final itemRows = items.map((item) {
  final hasDiscount = item['has_discount'] ?? false;
  return '''
    <tr>
      <td>${item['name']}</td>
      <td style="${hasDiscount ? 'text-decoration:line-through;' : ''}">
        ${item['original_price']}
      </td>
      <td style="font-weight:bold; color:${hasDiscount ? '#22c55e' : '#333'};">
        ${item['final_price']}
      </td>
    </tr>
  ''';
}).join('');
```

## 📊 Format Data yang Diharapkan

### Dari Database (request_orders.catalog_items)
```json
[
  {
    "name": "Backdrop Premium",
    "catalog_id": "aa54d6e9-ec62-4eb4-9674-c4f3a36bb929",
    "original_price": 500000,
    "final_price": 500000
  },
  {
    "name": "Panggung Portable",
    "catalog_id": "01e1a351-274f-4c96-9efa-43081e0596b7",
    "original_price": 1500000,
    "final_price": 2500000
  }
]
```

### Setelah Processing (catalogItemsWithPrice)
```dart
[
  {
    'name': 'Backdrop Premium',
    'original_price': 500000.0,
    'final_price': 500000.0,
    'formatted_original_price': 'Rp 500.000',
    'formatted_final_price': 'Rp 500.000',
  },
  {
    'name': 'Panggung Portable',
    'original_price': 1500000.0,
    'final_price': 2500000.0,
    'formatted_original_price': 'Rp 1.500.000',
    'formatted_final_price': 'Rp 2.500.000',
  }
]
```

## 🐛 Debug Logging

Tambahkan di console untuk troubleshooting:
```
✅ catalog_items loaded: [...]
⚠️ catalog_items is null
✅ catalogDetails found: 2 items
Item: Backdrop Premium, original: 500000, final: 500000
```

## ✅ Test Checklist

- [ ] Invoice detail page menampilkan tabel produk
- [ ] Harga original dan final terlihat per item
- [ ] Jika ada discount, harga original dicoret & final hijau
- [ ] PDF invoice menampilkan tabel produk dengan benar
- [ ] Email invoice menampilkan 3 kolom harga
- [ ] Mobile responsive (harga original di bawah jika perlu)
- [ ] Jika tidak ada catalog_items, tampilkan "-" (tidak error)

## 🔍 Troubleshooting

### Masalah: catalogDetails masih null
**Solusi:**
1. Cek console log: "⚠️ catalog_items is null"
2. Cek database: `SELECT catalog_items FROM request_orders WHERE id = '[request_order_id]'`
3. Pastikan `catalog_items` adalah JSON string atau array
4. Pastikan field `request_order_id` ada di invoice

### Masalah: Harga tidak muncul (0 atau blank)
**Solusi:**
1. Cek field name: `original_price` & `final_price` (bukan `price_estimation`)
2. Cek tipe data: harus number, bukan string
3. Cek parsing: pastikan `(item['original_price'] as num?)?.toDouble()` berhasil

### Masalah: Error "type 'String' is not a subtype of type 'List'"
**Solusi:**
- catalog_items di database adalah JSON string
- Sudah di-handle dengan `jsonDecode()`
- Pastikan import `dart:convert`

## 📝 Notes

- Jika `final_price` tidak ada, default ke `original_price`
- Jika `original_price` juga tidak ada, default ke `price_estimation`
- Jika semua tidak ada, default ke 0
- Field `catalog_id` tidak ditampilkan di UI (hanya untuk reference)

## 🚀 Deployment

Setelah update:
1. Hot reload/restart app
2. Test dengan invoice yang sudah ada
3. Jika masih tidak muncul, cek console log
4. Pastikan request_orders memiliki data catalog_items

---
**Updated:** 31 December 2025
**Version:** 2.0
