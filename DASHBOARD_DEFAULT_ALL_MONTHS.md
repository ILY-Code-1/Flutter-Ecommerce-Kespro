# DASHBOARD DEFAULT FILTER - SEMUA BULAN

## 🎯 **TUJUAN:**
Mengubah default value filter bulan di dashboard admin dari "Bulan Ini" menjadi **"Semua Bulan"** agar menampilkan total rekapan keseluruhan.

---

## 🔧 **PERUBAHAN YANG DILAKUKAN:**

### **1. admin_dashboard_controller.dart**

#### **A. onInit() - Line 86-91**

**SEBELUM:**
```dart
@override
void onInit() {
  super.onInit();
  // Default ke bulan ini
  selectedMonth.value = DateTime(DateTime.now().year, DateTime.now().month);
  fetchDashboardData();
}
```

**SESUDAH:**
```dart
@override
void onInit() {
  super.onInit();
  // Default ke semua bulan (null = no filter)
  selectedMonth.value = null;
  fetchDashboardData();
}
```

**Impact:**
- ✅ Default value sekarang `null` (tidak ada filter bulan)
- ✅ Menampilkan total keseluruhan data

---

#### **B. fetchStats() - Line 110-162**

**SEBELUM:**
```dart
Future<void> fetchStats() async {
  try {
    isLoadingStats.value = true;

    final month = selectedMonth.value ?? DateTime.now();
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    // Fetch orders for current month
    final ordersResponse = await _supabase
        .from('request_orders')
        .select('id, status')
        .isFilter('deleted_at', null)
        .gte('created_at', startOfMonth.toIso8601String())
        .lte('created_at', endOfMonth.toIso8601String());
    
    // ... rest of code
  }
}
```

**Masalah:**
- ❌ Selalu filter by date (bahkan jika null, default ke bulan ini)
- ❌ Tidak bisa tampilkan semua data

---

**SESUDAH:**
```dart
Future<void> fetchStats() async {
  try {
    isLoadingStats.value = true;

    // Build query for orders
    var ordersQuery = _supabase
        .from('request_orders')
        .select('id, status')
        .isFilter('deleted_at', null);

    // Add date filter only if month is selected
    if (selectedMonth.value != null) {
      final month = selectedMonth.value!;
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      ordersQuery = ordersQuery
          .gte('created_at', startOfMonth.toIso8601String())
          .lte('created_at', endOfMonth.toIso8601String());
    }

    final ordersResponse = await ordersQuery;
    
    // ... rest of code (same for invoices query)
  }
}
```

**Penjelasan:**
1. Build query tanpa filter tanggal terlebih dahulu
2. **Conditional filter**: Hanya apply filter tanggal jika `selectedMonth.value != null`
3. Jika `null` → fetch semua data tanpa filter bulan
4. Jika ada value → filter by bulan tersebut

**Impact:**
- ✅ Support "Semua Bulan" (null value)
- ✅ Support filter per bulan (non-null value)
- ✅ Flexible & clean

---

#### **C. changeMonth() - Line 238-242**

**SEBELUM:**
```dart
void changeMonth(DateTime? month) {
  selectedMonth.value = month ?? DateTime(DateTime.now().year, DateTime.now().month);
  fetchStats();
}
```

**Masalah:**
- ❌ Jika user pilih "Semua Bulan" (null), akan di-override ke bulan ini

---

**SESUDAH:**
```dart
void changeMonth(DateTime? month) {
  selectedMonth.value = month;  // Keep null if null
  fetchStats();
}
```

**Impact:**
- ✅ Null tetap null (tidak di-override)
- ✅ User bisa pilih "Semua Bulan"

---

#### **D. monthLabel getter - Line 244-248**

**SEBELUM:**
```dart
String get monthLabel {
  if (selectedMonth.value == null) return 'Bulan Ini';
  return DateFormat('MMMM yyyy').format(selectedMonth.value!);
}
```

**Masalah:**
- ❌ Null value display sebagai "Bulan Ini" (misleading)

---

**SESUDAH:**
```dart
String get monthLabel {
  if (selectedMonth.value == null) return 'Semua Bulan';
  return DateFormat('MMMM yyyy').format(selectedMonth.value!);
}
```

**Impact:**
- ✅ Null value display sebagai "Semua Bulan" (accurate)

---

### **2. admin_dashboard_page.dart**

#### **Month Filter Dropdown - Line 145-161**

**SEBELUM:**
```dart
child: DropdownButton<DateTime?>(
  value: controller.selectedMonth.value,
  hint: const Text('Pilih Bulan'),
  items: List.generate(12, (i) {
    final date = DateTime(
      DateTime.now().year,
      DateTime.now().month - i,
    );
    return DropdownMenuItem(
      value: date,
      child: Text(DateFormat('MMMM yyyy').format(date)),
    );
  }),
  onChanged: controller.changeMonth,
),
```

**Masalah:**
- ❌ Tidak ada opsi "Semua Bulan"
- ❌ Hanya ada 12 bulan terakhir

---

**SESUDAH:**
```dart
child: DropdownButton<DateTime?>(
  value: controller.selectedMonth.value,
  hint: const Text('Pilih Bulan'),
  items: [
    const DropdownMenuItem(
      value: null,
      child: Text('Semua Bulan'),
    ),
    ...List.generate(12, (i) {
      final date = DateTime(
        DateTime.now().year,
        DateTime.now().month - i,
      );
      return DropdownMenuItem(
        value: date,
        child: Text(DateFormat('MMMM yyyy').format(date)),
      );
    }),
  ],
  onChanged: controller.changeMonth,
),
```

**Impact:**
- ✅ Opsi "Semua Bulan" ditambahkan di awal list
- ✅ User bisa pilih semua bulan atau per bulan
- ✅ Default value menampilkan "Semua Bulan"

---

## 📊 **BEHAVIOR SEKARANG:**

### **Default (onInit):**
```
selectedMonth = null
Display: "Semua Bulan"
Query: SELECT * FROM ... WHERE deleted_at IS NULL
       (NO date filter)
Result: Total keseluruhan data
```

### **User Pilih Bulan Tertentu:**
```
selectedMonth = DateTime(2026, 1)
Display: "Januari 2026"
Query: SELECT * FROM ... WHERE deleted_at IS NULL
       AND created_at >= '2026-01-01'
       AND created_at <= '2026-01-31 23:59:59'
Result: Data bulan Januari 2026
```

### **User Pilih "Semua Bulan":**
```
selectedMonth = null
Display: "Semua Bulan"
Query: SELECT * FROM ... WHERE deleted_at IS NULL
       (NO date filter)
Result: Total keseluruhan data
```

---

## 🎯 **STAT CARDS BEHAVIOR:**

### **Request Orders:**
- Semua Bulan: Total semua request order
- Per Bulan: Total request order bulan tersebut

### **Pending Orders:**
- Semua Bulan: Total order dengan status "masuk" atau "negosiasi"
- Per Bulan: Total order dengan status tersebut di bulan terpilih

### **Completed Orders:**
- Semua Bulan: Total order dengan status "deal"
- Per Bulan: Total order deal di bulan terpilih

### **Active Catalogs:**
- **SELALU** total keseluruhan (tidak terpengaruh filter bulan)
- Karena catalog tidak terikat dengan bulan tertentu

### **Total Invoices:**
- Semua Bulan: Total semua invoice
- Per Bulan: Total invoice di bulan terpilih

### **Total Revenue:**
- Semua Bulan: Total dari semua invoice lunas
- Per Bulan: Total dari invoice lunas di bulan terpilih

---

## 🔄 **USER FLOW:**

1. **User masuk dashboard admin**
   - Display: "Semua Bulan"
   - Stat cards: Total keseluruhan data

2. **User klik dropdown bulan**
   - Tampil opsi: "Semua Bulan" (selected), Desember 2025, November 2025, ...

3. **User pilih bulan tertentu (misal: November 2025)**
   - Display: "November 2025"
   - Stat cards: Update ke data November 2025 saja

4. **User pilih "Semua Bulan" lagi**
   - Display: "Semua Bulan"
   - Stat cards: Update ke total keseluruhan

5. **User klik Refresh**
   - Re-fetch data sesuai filter yang sedang aktif
   - Snackbar: "Data dashboard diperbarui"

---

## ✅ **BENEFITS:**

1. **Better Default View**
   - ✅ Langsung lihat total keseluruhan
   - ✅ Lebih informatif untuk high-level overview
   - ✅ Tidak terbatas pada bulan berjalan

2. **Flexible Filtering**
   - ✅ Bisa lihat semua data
   - ✅ Bisa filter per bulan jika perlu detail
   - ✅ Easy switching antara views

3. **Clear Label**
   - ✅ "Semua Bulan" jelas maksudnya
   - ✅ User tahu sedang lihat data apa

4. **Better UX**
   - ✅ User tidak perlu scroll ke bawah untuk lihat total
   - ✅ Default view lebih useful
   - ✅ Consistent dengan expectation

---

## 📝 **TESTING CHECKLIST:**

- ✅ Default load menampilkan "Semua Bulan"
- ✅ Stat cards menampilkan total keseluruhan
- ✅ Dropdown menampilkan "Semua Bulan" as selected
- ✅ Bisa pilih bulan tertentu dan data update
- ✅ Bisa kembali ke "Semua Bulan" dari bulan tertentu
- ✅ Refresh button bekerja untuk both modes
- ✅ Activities tidak terpengaruh filter bulan (tetap recent)

---

## 🎨 **UI CHANGES:**

### **Dropdown Options:**
```
┌──────────────────────────┐
│  Semua Bulan         ✓   │  ← Default & NEW!
├──────────────────────────┤
│  Desember 2025           │
│  November 2025           │
│  Oktober 2025            │
│  ...                     │
└──────────────────────────┘
```

### **Display Label:**
```
Before: "Januari 2026" (bulan ini)
After:  "Semua Bulan" (keseluruhan)
```

---

## 📄 **FILES MODIFIED:**

1. **lib/modules/admin/dashboard/admin_dashboard_controller.dart**
   - Line 89: onInit() default value
   - Line 111-162: fetchStats() conditional filtering
   - Line 240: changeMonth() keep null as null
   - Line 246: monthLabel for null value

2. **lib/modules/admin/dashboard/admin_dashboard_page.dart**
   - Line 145-163: Dropdown items with "Semua Bulan" option

---

## 🚀 **DEPLOYMENT:**

**No Breaking Changes:**
- ✅ Backward compatible
- ✅ Existing filter functionality tetap bekerja
- ✅ Hanya mengubah default behavior

**No Migration Needed:**
- ✅ No database changes
- ✅ No API changes
- ✅ Pure UI/logic changes

---

**Updated:** 05 January 2026  
**Version:** 1.0  
**Status:** ✅ Production Ready  
**Impact:** Low Risk - UI Enhancement
