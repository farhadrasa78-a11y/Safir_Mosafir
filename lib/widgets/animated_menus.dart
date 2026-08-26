import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:safir_passengers/pages/settings_screen.dart';
import 'package:safir_passengers/pages/user_profile_screen.dart';
import 'package:safir_passengers/pages/sub_screens.dart';
// ایمپورت ثوابت و متدهای عمومی برند سفیر
import 'package:safir_passengers/global/global_var.dart';

// رنگ اصلی برند سفیر
const Color safirBrandColor = Color(0xFF145A41);

// متد کمکی برای تماس با پشتیبانی (متصل به فایربیس)
Future<void> _makeSupportCall(BuildContext context) async {
  String phone = "+93700000000"; // شماره پیش‌فرض در صورت عدم پاسخ‌دهی دیتابیس

  try {
    DatabaseReference adminRef = FirebaseDatabase.instance.ref().child("admin_settings").child("support_phone");
    DataSnapshot snapshot = await adminRef.get();
    if (snapshot.exists && snapshot.value != null) {
      phone = snapshot.value.toString();
    }
  } catch (e) {
    debugPrint("خطا در دریافت شماره پشتیبانی: $e");
  }

  final Uri launchUri = Uri(scheme: 'tel', path: phone);
  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('امکان برقرار تماس وجود ندارد: $phone')),
      );
    }
  }
}

// متد کمکی برای نمایش دیالوگ درباره برنامه
void _showAboutAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: safirBrandColor),
          SizedBox(width: 8),
          Text('درباره سفیر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      content: const Text(
        'اپلیکیشن آنلاین درخواست تاکسی، باربری و خدمات بین‌شهری سفیر.\nنسخه: 1.0.0\nارائه دهنده خدمات حمل‌ونقل ایمن و سریع.',
        style: TextStyle(fontSize: 13, height: 1.6),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('بستن', style: TextStyle(color: safirBrandColor, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

// منوی کشویی Drawer
class ExactAnimatedMenu extends StatefulWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageChanged;

  const ExactAnimatedMenu({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<ExactAnimatedMenu> createState() => _ExactAnimatedMenuState();
}

class _ExactAnimatedMenuState extends State<ExactAnimatedMenu> {
  int? activeIndex;

  // لیست منوها با پشتیبانی از کلیدهای چندزبانه
  final List<Map<String, dynamic>> menuItems = [
    {'titleKey': 'invite_friends', 'defaultTitle': 'دعوت دوستان', 'icon': Icons.person_add_alt_1_outlined},
    {'titleKey': 'settings', 'defaultTitle': 'تنظیمات', 'icon': Icons.settings_outlined},
    {'titleKey': 'messages', 'defaultTitle': 'پیام‌ها', 'icon': Icons.mail_outline},
    {'titleKey': 'discount_code', 'defaultTitle': 'کد تخفیف', 'icon': Icons.local_offer_outlined},
    {'titleKey': 'support_contact', 'defaultTitle': 'تماس با پشتیبانی', 'icon': Icons.headset_mic_outlined},
    {'titleKey': 'about_app', 'defaultTitle': 'درباره برنامه', 'icon': Icons.info_outline_rounded},
  ];

  void _updateIndexByPosition(Offset localPosition, double itemHeight) {
    double profileHeaderHeight = 96.0; 
    double relativeY = localPosition.dy - profileHeaderHeight;
    
    int index = (relativeY / itemHeight).floor();
    if (index >= 0 && index < menuItems.length) {
      if (activeIndex != index) {
        setState(() => activeIndex = index);
      }
    } else {
      if (activeIndex != null) {
        setState(() => activeIndex = null);
      }
    }
  }

  void _navigateToPage(String titleKey) {
    Navigator.pop(context);

    if (titleKey == 'settings') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SettingsScreen(
            currentLanguage: widget.currentLanguage,
            onLanguageChanged: widget.onLanguageChanged,
          ),
        ),
      );
    } else if (titleKey == 'invite_friends') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const InviteFriendsScreen()));
    } else if (titleKey == 'messages') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MessagesScreen()));
    } else if (titleKey == 'discount_code') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DiscountCodeScreen()));
    } else if (titleKey == 'support_contact') {
      _makeSupportCall(context);
    } else if (titleKey == 'about_app') {
      _showAboutAppDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double menuWidth = 280.0;
    double itemHeight = 56.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: menuWidth,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 40, offset: Offset(0, 16)),
          ],
        ),
        child: GestureDetector(
          onPanUpdate: (details) => _updateIndexByPosition(details.localPosition, itemHeight),
          onPanEnd: (_) => setState(() => activeIndex = null),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // هدر حساب کاربری بروزشده
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const UserProfileScreen()));
                },
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.transparent, 
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: safirBrandColor.withAlpha(30),
                        child: const Icon(Icons.person, color: safirBrandColor, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName.isNotEmpty ? userName : 'کاربر سفیر', 
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 14, color: Colors.black45),
                                const SizedBox(width: 4),
                                Text(
                                  userPhone.isNotEmpty ? userPhone : '۰۹۹۰۷۰۲۷۱۲۳',
                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 16, thickness: 1, color: Colors.grey.withAlpha(30), indent: 12, endIndent: 12),
              ...List.generate(menuItems.length, (index) {
                final item = menuItems[index];
                final isHovered = activeIndex == index;
                final String itemTitle = getTranslation(context, item['titleKey']) ?? item['defaultTitle'];

                return MouseRegion(
                  onEnter: (_) => setState(() => activeIndex = index),
                  onExit: (_) => setState(() => activeIndex = null),
                  child: AnimatedScale(
                    scale: isHovered ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutBack,
                      height: itemHeight - 4,
                      margin: EdgeInsets.symmetric(horizontal: isHovered ? 4 : 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: isHovered ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: isHovered ? Colors.black.withAlpha(20) : Colors.transparent,
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => _navigateToPage(item['titleKey']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: (isHovered || index == menuItems.length - 1)
                                    ? Colors.transparent
                                    : Colors.grey.withAlpha(20),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['icon'], 
                                size: 20, 
                                color: isHovered ? safirBrandColor : Colors.black54
                              ),
                              const SizedBox(width: 16),
                              Text(
                                itemTitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isHovered ? FontWeight.w600 : FontWeight.w400,
                                  color: isHovered ? safirBrandColor : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// منوی شناور پروفایل روی نقشه
class ProfileAnimatedMenu extends StatefulWidget {
  const ProfileAnimatedMenu({super.key});

  @override
  State<ProfileAnimatedMenu> createState() => _ProfileAnimatedMenuState();
}

class _ProfileAnimatedMenuState extends State<ProfileAnimatedMenu> {
  int? activeIndex;

  // لیست منوها با پشتیبانی از کلیدهای چندزبانه
  final List<Map<String, dynamic>> menuItems = [
    {'titleKey': 'trips_history', 'defaultTitle': 'سفرها', 'icon': Icons.history},
    {'titleKey': 'invite_friends', 'defaultTitle': 'دعوت دوستان', 'icon': Icons.person_add_alt_1_outlined},
    {'titleKey': 'messages', 'defaultTitle': 'پیام‌ها', 'icon': Icons.mail_outline},
    {'titleKey': 'discount_code', 'defaultTitle': 'کد تخفیف', 'icon': Icons.local_offer_outlined},
    {'titleKey': 'support_contact', 'defaultTitle': 'تماس با پشتیبانی', 'icon': Icons.headset_mic_outlined},
    {'titleKey': 'about_app', 'defaultTitle': 'درباره برنامه', 'icon': Icons.info_outline_rounded},
  ];

  void _updateIndexByPosition(Offset localPosition, double itemHeight) {
    double profileHeaderHeight = 98.0; 
    double relativeY = localPosition.dy - profileHeaderHeight;
    
    int index = (relativeY / itemHeight).floor();
    if (index >= 0 && index < menuItems.length) {
      if (activeIndex != index) {
        setState(() => activeIndex = index);
      }
    } else {
      if (activeIndex != null) {
        setState(() => activeIndex = null);
      }
    }
  }

  void _navigateToPage(String titleKey) {
    Navigator.pop(context); 

    if (titleKey == 'trips_history') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const TripsScreen()));
    } else if (titleKey == 'invite_friends') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const InviteFriendsScreen()));
    } else if (titleKey == 'messages') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MessagesScreen()));
    } else if (titleKey == 'discount_code') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DiscountCodeScreen()));
    } else if (titleKey == 'support_contact') {
      _makeSupportCall(context);
    } else if (titleKey == 'about_app') {
      _showAboutAppDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double menuWidth = 310.0; 
    double itemHeight = 56.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: menuWidth,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: GestureDetector(
          onPanUpdate: (details) => _updateIndexByPosition(details.localPosition, itemHeight),
          onPanEnd: (_) => setState(() => activeIndex = null),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const UserProfileScreen()));
                },
                child: Container(
                  height: 76,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: safirBrandColor.withAlpha(30),
                            child: const Icon(Icons.person, color: safirBrandColor, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName.isNotEmpty ? userName : 'کاربر سفیر',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userPhone.isNotEmpty ? userPhone : '۰۹۹۰۷۰۲۷۱۲۳', 
                                style: const TextStyle(fontSize: 12, color: Colors.black54)
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.chevron_left, color: Colors.black45, size: 24),
                    ],
                  ),
                ),
              ),
              Divider(height: 12, thickness: 1, color: Colors.grey.withAlpha(30), indent: 14, endIndent: 14),
              ...List.generate(menuItems.length, (index) {
                final item = menuItems[index];
                final isHovered = activeIndex == index;
                final String itemTitle = getTranslation(context, item['titleKey']) ?? item['defaultTitle'];

                return MouseRegion(
                  onEnter: (_) => setState(() => activeIndex = index),
                  onExit: (_) => setState(() => activeIndex = null),
                  child: AnimatedScale(
                    scale: isHovered ? 1.07 : 1.0, 
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutBack,
                      height: itemHeight - 4,
                      margin: EdgeInsets.symmetric(horizontal: isHovered ? 4 : 12, vertical: 2),
                      transform: Matrix4.translationValues(0, isHovered ? -8 : 0, 0),
                      decoration: BoxDecoration(
                        color: isHovered ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: isHovered ? Colors.black.withValues(alpha: 0.12) : Colors.transparent,
                            blurRadius: 14,
                            spreadRadius: 1,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => _navigateToPage(item['titleKey']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: (isHovered || index == menuItems.length - 1)
                                    ? Colors.transparent
                                    : Colors.grey.withAlpha(15),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['icon'], 
                                size: 20, 
                                color: isHovered ? safirBrandColor : Colors.black54
                              ),
                              const SizedBox(width: 16),
                              Text(
                                itemTitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isHovered ? FontWeight.w600 : FontWeight.w400,
                                  color: isHovered ? safirBrandColor : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
