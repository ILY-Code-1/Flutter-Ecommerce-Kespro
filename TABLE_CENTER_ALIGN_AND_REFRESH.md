# TABLE CENTER ALIGNMENT & CATALOG REFRESH BUTTON

## 🎯 **PERUBAHAN YANG DILAKUKAN:**

### **1. Center Alignment pada Tabel Request Order**
### **2. Center Alignment pada Tabel Invoice**
### **3. Button Refresh pada Halaman Katalog**

---

## 📊 **1. CENTER ALIGNMENT - REQUEST ORDER TABLE**

### **A. Header (Line ~643-698)**

**Perubahan:**
```dart
// SEBELUM
Expanded(
  flex: 2,
  child: Text(
    'ID Request',
    style: TextStyle(...),
  ),
),

// SESUDAH
Expanded(
  flex: 2,
  child: Text(
    'ID Request',
    textAlign: TextAlign.center,  // ← TAMBAHKAN
    style: TextStyle(...),
  ),
),
```

**Diterapkan pada:**
- ✅ ID Request
- ✅ Nama Event Organizer
- ✅ Email
- ✅ Status
- ✅ Aksi (sudah center dari sebelumnya)

---

### **B. Rows/Values (Line ~725-780)**

**Perubahan:**
```dart
// SEBELUM
Expanded(
  flex: 2,
  child: Text(
    order.id,
    style: const TextStyle(...),
    overflow: TextOverflow.ellipsis,
  ),
),

// SESUDAH
Expanded(
  flex: 2,
  child: Text(
    order.id,
    textAlign: TextAlign.center,  // ← TAMBAHKAN
    style: const TextStyle(...),
    overflow: TextOverflow.ellipsis,
  ),
),
```

**Status Badge:**
```dart
// SEBELUM
Expanded(
  flex: 2,
  child: _buildStatusBadge(...),
),

// SESUDAH
Expanded(
  flex: 2,
  child: Center(  // ← WRAP DENGAN CENTER
    child: _buildStatusBadge(...),
  ),
),
```

**Diterapkan pada:**
- ✅ ID Request (text)
- ✅ Nama EO (text)
- ✅ Email (text)
- ✅ Status (badge wrapped in Center)
- ✅ Aksi (sudah Center dari sebelumnya)

---

## 📋 **2. CENTER ALIGNMENT - INVOICE TABLE**

### **A. Header (Line ~1089-1156)**

**Perubahan:**
Sama seperti Request Order, tambahkan `textAlign: TextAlign.center` pada semua kolom header.

**Diterapkan pada:**
- ✅ ID Invoice
- ✅ Nama Event Organizer
- ✅ Email
- ✅ Total
- ✅ Status
- ✅ Aksi (sudah center)

---

### **B. Rows/Values (Line ~1186-1250)**

**Perubahan:**
```dart
// Text columns
Expanded(
  flex: 2,
  child: Text(
    invoice.invoiceNumber,
    textAlign: TextAlign.center,  // ← TAMBAHKAN
    style: const TextStyle(...),
    overflow: TextOverflow.ellipsis,
  ),
),

// Status badge
Expanded(
  flex: 2,
  child: Center(  // ← WRAP DENGAN CENTER
    child: _buildStatusBadge(...),
  ),
),
```

**Diterapkan pada:**
- ✅ ID Invoice (text)
- ✅ Nama EO (text)
- ✅ Email (text)
- ✅ Total (text)
- ✅ Status (badge wrapped in Center)
- ✅ Aksi (sudah Center)

---

## 🔄 **3. BUTTON REFRESH - HALAMAN KATALOG**

### **A. Update _buildCatalogContent (Line ~212-243)**

**Tambahkan action bar:**
```dart
child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    _buildHeader(...),
    // Action bar with refresh button
    _buildCatalogActionBar(catalogController, isMobile),  // ← TAMBAH BARIS INI
    Expanded(...),
  ],
),
```

---

### **B. Tambah Method _buildCatalogActionBar (Line ~342-382)**

**Method baru:**
```dart
Widget _buildCatalogActionBar(
  CatalogController catalogController,
  bool isMobile,
) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: isMobile ? 16 : 32,
      vertical: 12,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Obx(() => ElevatedButton.icon(
          onPressed: catalogController.isLoading.value
              ? null
              : catalogController.fetchCatalogs,
          icon: catalogController.isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh, size: 18, color: Colors.white),
          label: Text(
            isMobile ? '' : 'Refresh',
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        )),
      ],
    ),
  );
}
```

**Fitur:**
- ✅ Button posisi kanan (MainAxisAlignment.end)
- ✅ Loading indicator saat refresh
- ✅ Disabled saat loading
- ✅ Responsive (hide text on mobile)
- ✅ Consistent styling dengan Request Order & Invoice

---

## 🎨 **VISUAL RESULT:**

### **Before:**
```
┌──────────────────────────────────────────────┐
│ ID Request  │ Nama EO  │  Email  │  Status  │  ← Text align left
├──────────────────────────────────────────────┤
│ REQ001      │ John     │  j@...  │  Masuk   │  ← Text align left
└──────────────────────────────────────────────┘
```

### **After:**
```
┌──────────────────────────────────────────────┐
│  ID Request │  Nama EO │  Email  │  Status  │  ← Text align center
├──────────────────────────────────────────────┤
│   REQ001    │   John   │  j@...  │  Masuk   │  ← Text align center
└──────────────────────────────────────────────┘
```

---

## 📱 **CATALOG REFRESH BUTTON:**

### **Before:**
```
┌────────────────────────────────────┐
│  MANAJEMEN KATALOG                 │
├────────────────────────────────────┤
│  (no action bar)                   │
│  [Catalog Cards...]                │
└────────────────────────────────────┘
```

### **After:**
```
┌────────────────────────────────────┐
│  MANAJEMEN KATALOG                 │
├────────────────────────────────────┤
│                    [🔄 Refresh]    │  ← NEW!
├────────────────────────────────────┤
│  [Catalog Cards...]                │
└────────────────────────────────────┘
```

---

## ✅ **CHECKLIST PERUBAHAN:**

### **Request Order Table:**
- ✅ Header text center (5 columns)
- ✅ Row values text center (4 text columns)
- ✅ Status badge wrapped in Center
- ✅ Action button (already centered)

### **Invoice Table:**
- ✅ Header text center (6 columns)
- ✅ Row values text center (5 text columns)
- ✅ Status badge wrapped in Center
- ✅ Action button (already centered)

### **Catalog Page:**
- ✅ Added action bar container
- ✅ Added _buildCatalogActionBar method
- ✅ Refresh button with loading state
- ✅ Responsive (hide text on mobile)
- ✅ Consistent styling

---

## 🔧 **FILES MODIFIED:**

**1. admin_dashboard_page.dart**
- Line ~643-698: Request Order header (add textAlign)
- Line ~725-780: Request Order rows (add textAlign + Center)
- Line ~1089-1156: Invoice header (add textAlign)
- Line ~1186-1250: Invoice rows (add textAlign + Center)
- Line ~212-243: Catalog content (add action bar)
- Line ~342-382: New method _buildCatalogActionBar

---

## 📝 **NOTES:**

### **Text Alignment:**
- Menggunakan `textAlign: TextAlign.center` untuk Text widgets
- Menggunakan `Center()` widget untuk non-text widgets (status badge, buttons)

### **Status Badge:**
- Tidak bisa pakai `textAlign` langsung karena custom widget
- Harus wrap dengan `Center()` widget

### **Mobile Responsive:**
- Refresh button text hidden on mobile (space saving)
- Icon tetap visible
- Padding adjusted untuk mobile/desktop

### **Consistency:**
- Refresh button styling sama dengan Request Order & Invoice
- Loading state handling sama
- Button position (right aligned)

---

## 🎯 **BENEFIT:**

1. ✅ **Better Visual Alignment**
   - Table lebih rapi dan profesional
   - Data mudah dibaca (center aligned)
   - Consistent dengan best practices

2. ✅ **Catalog Refresh Feature**
   - User bisa refresh data katalog
   - Tidak perlu reload page
   - Loading indicator jelas

3. ✅ **Consistency Across Pages**
   - Semua table menggunakan center alignment
   - Semua admin page punya refresh button
   - Uniform user experience

---

**Updated:** 05 January 2026  
**Version:** 1.0  
**Status:** ✅ Production Ready
