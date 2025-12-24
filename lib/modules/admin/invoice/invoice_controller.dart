import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/repositories/invoice_repository.dart';

/// Controller untuk mengelola state Invoice di Admin Dashboard
/// 
/// Access Control:
/// - All operations: Admin only
class InvoiceController extends GetxController {
  final InvoiceRepository _repository = InvoiceRepository();

  // State management
  final invoices = <InvoiceModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final selectedInvoice = Rxn<InvoiceModel>();

  // Form fields
  final orderIdController = TextEditingController();
  final invoiceNumberController = TextEditingController();
  final amountController = TextEditingController();
  final selectedPaymentStatus = PaymentStatus.unpaid.obs;
  final selectedIssuedDate = Rxn<DateTime>();

  // Filter state
  final selectedStatusFilter = Rxn<PaymentStatus>();

  // Editing state
  final editingInvoiceId = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchInvoices();
  }

  @override
  void onClose() {
    orderIdController.dispose();
    invoiceNumberController.dispose();
    amountController.dispose();
    super.onClose();
  }

  /// Fetch semua invoices dari Supabase (Admin only)
  Future<void> fetchInvoices() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      
      List<InvoiceModel> items;
      if (selectedStatusFilter.value != null) {
        items = await _repository.fetchByStatus(selectedStatusFilter.value!);
      } else {
        items = await _repository.fetchAll();
      }
      invoices.assignAll(items);
    } catch (e) {
      errorMessage.value = e.toString();
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter invoices berdasarkan status pembayaran
  void filterByStatus(PaymentStatus? status) {
    selectedStatusFilter.value = status;
    fetchInvoices();
  }

  /// Generate nomor invoice baru
  Future<void> generateInvoiceNumber() async {
    try {
      final number = await _repository.generateInvoiceNumber();
      invoiceNumberController.text = number;
    } catch (e) {
      // Fallback
      invoiceNumberController.text = 'INV-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 10000}';
    }
  }

  /// Create invoice baru (Admin only)
  Future<void> createInvoice() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;
      final amount = double.tryParse(
        amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      ) ?? 0;

      final newInvoice = await _repository.create(
        orderId: orderIdController.text,
        invoiceNumber: invoiceNumberController.text,
        amount: amount,
        paymentStatus: selectedPaymentStatus.value,
        issuedDate: selectedIssuedDate.value ?? DateTime.now(),
      );

      invoices.insert(0, newInvoice);
      clearForm();
      Get.back();
      _showSuccessSnackbar('Invoice berhasil dibuat');
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Update invoice (Admin only)
  Future<void> updateInvoice() async {
    if (!_validateForm()) return;
    if (editingInvoiceId.value == null) return;

    try {
      isLoading.value = true;
      final amount = double.tryParse(
        amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      ) ?? 0;

      final updatedInvoice = await _repository.update(
        id: editingInvoiceId.value!,
        invoiceNumber: invoiceNumberController.text,
        amount: amount,
        paymentStatus: selectedPaymentStatus.value,
        issuedDate: selectedIssuedDate.value,
      );

      final index = invoices.indexWhere((i) => i.id == editingInvoiceId.value);
      if (index != -1) {
        invoices[index] = updatedInvoice;
      }

      clearForm();
      Get.back();
      _showSuccessSnackbar('Invoice berhasil diupdate');
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Update payment status only (Admin only)
  Future<void> updatePaymentStatus(String invoiceId, PaymentStatus newStatus) async {
    try {
      isLoading.value = true;
      final updatedInvoice = await _repository.updatePaymentStatus(
        id: invoiceId,
        status: newStatus,
      );

      final index = invoices.indexWhere((i) => i.id == invoiceId);
      if (index != -1) {
        invoices[index] = updatedInvoice;
      }

      _showSuccessSnackbar('Status pembayaran berhasil diupdate');
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Load invoice untuk edit
  void loadInvoiceForEdit(InvoiceModel invoice) {
    editingInvoiceId.value = invoice.id;
    orderIdController.text = invoice.orderId;
    invoiceNumberController.text = invoice.invoiceNumber;
    amountController.text = invoice.amount.toStringAsFixed(0);
    selectedPaymentStatus.value = invoice.paymentStatus;
    selectedIssuedDate.value = invoice.issuedDate;
  }

  /// Delete invoice dengan konfirmasi (Admin only)
  void deleteInvoice(InvoiceModel invoice) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 36,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hapus Invoice',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin menghapus invoice "${invoice.invoiceNumber}"?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _confirmDelete(invoice),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ya, Hapus',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Execute delete after confirmation
  Future<void> _confirmDelete(InvoiceModel invoice) async {
    try {
      Get.back(); // Close dialog
      isLoading.value = true;
      await _repository.delete(invoice.id);
      invoices.removeWhere((i) => i.id == invoice.id);
      _showSuccessSnackbar('Invoice berhasil dihapus');
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear form fields
  void clearForm() {
    orderIdController.clear();
    invoiceNumberController.clear();
    amountController.clear();
    selectedPaymentStatus.value = PaymentStatus.unpaid;
    selectedIssuedDate.value = null;
    editingInvoiceId.value = null;
  }

  /// Validate form fields
  bool _validateForm() {
    if (orderIdController.text.isEmpty ||
        invoiceNumberController.text.isEmpty ||
        amountController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
      );
      return false;
    }
    return true;
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Sukses',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade700,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade700,
    );
  }
}
