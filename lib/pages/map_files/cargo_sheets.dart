import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/app_colors.dart';
import '../../global/global_var.dart';

class CargoSheets {
  /// 🎨 رنگ‌های اصلی
  static const Color focusBlue = Color(0xFF0066FF);
  static const Color borderGrey = Color(0xFFD6D6D6);
  static const Color labelGrey = Color(0xFF9E9E9E);
  static const Color errorRed = Color(0xFFE53935);

  /// 📦 ۱. صفحه اطلاعات فرستنده
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => _SenderDialogContent(
          nameController: nameController,
          phoneController: phoneController,
          addressController: addressController,
          unitController: unitController,
          floorController: floorController,
          noteController: noteController,
          onConfirm: onConfirm,
          onUseMyInfoPressed: onUseMyInfoPressed,
        ),
      ),
    );
  }

  /// 📥 ۲. صفحه اطلاعات گیرنده
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => _ReceiverDialogContent(
          nameController: nameController,
          phoneController: phoneController,
          addressController: addressController,
          unitController: unitController,
          floorController: floorController,
          noteController: noteController,
          selectedPackageType: selectedPackageType,
          onPackageTypeChanged: onPackageTypeChanged,
          selectedInsurance: selectedInsurance,
          onInsuranceChanged: onInsuranceChanged,
          onConfirm: onConfirm,
        ),
      ),
    );
  }

  /// 🔹 متد ساخت فیلدهای ورودی متنی
  static Widget _buildField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    Widget? suffixIcon,
    String? errorText,
  }) {
    const normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: borderGrey, width: 1.0),
    );

    const focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: focusBlue, width: 1.5),
    );

    const errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: errorRed, width: 1.5),
    );

    return TextField(
      key: ValueKey('field_$label'),
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      scrollPadding: const EdgeInsets.all(80), // پدینگ مناسب برای آوردن فیلد بالای کیبورد
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        isDense: false,
        labelText: label,
        errorText: errorText,
        errorStyle: const TextStyle(color: errorRed, fontSize: 11),
        suffixIcon: suffixIcon,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        labelStyle: const TextStyle(color: labelGrey, fontSize: 13, fontWeight: FontWeight.w400),
        floatingLabelStyle: TextStyle(
          color: errorText != null ? errorRed : focusBlue,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          backgroundColor: Colors.white,
        ),
        hintStyle: const TextStyle(color: labelGrey, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        filled: true,
        fillColor: Colors.white,
        border: normalBorder,
        enabledBorder: errorText != null ? errorBorder : normalBorder,
        disabledBorder: normalBorder,
        focusedBorder: errorText != null ? errorBorder : focusedBorder,
      ),
    );
  }

  /// 🔹 متد ساخت فیلدهای دراپ‌داون
  static Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    const normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: borderGrey, width: 1.0),
    );

    const focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: focusBlue, width: 1.5),
    );

    return DropdownButtonFormField<String>(
      key: ValueKey('dropdown_$label'),
      value: items.contains(value) ? value : items.first,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w400),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: labelGrey),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: const TextStyle(color: labelGrey, fontSize: 13, fontWeight: FontWeight.w400),
        floatingLabelStyle: const TextStyle(
          color: focusBlue,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          backgroundColor: Colors.white,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        border: normalBorder,
        enabledBorder: normalBorder,
        disabledBorder: normalBorder,
        focusedBorder: focusedBorder,
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  /// 📐 تابع محاسبه قیمت
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

  /// 🚚 ۳. شیت مرحله نهایی انتخاب خودرو
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
                        color: isSelected ? focusBlue.withOpacity(0.08) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? focusBlue : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            vehicle['icon'] as IconData,
                            size: 28,
                            color: isSelected ? focusBlue : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vehicle['title'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? focusBlue : AppColors.textPrimary,
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
                      selectedColor: focusBlue.withOpacity(0.15),
                      onSelected: (v) => onPayerChanged(senderText),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(receiverText, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                      selected: paymentPayer == receiverText,
                      selectedColor: focusBlue.withOpacity(0.15),
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
                          color: focusBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1BAB58),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            color: Colors.white,
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

/// 🏢 ویجت اطلاعات فرستنده
class _SenderDialogContent extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController unitController;
  final TextEditingController floorController;
  final TextEditingController noteController;
  final VoidCallback onConfirm;
  final VoidCallback? onUseMyInfoPressed;

  const _SenderDialogContent({
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.unitController,
    required this.floorController,
    required this.noteController,
    required this.onConfirm,
    this.onUseMyInfoPressed,
  });

  @override
  State<_SenderDialogContent> createState() => _SenderDialogContentState();
}

class _SenderDialogContentState extends State<_SenderDialogContent> {
  String? nameError;
  String? phoneError;
  String? floorError;

  void _validateAndSubmit() {
    setState(() {
      bool isValid = true;

      if (widget.nameController.text.trim().isEmpty) {
        nameError = 'لطفاً نام فرستنده را وارد کنید';
        isValid = false;
      } else {
        nameError = null;
      }

      if (widget.phoneController.text.trim().isEmpty) {
        phoneError = 'لطفاً شماره تماس را وارد کنید';
        isValid = false;
      } else {
        phoneError = null;
      }

      if (widget.floorController.text.trim().isEmpty) {
        floorError = 'پلاک/طبقه الزامی است';
        isValid = false;
      } else {
        floorError = null;
      }

      if (isValid) {
        Navigator.pop(context);
        widget.onConfirm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لطفاً بخش‌های ضروری را تکمیل کنید'),
            backgroundColor: CargoSheets.errorRed,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // پدینگ انتهای صفحه برای اسکرول راحت‌تر
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // هدر سازگار با RTL
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.arrow_back_rtl
                          : Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'cargo.sender_details_title'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // دکمه «استفاده از اطلاعات من»
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (widget.onUseMyInfoPressed != null) {
                          widget.onUseMyInfoPressed!();
                        } else {
                          widget.nameController.text = userName;
                          widget.phoneController.text = userPhone;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'cargo.use_my_info'.tr(),
                            style: const TextStyle(
                              color: CargoSheets.focusBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_downward_rounded,
                            size: 16,
                            color: CargoSheets.focusBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ورودی‌ها
              CargoSheets._buildField(
                controller: widget.nameController,
                label: 'cargo.sender_fullname'.tr(),
                errorText: nameError,
              ),
              const SizedBox(height: 16),

              CargoSheets._buildField(
                controller: widget.phoneController,
                label: 'cargo.phone'.tr(),
                keyboardType: TextInputType.phone,
                errorText: phoneError,
              ),
              const SizedBox(height: 16),

              CargoSheets._buildField(
                controller: widget.addressController,
                label: 'cargo.origin_address_label'.tr(),
                readOnly: true,
                suffixIcon: const Icon(Icons.edit_outlined, size: 20, color: CargoSheets.labelGrey),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CargoSheets._buildField(
                      controller: widget.floorController,
                      label: 'cargo.plaque'.tr(),
                      errorText: floorError,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CargoSheets._buildField(
                      controller: widget.unitController,
                      label: 'cargo.unit'.tr(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CargoSheets._buildField(
                controller: widget.noteController,
                label: 'cargo.description_optional'.tr(),
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 8,
        ),
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1BAB58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: _validateAndSubmit,
            child: Text(
              'cargo.confirm_continue'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🏢 ویجت اطلاعات گیرنده
class _ReceiverDialogContent extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController unitController;
  final TextEditingController floorController;
  final TextEditingController noteController;
  final String selectedPackageType;
  final ValueChanged<String?> onPackageTypeChanged;
  final String selectedInsurance;
  final ValueChanged<String?> onInsuranceChanged;
  final VoidCallback onConfirm;

  const _ReceiverDialogContent({
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.unitController,
    required this.floorController,
    required this.noteController,
    required this.selectedPackageType,
    required this.onPackageTypeChanged,
    required this.selectedInsurance,
    required this.onInsuranceChanged,
    required this.onConfirm,
  });

  @override
  State<_ReceiverDialogContent> createState() => _ReceiverDialogContentState();
}

class _ReceiverDialogContentState extends State<_ReceiverDialogContent> {
  late String currentPackage;
  late String currentInsurance;

  String? nameError;
  String? phoneError;
  String? floorError;

  @override
  void initState() {
    super.initState();
    currentPackage = widget.selectedPackageType;
    currentInsurance = widget.selectedInsurance;
  }

  void _validateAndSubmit() {
    setState(() {
      bool isValid = true;

      if (widget.nameController.text.trim().isEmpty) {
        nameError = 'نام گیرنده الزامی است';
        isValid = false;
      } else {
        nameError = null;
      }

      if (widget.phoneController.text.trim().isEmpty) {
        phoneError = 'شماره گیرنده الزامی است';
        isValid = false;
      } else {
        phoneError = null;
      }

      if (widget.floorController.text.trim().isEmpty) {
        floorError = 'پلاک/طبقه الزامی است';
        isValid = false;
      } else {
        floorError = null;
      }

      if (isValid) {
        Navigator.pop(context);
        widget.onConfirm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لطفاً اطلاعات ضروری گیرنده را تکمیل کنید'),
            backgroundColor: CargoSheets.errorRed,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.arrow_back_rtl
                          : Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'cargo.receiver_details_title'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              CargoSheets._buildField(
                controller: widget.nameController,
                label: 'cargo.receiver_fullname'.tr(),
                errorText: nameError,
              ),
              const SizedBox(height: 16),

              CargoSheets._buildField(
                controller: widget.phoneController,
                label: 'cargo.receiver_phone'.tr(),
                keyboardType: TextInputType.phone,
                errorText: phoneError,
              ),
              const SizedBox(height: 16),

              CargoSheets._buildField(
                controller: widget.addressController,
                label: 'cargo.destination_address_label'.tr(),
                readOnly: true,
                suffixIcon: const Icon(Icons.edit_outlined, size: 20, color: CargoSheets.labelGrey),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CargoSheets._buildField(
                      controller: widget.floorController,
                      label: 'cargo.plaque'.tr(),
                      errorText: floorError,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CargoSheets._buildField(
                      controller: widget.unitController,
                      label: 'cargo.unit'.tr(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CargoSheets._buildField(
                controller: widget.noteController,
                label: 'cargo.delivery_note'.tr(),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),

              CargoSheets._buildDropdownField(
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
                    setState(() {
                      currentPackage = val;
                    });
                    widget.onPackageTypeChanged(val);
                  }
                },
              ),
              const SizedBox(height: 16),

              CargoSheets._buildDropdownField(
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
                    setState(() {
                      currentInsurance = val;
                    });
                    widget.onInsuranceChanged(val);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 8,
        ),
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1BAB58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: _validateAndSubmit,
            child: Text(
              'cargo.confirm_continue'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
