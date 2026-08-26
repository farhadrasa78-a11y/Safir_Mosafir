import 'package:flutter/material.dart';
import '../models/predicted_places.dart';
import 'package:safir_passengers/global/global_var.dart';
import 'package:safir_passengers/theme/app_colors.dart';

class PlacePredictionTileDesign extends StatelessWidget {
  final PredictedPlaces? predictedPlaces;

  const PlacePredictionTileDesign({
    super.key, 
    this.predictedPlaces,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین کردن نمایش آدرس‌ها و آیکون
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // آیکون لوکیشن با رنگ اصلی برند سفیر (#145A41)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.cardLightBg, // پس‌زمینه کارت روشن (#EAF6F1)
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded, 
                color: AppColors.primaryBrand, // #145A41
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان اصلی مکان
                  Text(
                    predictedPlaces?.mainText ?? getTranslation(context, "unknown_place"),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // توضیحات یا آدرس فرعی مکان
                  Text(
                    predictedPlaces?.secondaryText ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
