import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/app_colors.dart';
import '../../global/global_var.dart';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      elevation: 8, // 👈 سایه ملایم برای حس مدرن‌تر شیت
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            return AnimatedPadding(
              // 👇 هماهنگ با تایمینگ واقعی انیمیشن کیبورد، برای جلوگیری از پرش/گیر کردن
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
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
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // دکمه مدرن برای پر کردن اطلاعات حساب کاربری
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                if (onUseMyInfoPressed != null) {
                                  onUseMyInfoPressed();
                                } else {
                                  nameController.text = userName;
                                  phoneController.text = userPhone;
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBrand.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primaryBrand.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBrand.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_add_alt_1_rounded,
                                      color: AppColors.primaryBrand,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'cargo.use_my_info'.tr(),
                                      style: const TextStyle(
                                        color: AppColors.primaryBrand,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: AppColors.primaryBrand,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        _buildField(
                          controller: nameController,
                          label: 'cargo.sender_fullname'.tr(),
                        ),
                        const SizedBox(height: 12),

                        _buildField(
                          controller: phoneController,
                          label: 'cargo.phone'.tr(),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),

                        _buildField(
                          controller: addressController,
                          label: 'cargo.origin_address_label'.tr(),
                          readOnly: true,
                          suffixIcon: const Icon(Icons.location_on, size: 18, color: AppColors.primaryBrand),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                controller: floorController,
                                label: 'cargo.plaque'.tr(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildField(
                                controller: unitController,
                                label: 'cargo.unit'.tr(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _buildField(
                          controller: noteController,
                          label: 'cargo.description_optional'.tr(),
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 18),

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
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
      elevation: 8, // 👈 سایه ملایم هماهنگ با شیت فرستنده
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String currentPackage = selectedPackageType;
        String currentInsurance = selectedInsurance;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            return AnimatedPadding(
              // 👇 هماهنگ با تایمینگ واقعی انیمیشن کیبورد، برای جلوگیری از پرش/گیر کردن
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
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
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _buildField(
                          controller: nameController,
                          label: 'cargo.receiver_fullname'.tr(),
                        ),
                        const SizedBox(height: 12),

                        _buildField(
                          controller: phoneController,
                          label: 'cargo.receiver_phone'.tr(),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),

                        _buildField(
                          controller: addressController,
                          label: 'cargo.destination_address_label'.tr(),
                          readOnly: true,
                          suffixIcon: const Icon(Icons.location_on, size: 18, color: AppColors.primaryBrand),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                controller: floorController,
                                label: 'cargo.plaque'.tr(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildField(
                                controller: unitController,
                                label: 'cargo.unit'.tr(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _buildField(
                          controller: noteController,
                          label: 'cargo.delivery_note'.tr(),
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 12),

                        // 👇 قبلاً اینجا کد تکراری و بدون Key بود؛ حالا از همون متد
                        // یکپارچهٔ _buildDropdownField استفاده می‌شه (هم‌استایل با بقیهٔ فیلدها)
                        _buildDropdownField(
                          label: 'cargo.cargo_type'.tr(),
                          value: currentPackage,
                          items: [
                            'cargo.type_other'.tr(),
                            'cargo.type_home_furniture'.tr(),
                            'cargo.type_office_furniture'.tr(),
                            'cargo.type_goods_food'.tr(),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                currentPackage = val;
                              });
                              onPackageTypeChanged(val);
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        _buildDropdownField(
                          label: 'cargo.insurance_amount'.tr(),
                          value: currentInsurance,
                          items: [
                            'cargo.insurance_50k'.tr(),
                            'cargo.insurance_100k'.tr(),
                            'cargo.insurance_500k'.tr(),
                            'cargo.no_insurance'.tr(),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                currentInsurance = val;
                              });
                              onInsuranceChanged(val);
                            }
                          },
                        ),
                        const SizedBox(height: 18),

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
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// متد ساخت اینپوت تکس‌فیلد با استایل حاشیه نازک و لیبل روی خط
  static Widget _buildField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    Widget? suffixIcon,
  }) {
    const normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(
        color: Color(0xFFD6D6D6),
        width: 1.0,
      ),
    );

    const focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(
        color: AppColors.primaryBrand,
        width: 1.5,
      ),
    );

    return TextField(
      key: ValueKey('field_$label'), // 👈 جلوگیری از rebuild کامل ویجت هنگام باز شدن کیبورد
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      // 👇 فاصلهٔ کافی بالای کیبورد هنگام اسکرول خودکار، برای جلوگیری از پرش/گیر کردن
      scrollPadding: const EdgeInsets.only(bottom: 140),
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        isDense: false,
        labelText: label,
        suffixIcon: suffixIcon,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        labelStyle: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primaryBrand,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          backgroundColor: Colors.white,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 12.5,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.white,
        border: normalBorder,
        enabledBorder: normalBorder,
        disabledBorder: normalBorder,
        focusedBorder: focusedBorder,
      ),
    );
  }

  /// متد ساخت دراپ‌داون با استایل هماهنگ فیلدها
  static Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    const normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(
        color: Color(0xFFD6D6D6),
        width: 1.0,
      ),
    );

    const focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(
        color: AppColors.primaryBrand,
        width: 1.5,
      ),
    );

    return DropdownButtonFormField<String>(
      key: ValueKey('dropdown_$label'), // 👈 جلوگیری از rebuild کامل ویجت
      value: value,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
      ),
      icon: const Icon(
        Icons.arrow_drop_down,
        color: Color(0xFF757575),
      ),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primaryBrand,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          backgroundColor: Colors.white,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: normalBorder,
        enabledBorder: normalBorder,
        focusedBorder: focusedBorder,
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  /// 📐 تابع محاسبه قیمت اختصاصی هر خودرو بر اساس مسافت (کیلومتر)
  static double calculateFareForVehicle(String vehicleId, double distanceInKm) {
    double baseRate = 50.0;
    double perKmRate = 20.0;

    switch (vehicleId) {
      case 'zaranj':
        baseRate = 60.0;
        perKmRate = 25.0;
        break;
      case 'suzuki':
        baseRate = 120.0;
        perKmRate = 45.0;
        break;
      case 'mazda':
        baseRate = 250.0;
        perKmRate = 80.0;
        break;
      default:
        baseRate = 50.0;
        perKmRate = 20.0;
    }

    double calculatedFare = baseRate + (distanceInKm * perKmRate);
    return calculatedFare < baseRate ? baseRate : calculatedFare;
  }

  /// 🚚 ۳. شیت مرحله نهایی انتخاب خودرو و تایید سفارش
  static Widget buildCargoSummarySheet({
    required BuildContext context,
    required double fareAmount,
    required double distanceInKm,
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
    ];

    final String senderText = 'cargo.sender'.tr();
    final String receiverText = 'cargo.receiver'.tr();

    double currentFare = fareAmount > 0
        ? fareAmount
        : calculateFareForVehicle(selectedVehicleType, distanceInKm);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 88,
              child: ListView.builder(
                key: const PageStorageKey('cargo_vehicle_list'),
                scrollDirection: Axis.horizontal,
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  bool isSelected = selectedVehicleType == vehicle['id'];

                  return GestureDetector(
                    onTap: () {
                      onVehicleSelected(vehicle['id'] as String);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 105,
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
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'cargo.payer_side'.tr(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Row(
                  children: [
                    ChoiceChip(
                      label: Text(senderText, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                      selected: paymentPayer == senderText,
                      selectedColor: AppColors.primaryBrand.withOpacity(0.15),
                      onSelected: (v) => onPayerChanged(senderText),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(receiverText, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                      selected: paymentPayer == receiverText,
                      selectedColor: AppColors.primaryBrand.withOpacity(0.15),
                      onSelected: (v) => onPayerChanged(receiverText),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'cargo.total_fare'.tr(),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Text(
                        '${currentFare.toStringAsFixed(0)} ${'currency.afghani'.tr()}',
                        key: ValueKey<double>(currentFare),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBrand,
                        ),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
