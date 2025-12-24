import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/responsive_wrapper.dart';
import '../../data/models/catalog_model.dart';
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
                maxWidth: 900,
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
                        'FORM REQUEST ORDER',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Isi form di bawah untuk melakukan request sewa peralatan event',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Section: Data Pemesan
                      _buildSectionTitle('Data Pemesan', Icons.person_rounded),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Nama Event Organizer *',
                        hint: 'Masukkan nama EO atau perusahaan',
                        controller: controller.namaEOController,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Email *',
                        hint: 'Masukkan email aktif',
                        keyboardType: TextInputType.emailAddress,
                        controller: controller.emailController,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Nomor WhatsApp *',
                        hint: 'Contoh: 08123456789',
                        keyboardType: TextInputType.phone,
                        controller: controller.whatsappController,
                        prefixIcon: Icons.phone_rounded,
                      ),
                      const SizedBox(height: 32),

                      // Section: Pilih Produk
                      _buildSectionTitle('Pilih Produk', Icons.inventory_2_rounded),
                      const SizedBox(height: 16),
                      _buildCatalogSelector(isMobile),
                      const SizedBox(height: 32),

                      // Section: Detail Event
                      _buildSectionTitle('Detail Event', Icons.event_rounded),
                      const SizedBox(height: 16),
                      _buildDatePicker(context),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Lokasi Event *',
                        hint: 'Masukkan alamat lengkap lokasi event',
                        controller: controller.lokasiController,
                        prefixIcon: Icons.location_on_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Durasi Sewa *',
                        items: controller.durasiList,
                        onChanged: (val) => controller.durasi.value = val ?? '',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Catatan Tambahan',
                        hint: 'Masukkan catatan atau keperluan khusus (opsional)',
                        maxLines: 4,
                        controller: controller.catatanController,
                      ),
                      const SizedBox(height: 32),

                      // Total Estimation
                      _buildTotalSection(),
                      const SizedBox(height: 24),

                      // Submit Button
                      Obx(() => CustomButton(
                        text: controller.isLoading.value 
                            ? 'MENGIRIM...' 
                            : 'KIRIM REQUEST ORDER',
                        backgroundColor: AppTheme.primaryColor,
                        onPressed: controller.isLoading.value 
                            ? () {} 
                            : () => controller.submitOrder(),
                      )),
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildCatalogSelector(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih produk yang ingin disewa (bisa pilih lebih dari satu)',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isLoadingCatalogs.value) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            );
          }

          if (controller.catalogs.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada katalog tersedia',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isMobile ? 0.85 : 0.9,
            ),
            itemCount: controller.catalogs.length,
            itemBuilder: (context, index) {
              final catalog = controller.catalogs[index];
              return _buildCatalogCard(catalog);
            },
          );
        }),
      ],
    );
  }

  Widget _buildCatalogCard(CatalogModel catalog) {
    return Obx(() {
      final isSelected = controller.isCatalogSelected(catalog.id);
      
      return InkWell(
        onTap: () => controller.toggleCatalog(catalog.id),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor.withValues(alpha: 0.1) 
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryColor 
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                      child: catalog.imageUrl != null && catalog.imageUrl!.isNotEmpty
                          ? Image.network(
                              catalog.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                  ),
                  // Info
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            catalog.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected 
                                  ? AppTheme.primaryColor 
                                  : const Color(0xFF2D3748),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            catalog.formattedPrice,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected 
                                  ? AppTheme.primaryColor 
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Checkbox indicator
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.primaryColor.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.inventory_2_rounded,
          size: 32,
          color: AppTheme.primaryColor.withValues(alpha: 0.5),
        ),
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
            prefixIcon: Icon(Icons.schedule_rounded, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          hint: const Text('Pilih durasi sewa'),
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
          'Tanggal Mulai *',
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
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppTheme.primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
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
                  children: [
                    Icon(Icons.calendar_today_rounded, color: Colors.grey.shade500),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.tanggalMulai.value != null
                            ? '${controller.tanggalMulai.value!.day}/${controller.tanggalMulai.value!.month}/${controller.tanggalMulai.value!.year}'
                            : 'Pilih tanggal mulai event',
                        style: TextStyle(
                          color: controller.tanggalMulai.value != null
                              ? AppTheme.textPrimary
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildTotalSection() {
    return Obx(() {
      final selectedCount = controller.selectedCatalogIds.length;
      
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              AppTheme.primaryColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Produk Dipilih',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  '$selectedCount item',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estimasi Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  controller.formattedTotal,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '* Harga final akan dikonfirmasi oleh admin',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    });
  }
}
