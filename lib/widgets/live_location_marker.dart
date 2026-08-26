import 'package:flutter/material.dart';
import 'package:safir_passengers/theme/app_colors.dart';

class LiveLocationMarker extends StatefulWidget {
  final Color? color;
  final double accuracy; // دقت GPS برحسب متر

  const LiveLocationMarker({
    super.key,
    this.color,
    this.accuracy = 0.0,
  });

  @override
  State<LiveLocationMarker> createState() => _LiveLocationMarkerState();
}

class _LiveLocationMarkerState extends State<LiveLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.10).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = widget.color ?? AppColors.originBlue;

    // ۱. اگر دقت زیر ۴ متر باشد دایره خطا مخفی می‌شود (GPS کاملاً دقیق است)
    final bool showAccuracyCircle = widget.accuracy > 4.0;

    // ۲. محاسبه قطر بصورت پویا متناسب با دقت GPS
    final double visualDiameter = showAccuracyCircle
        ? (widget.accuracy * 2.2).clamp(30.0, 800.0)
        : 0.0;

    return RepaintBoundary( // 🚀 جلوگیری از فشار اضافه به CPU/GPU حین انیمیشن
      child: OverflowBox(
        minWidth: 0,
        maxWidth: 900,
        minHeight: 0,
        maxHeight: 900,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ۱. هاله پویای دقت GPS با انیمیشن Fade و Pulse همزمان
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: showAccuracyCircle ? 1.0 : 0.0,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: visualDiameter * _pulseAnimation.value,
                    height: visualDiameter * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeColor.withOpacity(0.12),
                      border: Border.all(
                        color: activeColor.withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                  );
                },
              ),
            ),

            // ۲. حلقه سفید بیرونی نقطه زنده
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
            ),

            // ۳. هسته اصلی نقطه زنده (آبی)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
