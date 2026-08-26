import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:share_plus/share_plus.dart';

import 'package:safir_passengers/pages/settings_screen.dart';
import 'package:safir_passengers/pages/user_profile_screen.dart';
import 'package:safir_passengers/pages/sub_screens.dart';
import 'package:safir_passengers/global/global_var.dart';

const Color safirBrandColor = Color(0xFF145A41);

// ۱. تماس با پشتیبانی
Future<void> _makeSupportCall(BuildContext context) async {
  String phone = "+93700000000"; 

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
        SnackBar(content: Text('امکان برقراری تماس وجود ندارد: $phone')),
      );
    }
  }
}

// ۲. دعوت دوستان (اشتراک‌گذاری کد معرفی)
void _shareInviteCode(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;
  final String referralCode = user != null ? user.uid.substring(0, 6).toUpperCase() : "SAFIR2026";
  final String shareMessage = 
      'سلام! از اپلیکیشن سفیر برای درخواست تاکسی و پیک استفاده کن.\n'
      'با وارد کردن کد معرفی من ($referralCode) تخفیف بگیر!\n'
      'دانلود برنامه: https://safirapp.com/download';

  Share.share(shareMessage);
}

// ۳. ورود و بررسی کد تخفیف
void _showDiscountModal(BuildContext context) {
  final TextEditingController discountController = TextEditingController();
  bool isLoading = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 24,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_offer_rounded, color: safirBrandColor),
                    const SizedBox(width: 8),
                    Text(
                      'discount_code'.tr().isEmpty ? 'ثبت کد تخفیف' : 'discount_code'.tr(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: discountController,
                  decoration: InputDecoration(
                    hintText: 'کد تخفیف را وارد کنید',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: safirBrandColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isLoading ? null : () async {
                      final code = discountController.text.trim();
                      if (code.isEmpty) return;

                      setModalState(() => isLoading = true);

                      try {
                        DatabaseReference couponRef = FirebaseDatabase.instance.ref().child("coupons").child(code);
                        DataSnapshot snapshot = await couponRef.get();

                        setModalState(() => isLoading = false);

                        if (snapshot.exists) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('کد تخفیف با موفقیت اعمال شد!'), backgroundColor: Colors.green),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('کد تخفیف معتبر نیست'), backgroundColor: Colors.red),
                          );
                        }
                      } catch (e) {
                        setModalState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('خطا: $e')),
                        );
                      }
                    },
                    child: isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('اعمال کد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

// ۴. نمایش دیالوگ درباره برنامه
void _showAboutAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.info_outline, color: safirBrandColor),
          const SizedBox(width: 8),
          Text(
            'about_app'.tr().isEmpty ? 'درباره سفیر' : 'about_app'.tr(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(
        'about_app_desc'.tr().isEmpty 
            ? 'اپلیکیشن آنلاین درخواست تاکسی، باربری و خدمات بین‌شهری سفیر.\nنسخه: 1.0.0\nارائه دهنده خدمات حمل‌ونقل ایمن و سریع.'
            : 'about_app_desc'.tr(),
        style: const TextStyle(fontSize: 13, height: 1.6),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'close'.tr().isEmpty ? 'بستن' : 'close'.tr(),
            style: const TextStyle(color: safirBrandColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

// منوی کشویی Drawer اصلی
class ExactAnimatedMenu extends StatefulWidget {
  final String? currentLanguage;
  final ValueChanged<String>? onLanguageChanged;

  const ExactAnimatedMenu({
    super.key,
    this.currentLanguage,
    this.onLanguageChanged,
  });

  @override
  State<ExactAnimatedMenu> createState() => _ExactAnimatedMenuState();
}

class _ExactAnimatedMenuState extends State<ExactAnimatedMenu> {
  int? activeIndex;

  final List<Map<String, dynamic>> menuItems = [
    {'titleKey': 'invite_friends', 'defaultTitle': 'دعوت دوستان', 'icon': Icons.person_add_alt_1_outlined},
    {'titleKey': 'settings', 'defaultTitle': 'تنظیمات', 'icon': Icons.settings_outlined},
    {'titleKey': 'messages', 'defaultTitle': 'پیام‌ها', 'icon': Icons.mail_outline},
    {'titleKey': 'discount_code', 'defaultTitle': 'کد تخفیف', 'icon': Icons.local_offer_outlined},
    {'titleKey': 'support_contact', 'defaultTitle': 'تماس با پشتیبانی', 'icon': Icons.headset_mic_outlined},
    {'titleKey': 'about_app', 'defaultTitle': 'درباره برنامه', 'icon': Icons.info_outline_rounded},
  ];

  void _navigateToPage(String titleKey) {
    Navigator.pop(context);

    switch (titleKey) {
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsScreen(
              currentLanguage: widget.currentLanguage ?? 'fa',
              onLanguageChanged: widget.onLanguageChanged ?? (_) {},
            ),
          ),
        );
        break;
      case 'invite_friends':
        _shareInviteCode(context);
        break;
      case 'messages':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MessagesScreen()));
        break;
      case 'discount_code':
        _showDiscountModal(context);
        break;
      case 'support_contact':
        _makeSupportCall(context);
        break;
      case 'about_app':
        _showAboutAppDialog(context);
        break;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                            userName.isNotEmpty ? userName : 'user_default'.tr().isEmpty ? 'کاربر سفیر' : 'user_default'.tr(), 
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
              
              final String translatedTitle = (item['titleKey'] as String).tr();
              final String itemTitle = translatedTitle.isNotEmpty && translatedTitle != item['titleKey']
                  ? translatedTitle 
                  : item['defaultTitle'];

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
                );
              }),
          ],
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

  final List<Map<String, dynamic>> menuItems = [
    {'titleKey': 'trips_history', 'defaultTitle': 'سفرها', 'icon': Icons.history},
    {'titleKey': 'invite_friends', 'defaultTitle': 'دعوت دوستان', 'icon': Icons.person_add_alt_1_outlined},
    {'titleKey': 'messages', 'defaultTitle': 'پیام‌ها', 'icon': Icons.mail_outline},
    {'titleKey': 'discount_code', 'defaultTitle': 'کد تخفیف', 'icon': Icons.local_offer_outlined},
    {'titleKey': 'support_contact', 'defaultTitle': 'تماس با پشتیبانی', 'icon': Icons.headset_mic_outlined},
    {'titleKey': 'about_app', 'defaultTitle': 'درباره برنامه', 'icon': Icons.info_outline_rounded},
  ];

  void _navigateToPage(String titleKey) {
    Navigator.pop(context); 

    switch (titleKey) {
      case 'trips_history':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const TripsScreen()));
        break;
      case 'invite_friends':
        _shareInviteCode(context);
        break;
      case 'messages':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MessagesScreen()));
        break;
      case 'discount_code':
        _showDiscountModal(context);
        break;
      case 'support_contact':
        _makeSupportCall(context);
        break;
      case 'about_app':
        _showAboutAppDialog(context);
        break;
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
                              userName.isNotEmpty ? userName : 'user_default'.tr().isEmpty ? 'کاربر سفیر' : 'user_default'.tr(),
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

              final String translatedTitle = (item['titleKey'] as String).tr();
              final String itemTitle = translatedTitle.isNotEmpty && translatedTitle != item['titleKey']
                  ? translatedTitle 
                  : item['defaultTitle'];

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
                );
              }),
          ],
        ),
      ),
    );
  }
}
