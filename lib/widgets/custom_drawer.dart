import 'package:flutter/material.dart';

import '../appInfo/auth_provider.dart';
import '../globle/global_var.dart';
import '../pages/about_page.dart';
import '../pages/profile_page.dart';
import '../pages/trips_history_page.dart';
import '../widgets/sign_out_dialog.dart';
import '../pages/settings_screen.dart'; 
import '../theme/app_colors.dart'; // آدرس فایل رنگ‌ها

class CustomDrawer extends StatelessWidget {
  final String userName;
  final AuthenticationProvider authProvider; 

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: const Color(0xFFF9F9F9),
        child: Column(
          children: [
            // ۱. سربرگ اختصاصی برند سفیر (#145A41)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 25, right: 20, left: 20),
              decoration: const BoxDecoration(
                color: AppColors.primaryBrand, // #145A41
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage("assets/images/avatarman.png"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isNotEmpty ? userName : (getTranslation('safir_passenger') ?? "مسافر سفیر"),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, color: Colors.white70, size: 14),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                userEmail,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ۲. لیست گزینه‌ها
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                children: [
                  _buildDrawerCard(
                    icon: Icons.account_box_outlined,
                    title: getTranslation('user_account') ?? "حساب کاربری",
                    iconColor: AppColors.primaryBrand,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
                    },
                  ),
                  _buildDrawerCard(
                    icon: Icons.history_rounded,
                    title: getTranslation('trips_history') ?? "تاریخچه سفرها",
                    iconColor: AppColors.primaryBrand,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TripsHistoryPage()));
                    },
                  ),
                  _buildDrawerCard(
                    icon: Icons.settings_outlined,
                    title: getTranslation('app_settings') ?? "تنظیمات برنامه",
                    iconColor: AppColors.primaryBrand,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(
                            currentLanguage: 'دری',
                            onLanguageChanged: (lang) {},
                          ),
                        ),
                      );
                    },
                  ),
                  _buildDrawerCard(
                    icon: Icons.privacy_tip_outlined,
                    title: getTranslation('privacy_security') ?? "حریم خصوصی و امنیت",
                    iconColor: Colors.grey.shade700,
                    onTap: () {},
                  ),
                  _buildDrawerCard(
                    icon: Icons.help_outline_rounded,
                    title: getTranslation('help_support') ?? "مرکز کمک و پشتیبانی",
                    iconColor: Colors.grey.shade700,
                    onTap: () {},
                  ),
                  _buildDrawerCard(
                    icon: Icons.info_outline_rounded,
                    title: getTranslation('about_safir') ?? "درباره سفیر",
                    iconColor: Colors.grey.shade700,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
                    },
                  ),
                  _buildDrawerCard(
                    icon: Icons.star_rate_outlined,
                    title: getTranslation('rate_app') ?? "امتیاز به اپلیکیشن",
                    iconColor: Colors.amber,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // ۳. بخش خروج
            Padding(
              padding: const EdgeInsets.all(15),
              child: _buildDrawerCard(
                icon: Icons.logout_rounded,
                title: getTranslation('sign_out') ?? "خروج از حساب کاربری",
                iconColor: Colors.redAccent,
                textColor: Colors.redAccent,
                onTap: () async {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SignOutDialog(
                        title: getTranslation('sign_out_title') ?? 'خروج',
                        description: getTranslation('sign_out_confirm') ?? 'آیا مطمئن هستید که می‌خواهید از حساب خود خارج شوید؟',
                        onSignOut: () async {
                          await authProvider.signOut(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerCard({
    required IconData icon,
    required String title,
    required Color iconColor,
    Color textColor = Colors.black87,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        trailing: Icon(Icons.chevron_left, color: Colors.grey.shade400, size: 18),
        onTap: onTap,
      ),
    );
  }
}
