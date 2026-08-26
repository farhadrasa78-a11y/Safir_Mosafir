import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // پکیج اضافه شد
import 'package:safir_passengers/global/global_var.dart';
import 'package:safir_passengers/theme/app_colors.dart';
import 'package:safir_passengers/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          "my_profile_title".tr(), // جایگزینی با easy_localization
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(
          children: [
            // بخش آواتار و تصویر پروفایل
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardBackground,
                      border: Border.all(
                        color: AppColors.primaryBrand.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: AppColors.primaryBrand,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // کارت نمایش اطلاعات کاربری
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.15)),
              ),
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: AppColors.primaryBrand),
                    title: Text(
                      "full_name_label".tr(), // جایگزینی با easy_localization
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    subtitle: Text(
                      userName.isEmpty ? "unknown_text".tr() : userName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.phone_android_outlined, color: AppColors.primaryBrand),
                    title: Text(
                      "phone_number_label".tr(), // جایگزینی با easy_localization
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    subtitle: Text(
                      userPhone.isEmpty 
                          ? "unknown_text".tr() 
                          : formatNumberByLocale(context, userPhone),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.email_outlined, color: AppColors.primaryBrand),
                    title: Text(
                      "email_address_label".tr(), // جایگزینی با easy_localization
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    subtitle: Text(
                      userEmail.isEmpty ? "unknown_text".tr() : userEmail,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // دکمه هدایت به صفحه ویرایش اطلاعات
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  overlayColor: AppColors.primaryButtonPressed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const EditProfileScreen()),
                  ).then((value) {
                    setState(() {});
                  });
                },
                icon: const Icon(Icons.edit, color: AppColors.buttonText, size: 20),
                label: Text(
                  "edit_profile_btn".tr(), // جایگزینی با easy_localization
                  style: const TextStyle(
                    color: AppColors.buttonText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
