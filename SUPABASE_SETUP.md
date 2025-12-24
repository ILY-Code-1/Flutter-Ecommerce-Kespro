# Supabase Setup Guide - Katalog CRUD dengan Soft Delete & Upload Gambar

## Daftar Isi
1. [Konfigurasi Project](#1-konfigurasi-project)
2. [Membuat Tabel Katalog](#2-membuat-tabel-katalog)
3. [Konfigurasi Storage untuk Gambar](#3-konfigurasi-storage-untuk-gambar)
4. [Row Level Security (RLS)](#4-row-level-security-rls)
5. [Konfigurasi Flutter](#5-konfigurasi-flutter)

---

## 1. Konfigurasi Project

### 1.1 Dapatkan Kredensial Supabase
1. Buka [Supabase Dashboard](https://supabase.com/dashboard)
2. Pilih project Anda (atau buat baru)
3. Pergi ke **Settings** > **API**
4. Salin:
   - **Project URL** (contoh: `https://xxxxx.supabase.co`)
   - **anon public key** (contoh: `eyJhbGciOiJIUzI1NiIsInR5cCI6...`)

### 1.2 Update File Konfigurasi Flutter
Buka file `lib/core/config/supabase_config.dart` dan ganti:

```dart
static const String supabaseUrl = 'https://YOUR-PROJECT-ID.supabase.co';
static const String supabaseAnonKey = 'YOUR-ANON-KEY-HERE';
```

---

## 2. Membuat Tabel Katalog

### 2.1 Buka SQL Editor
1. Di Supabase Dashboard, pergi ke **SQL Editor**
2. Klik **New Query**
3. Jalankan query-query berikut secara berurutan

### 2.2 Query: Membuat Tabel `catalogs`

```sql
-- =============================================
-- TABEL KATALOG DENGAN SOFT DELETE
-- =============================================

-- Membuat tabel catalogs
CREATE TABLE IF NOT EXISTS public.catalogs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price_estimation DECIMAL(15, 2) NOT NULL DEFAULT 0,
    image_url TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tambahkan komentar pada tabel
COMMENT ON TABLE public.catalogs IS 'Tabel untuk menyimpan data katalog produk sewa';
COMMENT ON COLUMN public.catalogs.id IS 'Primary key UUID';
COMMENT ON COLUMN public.catalogs.name IS 'Nama produk katalog';
COMMENT ON COLUMN public.catalogs.price_estimation IS 'Estimasi harga sewa';
COMMENT ON COLUMN public.catalogs.image_url IS 'URL gambar produk dari Supabase Storage';
COMMENT ON COLUMN public.catalogs.description IS 'Deskripsi produk';
COMMENT ON COLUMN public.catalogs.is_active IS 'Status aktif produk (tampil di landing page)';
COMMENT ON COLUMN public.catalogs.deleted_at IS 'Timestamp soft delete (NULL = tidak dihapus)';
COMMENT ON COLUMN public.catalogs.created_at IS 'Timestamp pembuatan';
COMMENT ON COLUMN public.catalogs.updated_at IS 'Timestamp update terakhir';
```

### 2.3 Query: Membuat Index untuk Performa

```sql
-- =============================================
-- INDEX UNTUK OPTIMASI QUERY
-- =============================================

-- Index untuk soft delete (query yang sering digunakan)
CREATE INDEX IF NOT EXISTS idx_catalogs_deleted_at ON public.catalogs(deleted_at);

-- Index untuk status aktif
CREATE INDEX IF NOT EXISTS idx_catalogs_is_active ON public.catalogs(is_active);

-- Index gabungan untuk query landing page (aktif dan tidak dihapus)
CREATE INDEX IF NOT EXISTS idx_catalogs_active_not_deleted 
ON public.catalogs(is_active, deleted_at) 
WHERE deleted_at IS NULL AND is_active = true;

-- Index untuk sorting berdasarkan created_at
CREATE INDEX IF NOT EXISTS idx_catalogs_created_at ON public.catalogs(created_at DESC);
```

### 2.4 Query: Membuat Function untuk Auto-Update `updated_at`

```sql
-- =============================================
-- FUNCTION & TRIGGER UNTUK AUTO UPDATE TIMESTAMP
-- =============================================

-- Function untuk update timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger untuk tabel catalogs
DROP TRIGGER IF EXISTS set_catalogs_updated_at ON public.catalogs;
CREATE TRIGGER set_catalogs_updated_at
    BEFORE UPDATE ON public.catalogs
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
```

### 2.5 Query: Membuat Function untuk Soft Delete

```sql
-- =============================================
-- FUNCTION UNTUK SOFT DELETE
-- =============================================

-- Function untuk soft delete catalog
CREATE OR REPLACE FUNCTION public.soft_delete_catalog(catalog_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.catalogs 
    SET deleted_at = NOW(), is_active = false
    WHERE id = catalog_id AND deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function untuk restore catalog yang di-soft delete
CREATE OR REPLACE FUNCTION public.restore_catalog(catalog_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.catalogs 
    SET deleted_at = NULL, is_active = true
    WHERE id = catalog_id AND deleted_at IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function untuk permanent delete (hanya jika sudah soft deleted)
CREATE OR REPLACE FUNCTION public.permanent_delete_catalog(catalog_id UUID)
RETURNS VOID AS $$
BEGIN
    DELETE FROM public.catalogs 
    WHERE id = catalog_id AND deleted_at IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 2.6 Query: Membuat View untuk Query yang Sering Digunakan

```sql
-- =============================================
-- VIEWS UNTUK KEMUDAHAN QUERY
-- =============================================

-- View untuk katalog aktif (untuk landing page)
CREATE OR REPLACE VIEW public.active_catalogs AS
SELECT 
    id,
    name,
    price_estimation,
    image_url,
    description,
    created_at,
    updated_at
FROM public.catalogs
WHERE deleted_at IS NULL AND is_active = true
ORDER BY created_at DESC;

-- View untuk semua katalog (termasuk yang tidak aktif, untuk admin)
CREATE OR REPLACE VIEW public.all_catalogs AS
SELECT 
    id,
    name,
    price_estimation,
    image_url,
    description,
    is_active,
    deleted_at,
    created_at,
    updated_at,
    CASE 
        WHEN deleted_at IS NOT NULL THEN 'deleted'
        WHEN is_active = false THEN 'inactive'
        ELSE 'active'
    END as status
FROM public.catalogs
WHERE deleted_at IS NULL
ORDER BY created_at DESC;

-- View untuk katalog yang sudah dihapus (trash)
CREATE OR REPLACE VIEW public.deleted_catalogs AS
SELECT 
    id,
    name,
    price_estimation,
    image_url,
    description,
    deleted_at,
    created_at
FROM public.catalogs
WHERE deleted_at IS NOT NULL
ORDER BY deleted_at DESC;
```

### 2.7 Query: Insert Data Dummy (Opsional)

```sql
-- =============================================
-- DATA DUMMY UNTUK TESTING
-- =============================================

INSERT INTO public.catalogs (name, price_estimation, description, is_active) VALUES
('Backdrop Premium', 500000, 'Backdrop berkualitas tinggi untuk berbagai acara', true),
('Panggung Portable', 1500000, 'Panggung portable ukuran 4x6 meter', true),
('Tenda Dekorasi', 2000000, 'Tenda dekorasi untuk outdoor event', true),
('Sound System Pro', 3000000, 'Paket sound system profesional 5000 watt', true),
('Lighting Package', 1200000, 'Paket lampu LED dan moving head', true),
('Kursi & Meja Set', 800000, 'Set 50 kursi dan 10 meja bundar', true),
('Dekorasi Bunga', 1000000, 'Dekorasi bunga segar untuk pelaminan', true),
('AC Portable', 750000, 'AC portable untuk tenda outdoor', true);
```

---

## 3. Konfigurasi Storage untuk Gambar

### 3.1 Membuat Bucket Storage

```sql
-- =============================================
-- MEMBUAT STORAGE BUCKET UNTUK GAMBAR KATALOG
-- =============================================

-- Jalankan di SQL Editor
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'catalog-images',
    'catalog-images',
    true,  -- Public bucket agar gambar bisa diakses tanpa auth
    5242880,  -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 5242880,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
```

### 3.2 Storage Policies untuk Bucket

```sql
-- =============================================
-- STORAGE POLICIES UNTUK CATALOG-IMAGES BUCKET
-- =============================================

-- Policy: Semua orang bisa melihat gambar (public read)
CREATE POLICY "Public can view catalog images"
ON storage.objects FOR SELECT
USING (bucket_id = 'catalog-images');

-- Policy: Authenticated users (admin) bisa upload gambar
CREATE POLICY "Authenticated users can upload catalog images"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'catalog-images'
    AND auth.role() = 'authenticated'
);

-- Policy: Authenticated users (admin) bisa update gambar
CREATE POLICY "Authenticated users can update catalog images"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'catalog-images'
    AND auth.role() = 'authenticated'
);

-- Policy: Authenticated users (admin) bisa delete gambar
CREATE POLICY "Authenticated users can delete catalog images"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'catalog-images'
    AND auth.role() = 'authenticated'
);
```

### 3.3 Alternatif: Buat Bucket via Dashboard
1. Pergi ke **Storage** di Supabase Dashboard
2. Klik **New Bucket**
3. Nama: `catalog-images`
4. Centang **Public bucket**
5. Klik **Create bucket**
6. Klik bucket yang baru dibuat
7. Pergi ke tab **Policies**
8. Tambahkan policies sesuai kebutuhan

---

## 4. Row Level Security (RLS)

### 4.1 Enable RLS pada Tabel Catalogs

```sql
-- =============================================
-- ENABLE ROW LEVEL SECURITY
-- =============================================

-- Enable RLS
ALTER TABLE public.catalogs ENABLE ROW LEVEL SECURITY;
```

### 4.2 RLS Policies untuk Tabel Catalogs

```sql
-- =============================================
-- RLS POLICIES UNTUK TABEL CATALOGS
-- =============================================

-- Policy: Public dapat membaca katalog yang aktif (untuk landing page)
CREATE POLICY "Public can read active catalogs"
ON public.catalogs FOR SELECT
USING (
    deleted_at IS NULL 
    AND is_active = true
);

-- Policy: Authenticated users (admin) dapat membaca semua katalog
CREATE POLICY "Admins can read all catalogs"
ON public.catalogs FOR SELECT
USING (auth.role() = 'authenticated');

-- Policy: Authenticated users (admin) dapat insert katalog baru
CREATE POLICY "Admins can insert catalogs"
ON public.catalogs FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authenticated users (admin) dapat update katalog
CREATE POLICY "Admins can update catalogs"
ON public.catalogs FOR UPDATE
USING (auth.role() = 'authenticated');

-- Policy: Authenticated users (admin) dapat delete katalog
CREATE POLICY "Admins can delete catalogs"
ON public.catalogs FOR DELETE
USING (auth.role() = 'authenticated');
```

### 4.3 Alternatif: Disable RLS untuk Development

```sql
-- =============================================
-- DISABLE RLS (HANYA UNTUK DEVELOPMENT!)
-- =============================================

-- PERINGATAN: Jangan gunakan di production!
-- Gunakan ini hanya jika ingin testing tanpa auth

ALTER TABLE public.catalogs DISABLE ROW LEVEL SECURITY;
```

---

## 5. Konfigurasi Flutter

### 5.1 Update Supabase Config

Setelah mendapatkan kredensial, update file `lib/core/config/supabase_config.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Ganti dengan kredensial Anda
  static const String supabaseUrl = 'https://YOUR-PROJECT-ID.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
}
```

---

## Query Reference Cepat

### Mengambil Katalog Aktif (Landing Page)
```sql
SELECT * FROM active_catalogs;
-- atau
SELECT * FROM catalogs WHERE deleted_at IS NULL AND is_active = true ORDER BY created_at DESC;
```

### Mengambil Semua Katalog (Admin)
```sql
SELECT * FROM all_catalogs;
```

### Soft Delete Katalog
```sql
SELECT soft_delete_catalog('catalog-uuid-here');
-- atau
UPDATE catalogs SET deleted_at = NOW(), is_active = false WHERE id = 'catalog-uuid-here';
```

### Restore Katalog
```sql
SELECT restore_catalog('catalog-uuid-here');
```

### Mendapatkan URL Gambar dari Storage
```
https://YOUR-PROJECT-ID.supabase.co/storage/v1/object/public/catalog-images/nama-file.jpg
```

---

## Checklist Setup

- [ ] Buat project di Supabase
- [ ] Salin URL dan anon key
- [ ] Jalankan query membuat tabel `catalogs`
- [ ] Jalankan query membuat indexes
- [ ] Jalankan query membuat function `handle_updated_at`
- [ ] Jalankan query membuat functions soft delete
- [ ] Jalankan query membuat views
- [ ] Buat storage bucket `catalog-images`
- [ ] Setup storage policies
- [ ] Enable RLS dan buat policies
- [ ] Update `supabase_config.dart` dengan kredensial
- [ ] Test dengan data dummy
- [ ] Jalankan `flutter pub get`
- [ ] Test aplikasi

---

## Troubleshooting

### Error: "permission denied for table catalogs"
- Pastikan RLS policies sudah dibuat dengan benar
- Atau disable RLS sementara untuk testing

### Error: "new row violates row-level security policy"
- User tidak memiliki permission untuk operasi tersebut
- Pastikan user sudah authenticated untuk operasi admin

### Gambar tidak muncul
- Pastikan bucket `catalog-images` sudah public
- Cek storage policies
- Pastikan URL gambar benar

### Query lambat
- Pastikan indexes sudah dibuat
- Gunakan view `active_catalogs` untuk landing page
