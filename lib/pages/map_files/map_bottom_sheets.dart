import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // اضافه شده برای لغو در فایربیس
import 'package:safir_passengers/global/global_var.dart';
import 'package:safir_passengers/global/trip_var.dart';
import 'package:safir_passengers/theme/app_colors.dart';

import 'smart_location_sheet.dart';
import 'package:safir_passengers/widgets/driver_info_card.dart';

// وارد کردن ۳ کامپوننت جدید
import 'trip_options_sheet.dart';
import 'schedule_trip_sheet.dart';
import 'promo_code_sheet.dart';

class MapBottomSheets {
  
  // 📍 مرحله ۱: انتخاب مبدأ و مقصد روی نقشه
  static Widget buildStep1({
    required BuildContext context,
    required bool isOriginStep,
    required String liveMarkerAddress,
    required String secondaryAddress,
    required VoidCallback onConfirmLocation,
    required VoidCallback onSearchTap,
    VoidCallback? onGpsTap,
    bool isMapIdle = true,
    bool isExpanded = true,
    ValueChanged<bool>? onExpandChanged,
  }) {
    return SmartLocationSheet(
      currentStep: isOriginStep ? 0 : 1,
      currentAddress: liveMarkerAddress,
      currentDestination: secondaryAddress,
      onConfirmStep: () {
        HapticFeedback.mediumImpact();
        onConfirmLocation();
      },
      onSearchOriginTap: (addr) {
        HapticFeedback.lightImpact();
        onSearchTap();
      },
      onSearchDestinationTap: () {
        HapticFeedback.lightImpact();
        onSearchTap();
      },
      onGpsTap: () {
        HapticFeedback.selectionClick();
        if (onGpsTap != null) onGpsTap();
      },
      isMapIdle: isMapIdle,
      isExpanded: isExpanded,
      onExpandChanged: onExpandChanged,
    );
  }

  // 🎯 مرحله ۲: انتخاب نوع خودرو و موترسایکل
  static Widget buildStep2({
    required int selectedCategory,
    required int selectedVehicleType,
    required double actualFareAmount,
    required Color safirColor,
    required Function(int) onCategoryChanged,
    required Function(int, String) onVehicleSelected,
    required VoidCallback onRequestTrip,
    required VoidCallback onTripOptionsTap,
    required VoidCallback onScheduleTap,
    required VoidCallback onPromoCodeTap,
    bool hasActiveTripOptions = false,
    bool isScheduled = false,
    bool hasPromoCode = false,
  }) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              spreadRadius: 2,
              offset: Offset(0, -3),
            )
          ],
        ),
        child: Builder(builder: (context) {
          String currency = 'currency_afg'.tr();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabItem(
                    title: 'tab_car'.tr(),
                    index: 0,
                    selectedCategory: selectedCategory,
                    color: AppColors.primaryBrand,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onCategoryChanged(0);
                    },
                  ),
                  _buildTabItem(
                    title: 'tab_motorbike'.tr(),
                    index: 1,
                    selectedCategory: selectedCategory,
                    color: AppColors.primaryBrand,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onCategoryChanged(1);
                    },
                  ),
                ],
              ),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 12),
              if (selectedCategory == 0) ...[
                _buildVehicleCard(
                  title: 'vehicle_eco_title'.tr(),
                  subtitle: 'vehicle_eco_sub'.tr(),
                  price: '${actualFareAmount.toStringAsFixed(0)} $currency',
                  imagePath: 'assets/images/safir_normal.png',
                  isSelected: selectedVehicleType == 0,
                  safirColor: AppColors.primaryBrand,
                  cardBgColor: AppColors.cardBgLight,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onVehicleSelected(0, 'Car');
                  },
                ),
                const SizedBox(height: 10),
                _buildVehicleCard(
                  title: 'vehicle_vip_title'.tr(),
                  subtitle: 'vehicle_vip_sub'.tr(),
                  price: '${(actualFareAmount * 1.35).toStringAsFixed(0)} $currency',
                  imagePath: 'assets/images/uberexec.png',
                  isSelected: selectedVehicleType == 1,
                  safirColor: AppColors.primaryBrand,
                  cardBgColor: AppColors.cardBgLight,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onVehicleSelected(1, 'Auto');
                  },
                ),
              ] else ...[
                _buildVehicleCard(
                  title: 'vehicle_bike_title'.tr(),
                  subtitle: 'vehicle_bike_sub'.tr(),
                  price: '${(actualFareAmount * 0.55).toStringAsFixed(0)} $currency',
                  imagePath: 'assets/images/safir_bike.png',
                  isSelected: selectedVehicleType == 0,
                  safirColor: AppColors.primaryBrand,
                  cardBgColor: AppColors.cardBgLight,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onVehicleSelected(0, 'Bike');
                  },
                ),
              ],
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionButton(
                    title: 'opt_ride_options'.tr(),
                    isActive: hasActiveTripOptions,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTripOptionsTap();
                    },
                  ),
                  Container(height: 14, width: 1, color: Colors.grey.shade300),
                  _buildOptionButton(
                    title: 'opt_schedule'.tr(),
                    isActive: isScheduled,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onScheduleTap();
                    },
                  ),
                  Container(height: 14, width: 1, color: Colors.grey.shade300),
                  _buildOptionButton(
                    title: 'opt_promo_code'.tr(),
                    isActive: hasPromoCode,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onPromoCodeTap();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onRequestTrip();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrand,
                    overlayColor: AppColors.primaryPressed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'btn_request_safir'.tr(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // 🚀 مرحله ۳: حالت در حال جستجوی سفیر
  static Widget buildStep3({
    required Color safirColor,
    required String originAddress,
    required String destinationAddress,
    required double fareAmount,
    required VoidCallback onCancel,
    String? currentRideId, // اضافه شده برای شناسه سفر
    VoidCallback? onBidPricePressed,
  }) {
    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.28,
      maxChildSize: 0.82,
      snap: true,
      builder: (context, scrollController) {
        String currency = 'currency_afg'.tr();

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                spreadRadius: 2,
                offset: Offset(0, -3),
              )
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    LoadingAnimationWidget.flickr(
                      leftDotColor: AppColors.primaryBrand,
                      rightDotColor: Colors.orangeAccent,
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'searching_driver_msg'.tr(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryBrand, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (onBidPricePressed != null) onBidPricePressed();
                },
                icon: const Icon(Icons.arrow_back_ios_new, size: 14, color: AppColors.primaryBrand),
                label: Text(
                  'new_bid_offer'.tr(),
                  style: const TextStyle(
                    color: AppColors.primaryBrand,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'opt_ride_options'.tr(),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.circle, size: 12, color: AppColors.originBlue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      originAddress.isEmpty ? 'origin'.tr() : originAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(right: 5, top: 2, bottom: 2),
                height: 14,
                width: 2,
                color: Colors.grey.shade300,
              ),
              Row(
                children: [
                  const Icon(Icons.square, size: 12, color: AppColors.primaryBrand),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      destinationAddress.isEmpty ? 'destination'.tr() : destinationAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${fareAmount.toStringAsFixed(0)} $currency',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'terms_and_privacy_notice'.tr(),
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, height: 1.4),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showCancelReasonDialog(context, onCancel, currentRideId: currentRideId);
                },
                child: Text(
                  'cancel_request_title'.tr(),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔴 دیالوگ دلایل لغو (متصل شده به فایربیس)
  static void _showCancelReasonDialog(
    BuildContext context, 
    VoidCallback onConfirmCancel, {
    String? currentRideId,
  }) {
    String? selectedReasonKey;
    
    final List<Map<String, String>> reasons = [
      {"key": "cancel_reason_hurry", "fallback": "عجله داشتم و راننده‌ای درخواستم را قبول نکرد."},
      {"key": "cancel_reason_changed_mind", "fallback": "از سفر منصرف شدم."},
      {"key": "cancel_reason_modify_trip", "fallback": "می‌خواهم تغییراتی در سفر ایجاد کنم."},
      {"key": "cancel_reason_other", "fallback": "دلایل دیگر"},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'cancel_request_title'.tr(),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'select_cancel_reason_title'.tr(), 
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  ...reasons.map((item) {
                    String titleText = item['key']!.tr();
                    if (titleText == item['key']) {
                      titleText = item['fallback']!;
                    }
                    return RadioListTile<String>(
                      title: Text(titleText, style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary)),
                      value: item['key']!,
                      groupValue: selectedReasonKey,
                      activeColor: Colors.red,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        setModalState(() => selectedReasonKey = val);
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: selectedReasonKey == null
                              ? null
                              : () async {
                                  HapticFeedback.mediumImpact();
                                  
                                  // ثبت وضعیت لغو در فایربیس
                                  if (currentRideId != null && currentRideId.isNotEmpty) {
                                    await FirebaseFirestore.instance
                                        .collection('rides')
                                        .doc(currentRideId)
                                        .update({
                                      'status': 'cancelled',
                                      'cancelReason': selectedReasonKey,
                                    });
                                  }

                                  Navigator.pop(context);
                                  onConfirmCancel();
                                },
                          child: Text(
                            'confirm_cancel_btn'.tr(),
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'cancel'.tr(),
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🚕 مرحله ۴: پذیرفته شدن سفر توسط راننده (متصل به کارت راننده و پلاک افغانستان)
  static Widget buildStep4(
    Color safirColor, {
    String carColorDriver = '',
    dynamic tripFareAmount = 0,
    String plateProvinceDriver = '',
    String plateCategoryDriver = '',
    String plateFarsiNumDriver = '',
    String plateNumDriver = '',
    bool isTempPlateDriver = false,
    String nameDriver = '',
    String carDetailsDriver = '',
    String photoDriver = '',
    String phoneNumberDriver = '',
  }) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Builder(builder: (context) {
        Map<String, dynamic> driverData = {
          'full_name': (nameDriver.isNotEmpty) ? nameDriver : 'default_driver_title'.tr(),
          'car_model': (carDetailsDriver.isNotEmpty) ? carDetailsDriver : 'تویوتا کرولا',
          'car_color': (carColorDriver.isNotEmpty) ? carColorDriver : 'سفید',
          'photo': photoDriver,
          'fare_amount': tripFareAmount,
          
          'plate_province': (plateProvinceDriver.isNotEmpty) ? plateProvinceDriver : 'کابل',
          'plate_category': (plateCategoryDriver.isNotEmpty) ? plateCategoryDriver : 'ش',
          'plate_farsi_num': (plateFarsiNumDriver.isNotEmpty) ? plateFarsiNumDriver : '٤٤٨٩٢',
          'plate_num': (plateNumDriver.isNotEmpty) ? plateNumDriver : '44892',
          'is_temp_plate': isTempPlateDriver,
        };

        return DriverInfoCard(
          driverData: driverData,
          onCallPressed: () {
            HapticFeedback.lightImpact();
            if (phoneNumberDriver.isNotEmpty) {
              launchUrl(Uri.parse("tel:$phoneNumberDriver"));
            }
          },
          onMessagePressed: () {
            HapticFeedback.lightImpact();
          },
          onPaymentPressed: () {
            HapticFeedback.lightImpact();
          },
        );
      }),
    );
  }

  // 🔹 توابع نمایش کشوها (BottomSheet)
  static void showTripOptions(BuildContext context, TripOptionsSheet sheetContent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => sheetContent,
    );
  }

  static void showScheduleTrip(BuildContext context, ScheduleTripSheet sheetContent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => sheetContent,
    );
  }

  static void showPromoCode(BuildContext context, PromoCodeSheet sheetContent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => sheetContent,
    );
  }

  static Widget _buildTabItem({
    required String title,
    required int index,
    required int selectedCategory,
    required Color color,
    required VoidCallback onTap,
  }) {
    bool isSelected = selectedCategory == index;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : Colors.grey.shade600,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? 80 : 0,
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildVehicleCard({
    required String title,
    required String subtitle,
    required String price,
    required String imagePath,
    required bool isSelected,
    required Color safirColor,
    required Color cardBgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? cardBgColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? safirColor : Colors.grey.shade200,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 75,
              height: 45,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  title.contains('موترسایکل') || title.contains('Motorbike') ? Icons.motorcycle : Icons.directions_car,
                  size: 38,
                  color: isSelected ? safirColor : Colors.grey,
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.info_outline, size: 15, color: Colors.grey.shade500),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildOptionButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.primaryBrand : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
