import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/responsive_wrapper.dart';
import 'order_controller.dart';

class OrderPage extends GetView<OrderController> {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWrapper.isMobile(context);

    return Scaffold(
      endDrawer: const AppDrawer(),
      body: Column(
        children: [
          const NavBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ResponsiveWrapper(
                maxWidth: 800,
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 24 : 48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'FORM ORDER',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        label: 'Nama Event Organizer',
                        hint: 'Masukkan nama EO',
                        onChanged: (val) => controller.namaEO.value = val,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Email',
                        hint: 'Masukkan email',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) => controller.email.value = val,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown(
                        label: 'Produk yang Dipesan',
                        items: controller.produkList,
                        onChanged: (val) => controller.produk.value = val ?? '',
                      ),
                      const SizedBox(height: 20),
                      _buildDatePicker(context),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Lokasi',
                        hint: 'Masukkan lokasi event',
                        onChanged: (val) => controller.lokasi.value = val,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown(
                        label: 'Durasi Sewa',
                        items: controller.durasiList,
                        onChanged: (val) => controller.durasi.value = val ?? '',
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Catatan Tambahan',
                        hint: 'Masukkan catatan atau keperluan khusus',
                        maxLines: 4,
                        onChanged: (val) => controller.catatan.value = val,
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: 'PROSES ORDER',
                        backgroundColor: AppTheme.primaryColor,
                        onPressed: controller.submitOrder,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          hint: const Text('Pilih opsi'),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Mulai',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  controller.tanggalMulai.value = date;
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.tanggalMulai.value != null
                          ? '${controller.tanggalMulai.value!.day}/${controller.tanggalMulai.value!.month}/${controller.tanggalMulai.value!.year}'
                          : 'Pilih tanggal',
                      style: TextStyle(
                        color: controller.tanggalMulai.value != null
                            ? AppTheme.textPrimary
                            : Colors.grey,
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
