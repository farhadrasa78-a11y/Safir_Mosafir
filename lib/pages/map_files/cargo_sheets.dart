import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/app_colors.dart';
import '../../global/global_var.dart';

class CargoSheets {
  static const Color focusBlue = Color(0xFF0066FF);
  static const Color borderGrey = Color(0xFFD6D6D6);
  static const Color labelGrey = Color(0xFF9E9E9E);
  static const Color errorRed = Color(0xFFE53935);

  // فاصله‌ها و اندازه‌های ثابت فرم
  static const double _sidePadding = 16;
  static const double _topPadding = 12;
  static const double _buttonHeight = 48;
  static const double _buttonTopGap = 12;
  static const double _buttonBottomGap = 12;
  static const double _fieldSafeGap = 24;

  /// فضای لازم پایین فرم:
  /// فاصله امن 24 + فاصله تا دکمه 12 + ارتفاع دکمه 48 + فاصله پایین 12
  static const double _formBottomSpace =
      _fieldSafeGap +
      _buttonTopGap +
      _buttonHeight +
      _buttonBottomGap;

  /// موقعیت دکمه نسبت به پایین صفحه/کیبورد
  static double _buttonBottom(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // وقتی کیبورد باز است، 12px بالاتر از آن.
    if (keyboardHeight > 0) {
      return keyboardHeight + _buttonBottomGap;
    }

    // وقتی کیبورد بسته است، SafeArea پایین + 12px.
    return MediaQuery.of(context).padding.bottom + _buttonBottomGap;
  }

  /// ارتفاع قابل‌مشاهده فرم در زمان باز بودن کیبورد
  static double _formBottom(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // خود فضای کیبورد از منطقهٔ قابل مشاهده کم می‌شود.
    // فرم هم به همان اندازه بالا می‌رود.
    return keyboardHeight;
  }

  /// صفحه کامل اطلاعات فرستنده
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
        builder: (routeContext) {
          String? nameError;
          String? phoneError;
          String? floorError;

          return StatefulBuilder(
            builder: (context, setModalState) {
              return Scaffold(
                backgroundColor: Colors.white,

                // خود Scaffold با کیبورد Resize نمی‌شود.
                // ما کل فرم و دکمه را با یک مقدار هماهنگ حرکت می‌دهیم.
                resizeToAvoidBottomInset: false,

                appBar: AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(routeContext),
                  ),
                  title: Text(
                    'cargo.sender_details_title'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  centerTitle: false,
                ),

                body: Stack(
                  children: [
                    // فرم: به اندازه کیبورد از پایین بالا می‌رود.
                    Positioned.fill(
                      bottom: _formBottom(context),
                      child: _buildScrollableForm(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Material(
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
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
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
                                          color: focusBlue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 16,
                                        color: focusBlue,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            controller: nameController,
                            label: 'cargo.sender_fullname'.tr(),
                            errorText: nameError,
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            controller: phoneController,
                            label: 'cargo.phone'.tr(),
                            keyboardType: TextInputType.phone,
                            errorText: phoneError,
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            controller: addressController,
                            label: 'cargo.origin_address_label'.tr(),
                            readOnly: true,
                            suffixIcon: const Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: labelGrey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildField(
                                  controller: floorController,
                                  label: 'cargo.plaque'.tr(),
                                  errorText: floorError,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  controller: unitController,
                                  label: 'cargo.unit'.tr(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            controller: noteController,
                            label: 'cargo.description_optional'.tr(),
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),

                    // دکمه: دقیقاً با همان keyboardHeight بالا می‌رود.
                    Positioned(
                      left: _sidePadding,
                      right: _sidePadding,
                      bottom: _buttonBottom(context),
                      child: _buildConfirmButton(
                        label: 'cargo.confirm_continue'.tr(),
                        onPressed: () {
                          setModalState(() {
                            bool isValid = true;

                            if (nameController.text.trim().isEmpty) {
                              nameError = 'لطفاً نام فرستنده را وارد کنید';
                              isValid = false;
                            } else {
                              nameError = null;
                            }

                            if (phoneController.text.trim().isEmpty) {
                              phoneError = 'لطفاً شماره تماس را وارد کنید';
                              isValid = false;
                            } else {
                              phoneError = null;
                            }

                            if (floorController.text.trim().isEmpty) {
                              floorError = 'پلاک/طبقه الزامی است';
                              isValid = false;
                            } else {
                              floorError = null;
                            }

                            if (!isValid) {
                              ScaffoldMessenger.of(routeContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'لطفاً بخش‌های ضروری را تکمیل کنید',
                                  ),
                                  backgroundColor: errorRed,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            Navigator.pop(routeContext);
                            onConfirm();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// صفحه کامل اطلاعات گیرنده
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
        builder: (routeContext) {
          String currentPackage = selectedPackageType;
          String currentInsurance = selectedInsurance;

          String? nameError;
          String? phoneError;
          String? floorError;

          return StatefulBuilder(
            builder: (context, setModalState) {
              return Scaffold(
                backgroundColor: Colors.white,
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(routeContext),
                  ),
                  title: Text(
                    'cargo.receiver_details_title'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  centerTitle: false,
                ),
                body: Stack(
                  children: [
                    Positioned.fill(
                      bottom: _formBottom(context),
                      child: _buildScrollableForm(
                        children: [
                          _buildField(
                            controller: nameController,
                            label: 'cargo.receiver_fullname'.tr(),
                            errorText: nameError,
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            controller: phoneController,
                            label: 'cargo.receiver_phone'.tr(),
                            keyboardType: TextInputType.phone,
                            errorText: phoneError,
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            controller: addressController,
                            label: 'cargo.destination_address_label'.tr(),
                            readOnly: true,
                            suffixIcon: const Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: labelGrey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildField(
                                  controller: floorController,
                                  label: 'cargo.plaque'.tr(),
                                  errorText: floorError,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  controller: unitController,
                                  label: 'cargo.unit'.tr(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            controller: noteController,
                            label: 'cargo.delivery_note'.tr(),
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 20),
                          _buildDropdownField(
                            label: 'cargo.cargo_type'.tr(),
                            value: currentPackage,
                            items: [
                              'cargo.type_other'.tr(),
                              'cargo.type_home_furniture'.tr(),
                              'cargo.type_office_furniture'.tr(),
                              'cargo.type_goods_food'.tr(),
                            ],
                            onChanged: (value) {
                              if (value == null) return;

                              setModalState(() {
                                currentPackage = value;
                              });

                              onPackageTypeChanged(value);
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildDropdownField(
                            label: 'cargo.insurance_amount'.tr(),
                            value: currentInsurance,
                            items: [
                              'cargo.insurance_50k'.tr(),
                              'cargo.insurance_100k'.tr(),
                              'cargo.insurance_500k'.tr(),
                              'cargo.no_insurance'.tr(),
                            ],
                            onChanged: (value) {
                              if (value == null) return;

                              setModalState(() {
                                currentInsurance = value;
                              });

                              onInsuranceChanged(value);
                            },
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: _sidePadding,
                      right: _sidePadding,
                      bottom: _buttonBottom(context),
                      child: _buildConfirmButton(
                        label: 'cargo.confirm_continue'.tr(),
                        onPressed: () {
                          setModalState(() {
                            bool isValid = true;

                            if (nameController.text.trim().isEmpty) {
                              nameError = 'نام گیرنده الزامی است';
                              isValid = false;
                            } else {
                              nameError = null;
                            }

                            if (phoneController.text.trim().isEmpty) {
                              phoneError = 'شماره گیرنده الزامی است';
                              isValid = false;
                            } else {
                              phoneError = null;
                            }

                            if (floorController.text.trim().isEmpty) {
                              floorError = 'پلاک/طبقه الزامی است';
                              isValid = false;
                            } else {
                              floorError = null;
                            }

                            if (!isValid) {
                              ScaffoldMessenger.of(routeContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'لطفاً اطلاعات ضروری گیرنده را تکمیل کنید',
                                  ),
                                  backgroundColor: errorRed,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            Navigator.pop(routeContext);
                            onConfirm();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// فرم اسکرول‌شونده:
  /// bottom ثابت 96 است تا انتهای فرم همیشه بتواند 24px بالاتر از دکمه بیاید.
  static Widget _buildScrollableForm({
    required List<Widget> children,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
      padding: const EdgeInsets.fromLTRB(
        _sidePadding,
        _topPadding,
        _sidePadding,
        _formBottomSpace,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  static Widget _buildConfirmButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: _buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1BAB58),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// فیلدهای متنی
  static Widget _buildField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    Widget? suffixIcon,
    String? errorText,
  }) {
    const OutlineInputBorder normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(
        color: borderGrey,
        width: 1,
      ),
      gapPadding: 6,
    );

    const OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(
        color: focusBlue,
        width: 1.5,
      ),
      gapPadding: 6,
    );

    const OutlineInputBorder errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(
        color: errorRed,
        width: 1.5,
      ),
      gapPadding: 6,
    );

    return TextField(
      key: ValueKey<String>('field_$label'),
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,

      // فیلد در محدوده قابل مشاهده می‌ماند.
      // عدد پایین = 24 فاصله + 12 فاصله تا دکمه + 48 ارتفاع دکمه + 12 فاصله پایین.
      scrollPadding: const EdgeInsets.only(
        top: 24,
        bottom: _formBottomSpace,
      ),

      onEditingComplete: () {
        if (textInputAction == TextInputAction.done) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },

      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),

      decoration: InputDecoration(
        isDense: false,
        labelText: label,
        errorText: errorText,
        errorStyle: const TextStyle(
          color: errorRed,
          fontSize: 11,
        ),
        suffixIcon: suffixIcon,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        labelStyle: const TextStyle(
          color: labelGrey,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          color: errorText != null ? errorRed : focusBlue,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          backgroundColor: Colors.white,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 18,
        ),
        filled: true,
        fillColor: Colors.white,
        border: normalBorder,
        enabledBorder: errorText != null ? errorBorder : normalBorder,
        disabledBorder: normalBorder,
        focusedBorder: errorText != null ? errorBorder : focusedBorder,
      ),
    );
  }

  /// فیلدهای دراپ‌داون
  static Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    const OutlineInputBorder normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(
        color: borderGrey,
        width: 1,
      ),
      gapPadding: 6,
    );

    const OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(
        color: focusBlue,
        width: 1.5,
      ),
      gapPadding: 6,
    );

    return DropdownButtonFormField<String>(
      key: ValueKey<String>('dropdown_$label'),
      value: value,
      isExpanded: true,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: labelGrey,
      ),
      decoration: const InputDecoration(
        labelText: '',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(
          color: labelGrey,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          color: focusBlue,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          backgroundColor: Colors.white,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 18,
        ),
        border: normalBorder,
        enabledBorder: normalBorder,
        disabledBorder: normalBorder,
        focusedBorder: focusedBorder,
      ).copyWith(
        labelText: label,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  /// محاسبه کرایه بر اساس خودرو و مسافت
  static double calculateFareForVehicle(
    String vehicleId,
    double distanceInKm,
  ) {
    double baseRate = 50;
    double perKmRate = 20;

    switch (vehicleId) {
      case 'zaranj':
        baseRate = 60;
        perKmRate = 25;
        break;
      case 'suzuki':
        baseRate = 120;
        perKmRate = 45;
        break;
      case 'mazda':
        baseRate = 250;
        perKmRate = 80;
        break;
      default:
        baseRate = 50;
        perKmRate = 20;
    }

    final double calculatedFare = baseRate + (distanceInKm * perKmRate);
    return calculatedFare < baseRate ? baseRate : calculatedFare;
  }

  /// شیت انتخاب خودرو و تایید سفارش
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
      {
        'id': 'zaranj',
        'title': 'cargo.vehicle_zaranj'.tr(),
        'icon': Icons.electric_rickshaw,
      },
      {
        'id': 'suzuki',
        'title': 'cargo.vehicle_suzuki'.tr(),
        'icon': Icons.local_shipping_outlined,
      },
      {
        'id': 'mazda',
        'title': 'cargo.vehicle_mazda'.tr(),
        'icon': Icons.fire_truck_outlined,
      },
    ];

    final String senderText = 'cargo.sender'.tr();
    final String receiverText = 'cargo.receiver'.tr();

    final double currentFare = fareAmount > 0
        ? fareAmount
        : calculateFareForVehicle(selectedVehicleType, distanceInKm);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
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
                  final Map<String, dynamic> vehicle = vehicles[index];
                  final bool isSelected =
                      selectedVehicleType == vehicle['id'];

                  return GestureDetector(
                    onTap: () {
                      onVehicleSelected(vehicle['id'] as String);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 105,
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? focusBlue.withOpacity(0.08)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isSelected ? focusBlue : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            vehicle['icon'] as IconData,
                            size: 28,
                            color: isSelected
                                ? focusBlue
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vehicle['title'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? focusBlue
                                  : AppColors.textPrimary,
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    ChoiceChip(
                      label: Text(
                        senderText,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: paymentPayer == senderText,
                      selectedColor: focusBlue.withOpacity(0.15),
                      onSelected: (_) => onPayerChanged(senderText),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(
                        receiverText,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: paymentPayer == receiverText,
                      selectedColor: focusBlue.withOpacity(0.15),
                      onSelected: (_) => onPayerChanged(receiverText),
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
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: Text(
                        '${currentFare.toStringAsFixed(0)} '
                        '${'currency.afghani'.tr()}',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : onRequestTrip,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
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
