import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../models/catalog_model.dart';

/// Repository untuk operasi CRUD Katalog dengan Supabase
/// Mendukung Soft Delete dan Upload Gambar
/// 
/// Access Control:
/// - READ (active): Public & Admin
/// - READ (all): Admin only
/// - CREATE/UPDATE/DELETE: Admin only
class CatalogRepository {
  static const String _tableName = 'catalogs';
  static const String _storageBucket = 'catalog-images';

  // ==========================================
  // READ OPERATIONS
  // ==========================================

  /// Fetch katalog aktif untuk Landing Page (Public)
  /// Hanya menampilkan yang tidak di-soft delete dan is_active = true
  Future<List<CatalogModel>> fetchActiveForLandingPage() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .isFilter('deleted_at', null)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CatalogModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data katalog: $e');
    }
  }

  /// Fetch semua katalog untuk Admin (termasuk inactive, exclude soft deleted)
  Future<List<CatalogModel>> fetchAll() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CatalogModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data katalog: $e');
    }
  }

  /// Fetch katalog yang sudah di-soft delete (Trash) untuk Admin
  Future<List<CatalogModel>> fetchDeleted() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .not('deleted_at', 'is', null)
          .order('deleted_at', ascending: false);

      return (response as List)
          .map((json) => CatalogModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data katalog terhapus: $e');
    }
  }

  /// Fetch katalog by ID (Admin only)
  Future<CatalogModel?> fetchById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return CatalogModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail katalog: $e');
    }
  }

  // ==========================================
  // CREATE OPERATION
  // ==========================================

  /// Create katalog baru (Admin only)
  Future<CatalogModel> create({
    required String name,
    required double priceEstimation,
    String? imageUrl,
    String? description,
    bool isActive = true,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert({
            'name': name,
            'price_estimation': priceEstimation,
            'image_url': imageUrl,
            'description': description,
            'is_active': isActive,
          })
          .select()
          .single();

      return CatalogModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menambah katalog: $e');
    }
  }

  // ==========================================
  // UPDATE OPERATIONS
  // ==========================================

  /// Update katalog (Admin only)
  Future<CatalogModel> update({
    required String id,
    required String name,
    required double priceEstimation,
    String? imageUrl,
    String? description,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'name': name,
        'price_estimation': priceEstimation,
      };
      
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (description != null) updateData['description'] = description;
      if (isActive != null) updateData['is_active'] = isActive;

      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .isFilter('deleted_at', null) // Hanya update yang belum dihapus
          .select()
          .single();

      return CatalogModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate katalog: $e');
    }
  }

  /// Toggle status aktif katalog (Admin only)
  Future<CatalogModel> toggleActive(String id, bool isActive) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update({'is_active': isActive})
          .eq('id', id)
          .isFilter('deleted_at', null)
          .select()
          .single();

      return CatalogModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengubah status katalog: $e');
    }
  }

  // ==========================================
  // DELETE OPERATIONS (SOFT DELETE)
  // ==========================================

  /// Soft delete katalog (Admin only)
  /// Set deleted_at = NOW() dan is_active = false
  Future<void> softDelete(String id) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'is_active': false,
          })
          .eq('id', id)
          .isFilter('deleted_at', null);
    } catch (e) {
      throw Exception('Gagal menghapus katalog: $e');
    }
  }

  /// Restore katalog yang sudah di-soft delete (Admin only)
  Future<CatalogModel> restore(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update({
            'deleted_at': null,
            'is_active': true,
          })
          .eq('id', id)
          .not('deleted_at', 'is', null)
          .select()
          .single();

      return CatalogModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal memulihkan katalog: $e');
    }
  }

  /// Permanent delete katalog (Admin only)
  /// Hanya bisa delete yang sudah di-soft delete
  Future<void> permanentDelete(String id) async {
    try {
      // Ambil data dulu untuk hapus gambar
      final catalog = await fetchById(id);
      
      // Hapus dari database
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', id)
          .not('deleted_at', 'is', null); // Hanya hapus yang sudah soft deleted

      // Hapus gambar dari storage jika ada
      if (catalog?.imageUrl != null && catalog!.imageUrl!.isNotEmpty) {
        try {
          await deleteImage(catalog.imageUrl!);
        } catch (_) {
          // Ignore error jika gambar tidak ditemukan
        }
      }
    } catch (e) {
      throw Exception('Gagal menghapus permanen katalog: $e');
    }
  }

  // ==========================================
  // IMAGE OPERATIONS
  // ==========================================

  /// Upload gambar katalog ke Supabase Storage (Admin only)
  /// Returns the public URL of uploaded image
  Future<String> uploadImage({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName.split('.').last.toLowerCase();
      final path = 'catalog_${timestamp}_${fileName.hashCode}.$extension';
      
      await SupabaseConfig.client.storage
          .from(_storageBucket)
          .uploadBinary(
            path, 
            fileBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final publicUrl = SupabaseConfig.client.storage
          .from(_storageBucket)
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Gagal mengupload gambar: $e');
    }
  }

  /// Delete gambar dari Supabase Storage (Admin only)
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract path dari URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // Path biasanya: storage/v1/object/public/bucket-name/file-name
      // Kita ambil bagian terakhir sebagai file name
      final fileName = pathSegments.last;

      await SupabaseConfig.client.storage
          .from(_storageBucket)
          .remove([fileName]);
    } catch (e) {
      throw Exception('Gagal menghapus gambar: $e');
    }
  }

  /// Update gambar katalog (hapus yang lama, upload yang baru)
  Future<String> updateImage({
    required String? oldImageUrl,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    // Hapus gambar lama jika ada
    if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
      try {
        await deleteImage(oldImageUrl);
      } catch (_) {
        // Ignore error jika gambar lama tidak ditemukan
      }
    }

    // Upload gambar baru
    return await uploadImage(fileName: fileName, fileBytes: fileBytes);
  }
}
