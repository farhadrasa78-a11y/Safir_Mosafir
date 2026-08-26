import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:safir_passengers/theme/app_colors.dart';

class TripOptionsSheet extends StatefulWidget {
  final String? secondDestination;
  final int stopMinutes;
  final bool isRoundTrip;
  final bool hasLuggage;
  final bool preferSilence;
  final VoidCallback onSelectSecondDestinationOnMap;
  final Function(
    String? secondDest,
    int stopMinutes,
    bool isRoundTrip,
    bool hasLuggage,
    bool preferSilence,
  ) onSave;

  const TripOptionsSheet({
    Key? key,
    this.secondDestination,
    this.stopMinutes = 0,
    this.isRoundTrip = false,
    this.hasLuggage = false,
    this.preferSilence = false,
    required this.onSelectSecondDestinationOnMap,
    required this.onSave,
  }) : super(key: key);

  @override
  State<TripOptionsSheet> createState() => _TripOptionsSheetState();
}

class _TripOptionsSheetState extends State<TripOptionsSheet> {
  late String? _secondDestination;
  late int _stopMinutes;
  late bool _isRoundTrip;
  late bool _hasLuggage;
  late bool _preferSilence;

  @override
  void initState() {
    super.initState();
    _secondDestination = widget.secondDestination;
    _stopMinutes = widget.stopMinutes;
    _isRoundTrip = widget.isRoundTrip;
    _hasLuggage = widget.hasLuggage;
    _preferSilence = widget.preferSilence;
  }

  void _showStopDurationDialog() {
    int tempMinutes = _stopMinutes;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text('opt_stop_in_path'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('stop_none'.tr()),
                  leading: Radio<int>(
                    value: 0,
                    groupValue: tempMinutes,
                    activeColor: AppColors.primaryBrand,
                    onChanged: (val) => setModalState(() => tempMinutes = val!),
                  ),
                ),
                ListTile(
                  title: Text('stop_5_min'.tr()),
                  leading: Radio<int>(
                    value: 5,
                    groupValue: tempMinutes,
                    activeColor: AppColors.primaryBrand,
                    onChanged: (val) => setModalState(() => tempMinutes = val!),
                  ),
                ),
                ListTile(
                  title: Text('stop_10_min'.tr()),
                  leading: Radio<int>(
                    value: 10,
                    groupValue: tempMinutes,
                    activeColor: AppColors.primaryBrand,
                    onChanged: (val) => setModalState(() => tempMinutes = val!),
                  ),
                ),
                ListTile(
                  title: Text('stop_20_min'.tr()),
                  leading: Radio<int>(
                    value: 20,
                    groupValue: tempMinutes,
                    activeColor: AppColors.primaryBrand,
                    onChanged: (val) => setModalState(() => tempMinutes = val!),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr(), style: const TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBrand),
                onPressed: () {
                  setState(() => _stopMinutes = tempMinutes);
                  Navigator.pop(context);
                },
                child: Text('confirm_btn'.tr(), style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // عنوان و دکمه بازگشت
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'opt_ride_options'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 16),

            // پیام هشدار بالای صفحه
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phonelink_ring_sharp, color: Colors.redAccent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'trip_options_change_warning'.tr(),
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'opt_ride_options'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),

            // ۱. مقصد دوم
            _buildClickableRow(
              title: 'opt_second_destination'.tr(),
              subtitle: _secondDestination ?? '',
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
                widget.onSelectSecondDestinationOnMap();
              },
            ),

            // ۲. توقف در مسیر
            _buildClickableRow(
              title: 'opt_stop_in_path'.tr(),
              subtitle: _stopMinutes > 0 ? '$_stopMinutes ${'minutes_suffix'.tr()}' : '',
              onTap: () {
                HapticFeedback.lightImpact();
                _showStopDurationDialog();
              },
            ),

            // ۳. رفت و برگشت
            _buildSwitchRow(
              title: 'opt_round_trip'.tr(),
              value: _isRoundTrip,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _isRoundTrip = val);
              },
            ),

            // ۴. بار یا چمدان
            _buildSwitchRow(
              title: 'opt_extra_luggage'.tr(),
              value: _hasLuggage,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _hasLuggage = val);
              },
            ),

            // ۵. تمایلی به گفتگو ندارم
            _buildSwitchRow(
              title: 'opt_prefer_silence'.tr(),
              value: _preferSilence,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _preferSilence = val);
              },
            ),

            const SizedBox(height: 24),

            // دکمه‌های تایید و انصراف
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('cancel'.tr(), style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      widget.onSave(_secondDestination, _stopMinutes, _isRoundTrip, _hasLuggage, _preferSilence);
                      Navigator.pop(context);
                    },
                    child: Text('confirm_btn'.tr(), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

      Widget _buildClickableRow({
    required String title,
    String subtitle = '',
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey),
                Row(
                  children: [
                    if (subtitle.isNotEmpty) ...[
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBrand,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 0.6),
      ],
    );
  }


  Widget _buildSwitchRow({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Switch(
                value: value,
                activeColor: AppColors.primaryBrand,
                onChanged: onChanged,
              ),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.6),
      ],
    );
  }
}
