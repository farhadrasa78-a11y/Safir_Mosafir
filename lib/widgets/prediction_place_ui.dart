import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:safir_passengers/appInfo/app_info.dart';
import 'package:safir_passengers/methods/common_methods.dart';
import 'package:safir_passengers/models/address_models.dart';
import 'package:safir_passengers/models/prediction_model.dart';
import 'package:safir_passengers/widgets/loading_dialog.dart';

// ایمپورت ثوابت، ترجمه و پالت رنگی اختصاصی سفیر
import '../globle/global_var.dart';
import '../theme/app_colors.dart'; // آدرس فایل رنگ‌ها را در صورت نیاز اصلاح کنید

class PredictionPlaceUI extends StatefulWidget {
  final PredictionModel? predictedPlaceData;

  const PredictionPlaceUI({super.key, this.predictedPlaceData});

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI> {
  final CommonMethods commonMethods = CommonMethods();
  
  // متد دریافت جزئیات موقعیت انتخاب شده
  fetchClickedPlaceDetails() async {
    if (widget.predictedPlaceData == null) return;

    String loadingMessage = getTranslation('fetching_place_details') ?? "در حال دریافت جزئیات موقعیت...";

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(messageText: loadingMessage),
    );

    // ساخت مدل آدرس جهت ذخیره در Provider
    AddressModel dropOffLocation = AddressModel();

    dropOffLocation.placeName = widget.predictedPlaceData!.main_text ?? "";
    
    // خواندن ایمن طول و عرض جغرافیایی (بررسی هر دو حالت نام‌گذاری lat/latitude)
    String latStr = widget.predictedPlaceData!.latitude ?? widget.predictedPlaceData!.lat ?? "0.0";
    String lngStr = widget.predictedPlaceData!.longitude ?? widget.predictedPlaceData!.lng ?? "0.0";

    dropOffLocation.latitudePosition = double.tryParse(latStr) ?? 0.0;
    dropOffLocation.longitudePosition = double.tryParse(lngStr) ?? 0.0;
    dropOffLocation.placeID = widget.predictedPlaceData!.place_id ?? "";

    // ذخیره آدرس مقصد در Provider
    Provider.of<AppInfoClass>(context, listen: false).updateDropOffLocation(dropOffLocation);

    if (!mounted) return;
    
    // بستن دیالوگ لودینگ
    Navigator.pop(context); 

    // بستن صفحه جستجو و بازگشت به صفحه اصلی نقشه با مقدار "placeSelected"
    Navigator.pop(context, "placeSelected"); 
  }

  @override
  Widget build(BuildContext context) {
    if (widget.predictedPlaceData == null) {
      return const SizedBox.shrink();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.15)),
        ),
        child: InkWell(
          onTap: () {
            fetchClickedPlaceDetails();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // آیکون موقعیت با رنگ برند سفیر (#145A41) و پس‌زمینه کارت روشن (#EAF6F1)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.cardLightBg, // #EAF6F1
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryBrand, // #145A41
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                
                // نمایش متن آدرس
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.predictedPlaceData!.main_text ?? (getTranslation('unknown_location') ?? ""),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15, 
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.predictedPlaceData!.secondary_text ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12, 
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // فلش راهنما
                Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
