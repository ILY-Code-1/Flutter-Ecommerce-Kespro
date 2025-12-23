import 'package:get/get.dart';

class OrderController extends GetxController {
  final namaEO = ''.obs;
  final email = ''.obs;
  final produk = ''.obs;
  final tanggalMulai = Rxn<DateTime>();
  final lokasi = ''.obs;
  final durasi = ''.obs;
  final catatan = ''.obs;

  final produkList = [
    'Backdrop',
    'Panggung',
    'Tenant/Booth',
    'Sound System',
    'Lighting',
    'Kursi & Meja',
    'Dekorasi',
    'Lainnya',
  ];

  final durasiList = [
    '1 Hari',
    '2-3 Hari',
    '1 Minggu',
    'Lebih dari 1 Minggu',
  ];

  void submitOrder() {
    // Dummy submit - just navigate to success
    Get.toNamed('/success');
  }
}
