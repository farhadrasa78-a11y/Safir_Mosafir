import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/app_colors.dart';
import '../../global/global_var.dart'; // 👈 اضافه شده جهت دسترسی به اطلاعات کاربر جاری

class CargoSheets {
  /// 📦 ۱. شیت اطلاعات فرستنده (Sender Sheet)
  static void showSenderDialog({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController addressController,
    required TextEditingController unitController,
    required TextEditingController floorController,
    required TextEditingController noteController,
    required VoidCallback onConfirm,
    VoidCallback? onUseMyInfoPressed,
  }) {
    // 💡 پر کردن خودکار فیلدها از روی پروفایل در صورت خالی بودن
    if (nameController.text.trim().isEmpty && userName.isNotEmpty) {
      nameController.text = userName;
    }
    if (phoneController.text.trim().isEmpty && userPhone.isNotEmpty) {
      phoneController.text = userPhone;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    Text(
                      'cargo.sender_details_title'.tr(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 👤 دکمه یا کارت انتخاب مشخصات از پروفایل کاربری
                InkWell(
                  onTap: () {
                    if (onUseMyInfoPressed != null) {
                      onUseMyInfoPressed();
                    } else {
                      nameController.text = userName;
                      phoneController.text = userPhone;
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrand.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryBrand.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_circle, color: AppColors.primaryBrand, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'cargo.use_my_info'.tr(),
                            style: const TextStyle(
                              color: AppColors.primaryBrand,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Icon(Icons.check_circle_outline, size: 18, color: AppColors.primaryBrand),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // فیلد نام فرستنده
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'cargo.sender_fullname'.tr(),
                    labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryBrand, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // فیلد شماره تماس
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'cargo.phone'.tr(),
                    labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryBrand, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // فیلد آدرس
                TextField(
                  controller: addressController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'cargo.origin_address_label'.tr(),
                    labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    suffixIcon: const Icon(Icons.location_on, size: 18, color: AppColors.primaryBrand),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: floorController,
                        decoration: InputDecoration(
                          labelText: 'cargo.plaque'.tr(),
                          labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: InputDecoration(
                          labelText: 'cargo.unit'.tr(),
                          labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // توضیحات تکمیلی
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'cargo.description_optional'.tr(),
                    labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      onConfirm();
                    },
                    child: Text(
                      'cargo.confirm_continue'.tr(),
                      style: const TextStyle(
                        color: AppColors.buttonText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 📥 ۲. شیت اطلاعات گیرنده (Receiver Sheet)
  static void showReceiverDialog({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController addressController,
    required TextEditingController unitController,
    required TextEditingController floorController,
    required TextEditingController noteController,
    required String selectedPackageType,
    required ValueChanged<String?> onPackageTypeChanged,
    required String selectedInsurance,
    required ValueChanged<String?> onInsuranceChanged,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                        Text(
                          'cargo.receiver_details_title'.tr(),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'cargo.receiver_fullname'.tr(),
                        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'cargo.receiver_phone'.tr(),
                        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: addressController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'cargo.destination_address_label'.tr(),
                        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        suffixIcon: const Icon(Icons.location_on, size: 18, color: AppColors.primaryBrand),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: floorController,
                            decoration: InputDecoration(
                              labelText: 'cargo.plaque'.tr(),
                              labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: unitController,
                            decoration: InputDecoration(
                              labelText: 'cargo.unit'.tr(),
                              labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: 'cargo.delivery_note'.tr(),
                        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // نوع مرسوله
                    DropdownButtonFormField<String>(
                      value: selectedPackageType,
                      decoration: InputDecoration(
                        labelText: 'cargo.cargo_type'.tr(),
                        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: [
                        'cargo.type_other'.tr(),
                        'cargo.type_home_furniture'.tr(),
                        'cargo.type_office_furniture'.tr(),
                        'cargo.type_goods_food'.tr(),
                      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) {
                        setModalState(() {});
                        onPackageTypeChanged(val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // پوشش بیمه
                    DropdownButtonFormField<String>(
                      value: selectedInsurance,
                      decoration: InputDecoration(
                        labelText: 'cargo.insurance_amount'.tr(),
                        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: [
                        'cargo.insurance_50k'.tr(),
                        'cargo.insurance_100k'.tr(),
                        'cargo.insurance_500k'.tr(),
                        'cargo.no_insurance'.tr(),
                      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) {
                        setModalState(() {});
                        onInsuranceChanged(val);
                      },
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          onConfirm();
                        },
                        child: Text(
                          'cargo.confirm_continue'.tr(),
                          style: const TextStyle(
                            color: AppColors.buttonText,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 🚚 ۳. شیت مرحله نهایی انتخاب خودرو و تایید سفارش
  static Widget buildCargoSummarySheet({
    required BuildContext context,
    required double fareAmount,
    required String selectedVehicleType,
    required ValueChanged<String> onVehicleSelected,
    required String paymentPayer,
    required ValueChanged<String> onPayerChanged,
    required VoidCallback onRequestTrip,
    bool isLoading = false,
  }) {
    final List<Map<String, dynamic>> vehicles = [
      {'id': 'zaranj', 'title': 'cargo.vehicle_zaranj'.tr(), 'icon': Icons.electric_rickshaw},
      {'id': 'suzuki', 'title': 'cargo.vehicle_suzuki'.tr(), 'icon': Icons.local_shipping_outlined},
      {'id': 'mazda', 'title': 'cargo.vehicle_mazda'.tr(), 'icon': Icons.fire_truck_outlined},
      {'id': 'kamaz', 'title': 'cargo.vehicle_kamaz'.tr(), 'icon': Icons.agriculture_outlined},
    ];

    final String senderText = 'cargo.sender'.tr();
    final String receiverText = 'cargo.receiver'.tr();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'cargo.select_vehicle'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // انتخاب نوع خودرو (زرنج، سوزوکی، مزدا، کاماز)
            SizedBox(
              height: 88,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  bool isSelected = selectedVehicleType == vehicle['id'];

                  return GestureDetector(
                    onTap: () => onVehicleSelected(vehicle['id'] as String),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 95,
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBrand.withOpacity(0.08) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBrand : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            vehicle['icon'] as IconData,
                            size: 28,
                            color: isSelected ? AppColors.primaryBrand : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vehicle['title'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.primaryBrand : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 24),

            // تعیین پرداخت‌کننده (فرستنده / گیرنده)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'cargo.payer_side'.tr(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Row(
                  children: [
                    ChoiceChip(
                      label: Text(senderText, style: const TextStyle(fontSize: 11)),
                      selected: paymentPayer == senderText,
                      selectedColor: AppColors.primaryBrand.withOpacity(0.15),
                      onSelected: (v) => onPayerChanged(senderText),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(receiverText, style: const TextStyle(fontSize: 11)),
                      selected: paymentPayer == receiverText,
                      selectedColor: AppColors.primaryBrand.withOpacity(0.15),
                      onSelected: (v) => onPayerChanged(receiverText),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),

            // قیمت و دکمه ثبت سفارش
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'cargo.total_fare'.tr(),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      '${fareAmount.toStringAsFixed(0)} ${'currency.afghani'.tr()}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBrand,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : onRequestTrip,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'cargo.submit_order'.tr(),
                          style: const TextStyle(
                            color: AppColors.buttonText,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}