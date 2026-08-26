import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../../theme/app_colors.dart';

class IntercitySheets {
  static const Color safirBrandColor = Color(0xFF145A41);
  static const Color originBlueColor = Color(0xFF2563EB);

  /// 🏙️ ۱. نمایش شیت انتخاب شهر مقصد با جستجو و کلیک روی نقشه
  static void showCityPicker({
    required BuildContext context,
    required List<Map<String, dynamic>> targetCities,
    required Function(Map<String, dynamic> city) onCitySelected,
    VoidCallback? onPickOnMapPressed,
  }) {
    List<Map<String, dynamic>> filteredCities = List.from(targetCities);
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'intercity.select_destination_city'.tr().isEmpty 
                            ? 'انتخاب شهر مقصد' 
                            : 'intercity.select_destination_city'.tr(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: AppColors.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // کادر جستجوی مدرن
                  TextField(
                    onChanged: (query) {
                      setSheetState(() {
                        filteredCities = targetCities.where((city) {
                          final name = city['name']?.toString().toLowerCase() ?? '';
                          final province = city['province']?.toString().toLowerCase() ?? '';
                          final q = query.toLowerCase();
                          return name.contains(q) || province.contains(q);
                        }).toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'intercity.search_city_hint'.tr().isEmpty 
                          ? 'جستجوی نام شهر یا ولایت...' 
                          : 'intercity.search_city_hint'.tr(),
                      prefixIcon: const Icon(Icons.search_rounded, color: safirBrandColor),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // دکمه انتخاب روی نقشه
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onPickOnMapPressed?.call();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      decoration: BoxDecoration(
                        color: safirBrandColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: safirBrandColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.map_rounded, color: safirBrandColor),
                          const SizedBox(width: 10),
                          Text(
                            'intercity.select_on_map'.tr().isEmpty 
                                ? 'انتخاب مستقیم از روی نقشه' 
                                : 'intercity.select_on_map'.tr(),
                            style: const TextStyle(
                                color: safirBrandColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5),
                          ),
                          const Spacer(),
                          Icon(
                            isRTL ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded, 
                            size: 14, 
                            color: safirBrandColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'intercity.popular_cities'.tr().isEmpty 
                        ? 'شهرهای پرتردد' 
                        : 'intercity.popular_cities'.tr(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.38,
                    ),
                    child: filteredCities.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'intercity.no_city_found'.tr().isEmpty 
                                    ? 'شهری با این مشخصات یافت نشد' 
                                    : 'intercity.no_city_found'.tr(),
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredCities.length,
                            separatorBuilder: (c, i) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            itemBuilder: (context, index) {
                              var city = filteredCities[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.location_city_rounded, color: safirBrandColor, size: 20),
                                ),
                                title: Text(city['name'] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                        fontSize: 14)),
                                subtitle: Text(
                                    city['province'] != null 
                                        ? 'ولایت ${city['province']}' 
                                        : 'intercity.province_label'.tr(args: [city['name'] ?? '']),
                                    style: const TextStyle(
                                        fontSize: 11.5, color: AppColors.textSecondary)),
                                trailing: Icon(
                                  isRTL ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, 
                                  color: Colors.grey,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  onCitySelected(city);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 💳 ۲. شیت فاکتور، تنظیم زمان، تعداد مسافر و ثبت نهایی سفر بین‌شهری
  static Widget buildStep2IntercitySheet({
    required BuildContext context,
    String originAddress = '',
    String destinationAddress = '',
    dynamic travelDate,
    int passengerCount = 1,
    double fareAmount = 0.0,
    bool isLoading = false,
    VoidCallback? onEditOrigin,
    VoidCallback? onEditDestination,
    VoidCallback? onSelectTimingPressed,
    VoidCallback? onSelectPassengersPressed,
    VoidCallback? onRequestTrip,
    VoidCallback? onSubmitTrip,
    Function(dynamic)? onDateSelected,
    Function(int)? onPassengersChanged,
  }) {
    final VoidCallback? submitAction = onRequestTrip ?? onSubmitTrip;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 14),

            // کادر مبدأ و مقصد
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: onEditOrigin,
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: originBlueColor, size: 12),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'intercity.origin'.tr().isEmpty ? 'مبدأ' : 'intercity.origin'.tr(),
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                              Text(
                                originAddress.isEmpty 
                                    ? ('intercity.selected_origin_default'.tr().isEmpty ? 'موقعیت فعلی' : 'intercity.selected_origin_default'.tr()) 
                                    : originAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit_outlined, size: 16, color: safirBrandColor),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),
                  InkWell(
                    onTap: onEditDestination,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'intercity.destination'.tr().isEmpty ? 'مقصد' : 'intercity.destination'.tr(),
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                              Text(
                                destinationAddress.isEmpty 
                                    ? ('intercity.selected_destination_default'.tr().isEmpty ? 'انتخاب شهر مقصد' : 'intercity.selected_destination_default'.tr()) 
                                    : destinationAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit_outlined, size: 16, color: safirBrandColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // انتخاب تاریخ و انتخاب تعداد مسافران
            Row(
              children: [
                // انتخاب تاریخ
                Expanded(
                  child: InkWell(
                    onTap: onSelectTimingPressed ?? () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: travelDate is DateTime ? travelDate : DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                      );
                      if (picked != null) {
                        onDateSelected?.call(picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.indigo.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: Colors.indigo, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'intercity.travel_time'.tr().isEmpty ? 'زمان حرکت' : 'intercity.travel_time'.tr(),
                                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                ),
                                Text(
                                  travelDate is DateTime
                                      ? DateFormat('yyyy/MM/dd').format(travelDate)
                                      : (travelDate?.toString().isNotEmpty == true 
                                          ? travelDate.toString() 
                                          : ('intercity.today'.tr().isEmpty ? 'امروز' : 'intercity.today'.tr())),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // انتخاب تعداد مسافران با کنترل سریع + / -
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            if (passengerCount > 1) {
                              onPassengersChanged?.call(passengerCount - 1);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.remove, size: 16, color: Colors.orange),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              'intercity.passengers_count'.tr().isEmpty ? 'تعداد مسافر' : 'intercity.passengers_count'.tr(),
                              style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                            ),
                            Text(
                              '${passengerCount.toString()} نفر',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            if (passengerCount < 6) {
                              onPassengersChanged?.call(passengerCount + 1);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.add, size: 16, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // محاسبه و نمایش کرایه
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'intercity.fare_cost'.tr().isEmpty ? 'هزینه تخمینی' : 'intercity.fare_cost'.tr(),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                Text(
                  '${fareAmount.toStringAsFixed(0)} ${'intercity.currency'.tr().isEmpty ? 'افغانی' : 'intercity.currency'.tr()}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: safirBrandColor),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // دکمه ثبت درخواست
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: safirBrandColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: isLoading ? null : submitAction,
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'intercity.request_trip'.tr().isEmpty ? 'ثبت درخواست سفر بین شهری' : 'intercity.request_trip'.tr(),
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
