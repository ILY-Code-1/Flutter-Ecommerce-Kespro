-- =============================================
-- DROP JADWAL SEWA (RENTAL SCHEDULES)
-- =============================================
-- Jalankan query ini di Supabase SQL Editor untuk menghapus
-- semua data dan struktur terkait Jadwal Sewa

-- 1. Drop view terlebih dahulu (karena bergantung pada table)
DROP VIEW IF EXISTS public.v_rental_schedules_full;

-- 2. Drop function yang terkait jadwal sewa
DROP FUNCTION IF EXISTS public.create_rental_schedules_from_request(UUID);
DROP FUNCTION IF EXISTS public.check_catalog_availability(UUID, DATE, DATE, UUID);

-- 3. Drop trigger
DROP TRIGGER IF EXISTS trigger_update_rental_schedules_updated_at ON public.rental_schedules;

-- 4. Drop function untuk trigger
DROP FUNCTION IF EXISTS public.update_rental_schedules_updated_at();

-- 5. Drop RLS policies
DROP POLICY IF EXISTS "Anyone can read rental_schedules" ON public.rental_schedules;
DROP POLICY IF EXISTS "Anyone can insert rental_schedules" ON public.rental_schedules;
DROP POLICY IF EXISTS "Anyone can update rental_schedules" ON public.rental_schedules;
DROP POLICY IF EXISTS "Anyone can delete rental_schedules" ON public.rental_schedules;

-- 6. Drop table (ini akan menghapus semua data!)
DROP TABLE IF EXISTS public.rental_schedules;

-- =============================================
-- VERIFICATION
-- =============================================
-- Jalankan query berikut untuk memastikan sudah terhapus:
-- SELECT * FROM information_schema.tables WHERE table_name = 'rental_schedules';
-- Harus return 0 rows

-- =============================================
-- CATATAN
-- =============================================
-- Query ini TIDAK menghapus:
-- - Tabel request_orders (tetap ada)
-- - Tabel invoices (tetap ada)
-- - View v_request_orders_full (tetap ada)
-- - View v_invoices_full (tetap ada)
