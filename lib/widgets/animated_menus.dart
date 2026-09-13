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

Future<void> _makeSupportCall(BuildContext context) async {
  String phone = '+93700000000';

  try {
    final DatabaseReference adminRef = FirebaseDatabase.instance
        .ref()
        .child('admin_settings')
        .child('support_phone');

    final DataSnapshot snapshot = await adminRef.get();

    if (snapshot.exists && snapshot.value != null) {
      phone = snapshot.value.toString();
    }
  } catch (e) {
    debugPrint('خطا در دریافت شماره پشتیبانی: $e');
  }

  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phone,
  );

  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('امکان برقراری تماس وجود ندارد: $phone'),
      ),
    );
  }
}

void _shareInviteCode(BuildContext context) {
  final User? user = FirebaseAuth.instance.currentUser;

  final String referralCode = user != null && user.uid.length >= 6
      ? user.uid.substring(0, 6).toUpperCase()
      : 'SAFIR2026';

  final String shareMessage =
      '''سلام! از اپلیکیشن سفیر برای درخواست تاکسی و پیک استفاده کن.
با وارد کردن کد معرفی من ($referralCode) تخفیف بگیر!
دانلود برنامه: https://safirapp.com/download''';

  Share.share(shareMessage);
}

void _showDiscountModal(BuildContext context) {
  final TextEditingController discountController =
      TextEditingController();

  bool isLoading = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_offer_rounded,
                      color: safirBrandColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'discount_code'.tr().isEmpty
                          ? 'ثبت کد تخفیف'
                          : 'discount_code'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: discountController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'کد تخفیف را وارد کنید',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: safirBrandColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            final String code =
                                discountController.text.trim();

                            if (code.isEmpty) {
                              return;
                            }

                            setModalState(() {
                              isLoading = true;
                            });

                            try {
                              final DatabaseReference couponRef =
                                  FirebaseDatabase.instance
                                      .ref()
                                      .child('coupons')
                                      .child(code);

                              final DataSnapshot snapshot =
                                  await couponRef.get();

                              if (!context.mounted) return;

                              setModalState(() {
                                isLoading = false;
                              });

                              if (snapshot.exists) {
                                Navigator.pop(sheetContext);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'کد تخفیف با موفقیت اعمال شد!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'کد تخفیف معتبر نیست',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (!context.mounted) return;

                              setModalState(() {
                                isLoading = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('خطا: $e'),
                                ),
                              );
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'اعمال کد',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

void _showAboutAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: safirBrandColor,
              ),
              const SizedBox(width: 8),
              Text(
                'about_app'.tr().isEmpty
                    ? 'درباره سفیر'
                    : 'about_app'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'about_app_desc'.tr().isEmpty
                ? '''اپلیکیشن آنلاین درخواست تاکسی، باربری و خدمات بین‌شهری سفیر.
نسخه: 1.0.0
ارائه‌دهنده خدمات حمل‌ونقل ایمن و سریع.'''
                : 'about_app_desc'.tr(),
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'close'.tr().isEmpty ? 'بستن' : 'close'.tr(),
                style: const TextStyle(
                  color: safirBrandColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class ExactAnimatedMenu extends StatefulWidget {
  const ExactAnimatedMenu({

    super.key,
    this.currentLanguage,
    this.onLanguageChanged,
  });

  final String? currentLanguage;
  final ValueChanged<String>? onLanguageChanged;

  @override
  State<ExactAnimatedMenu> createState() =>
      _ProfileAnimatedMenuState();
}

class _ExactAnimatedMenuState extends State<ProfileAnimatedMenu> {
  String _displayName() {
    if (userName.trim().isNotEmpty) {
      return userName.trim();
    }

    final String translated = 'user_default'.tr();

    if (translated.isNotEmpty && translated != 'user_default') {
      return translated;
    }

    return 'کاربر سفیر';
  }

  String _displayPhone() {
    if (userPhone.trim().isNotEmpty) {
      return userPhone.trim();
    }

    return '۰۹۹۰۷۰۲۷۱۲۳';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            tooltip: 'بازگشت',
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black87,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'profile'.tr().isEmpty
                ? 'پروفایل'
                : 'profile'.tr(),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildSectionTitle('حساب کاربری'),
              _buildMenuItem(
                icon: Icons.history_rounded,
                title: 'trips_history'.tr().isEmpty
                    ? 'سفرها'
                    : 'trips_history'.tr(),
                subtitle: 'مشاهده سفرهای قبلی',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TripsScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.person_add_alt_1_rounded,
                title: 'invite_friends'.tr().isEmpty
                    ? 'دعوت دوستان'
                    : 'invite_friends'.tr(),
                subtitle: 'دوستان خود را به سفیر دعوت کنید',
                onTap: () => _shareInviteCode(context),
              ),
              _buildMenuItem(
                icon: Icons.mail_outline_rounded,
                title: 'messages'.tr().isEmpty
                    ? 'پیام‌ها'
                    : 'messages'.tr(),
                subtitle: 'پیام‌ها و اطلاعیه‌ها',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MessagesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              _buildSectionTitle('خدمات و پشتیبانی'),
              _buildMenuItem(
                icon: Icons.local_offer_outlined,
                title: 'discount_code'.tr().isEmpty
                    ? 'کد تخفیف'
                    : 'discount_code'.tr(),
                subtitle: 'ثبت و استفاده از کد تخفیف',
                onTap: () => _showDiscountModal(context),
              ),
              _buildMenuItem(
                icon: Icons.headset_mic_outlined,
                title: 'support_contact'.tr().isEmpty
                    ? 'تماس با پشتیبانی'
                    : 'support_contact'.tr(),
                subtitle: 'ما همیشه آماده کمک هستیم',
                onTap: () => _makeSupportCall(context),
              ),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'settings'.tr().isEmpty
                    ? 'تنظیمات'
                    : 'settings'.tr(),
                subtitle: 'زبان و تنظیمات برنامه',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        currentLanguage:
                            widget.currentLanguage ?? 'fa',
                        onLanguageChanged:
                            widget.onLanguageChanged ?? (_) {},
                      ),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.info_outline_rounded,
                title: 'about_app'.tr().isEmpty
                    ? 'درباره برنامه'
                    : 'about_app'.tr(),
                subtitle: 'اطلاعات نسخه و سفیر',
                onTap: () => _showAboutAppDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF145A41),
            Color(0xFF21825D),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: safirBrandColor.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.45),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 35,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _displayPhone(),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 11),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'حساب کاربری سفیر',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_rounded,
            color: Colors.white,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 4,
        bottom: 9,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: safirBrandColor.withOpacity(0.08),
          highlightColor: safirBrandColor.withOpacity(0.04),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE6ECE8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: safirBrandColor.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: safirBrandColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.black38,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
