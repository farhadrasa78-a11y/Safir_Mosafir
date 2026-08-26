import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final Color safirColor = const Color(0xFF145A41);

  @override
  Widget build(BuildContext context) {
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'about_safir_title'.tr().isEmpty 
              ? 'درباره سفیر' 
              : 'about_safir_title'.tr(),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            isRTL ? Icons.arrow_back_ios_new_rounded : Icons.arrow_back_rounded,
            color: Colors.black87,
            size: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🚖 لوگو / نماد شیک برند سفیر
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: safirColor.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: safirColor.withOpacity(0.15), width: 1.5),
              ),
              child: Icon(
                Icons.local_taxi_rounded,
                size: 72,
                color: safirColor,
              ),
            ),
            const SizedBox(height: 20),
            
            // 🏷️ نام برند و نسخه
            Text(
              'safir_brand_name'.tr().isEmpty 
                  ? 'تاکسی آنلاین سفیر' 
                  : 'safir_brand_name'.tr(),
              style: TextStyle(
                color: safirColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${'app_version_label'.tr().isEmpty ? 'نسخه' : 'app_version_label'.tr()} 1.0.0",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 28),
            
            // 📄 توضیحات پلتفرم
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                'about_safir_description'.tr().isEmpty 
                    ? 'سفیر پلتفرم هوشمند درخواست آنلاین تاکسی و پیک در افغانستان است که با هدف تسهیل سفرهای درون‌شهری و بین‌شهری، ارائه خدمات امن، سریع و با قیمت مناسب طراحی شده است.' 
                    : 'about_safir_description'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // 📞 بخش پشتیبانی و گزارشات
            Align(
              alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                'support_reports_title'.tr().isEmpty 
                    ? 'ارتباط با پشتیبانی و مدیریت' 
                    : 'support_reports_title'.tr(),
                style: TextStyle(
                  color: safirColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // ✉️ کارت اطلاعات تماس
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: safirColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.email_outlined, color: safirColor, size: 20),
                    ),
                    title: Text(
                      'support_email_label'.tr().isEmpty 
                          ? 'پشتیبانی مشتریان' 
                          : 'support_email_label'.tr(),
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Text(
                      "support@safir.af",
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () {
                      // امکان اضافه کردن url_launcher برای ارسال ایمیل direct
                    },
                  ),
                  Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade200),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: safirColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.headset_mic_outlined, color: safirColor, size: 20),
                    ),
                    title: Text(
                      'management_contact_label'.tr().isEmpty 
                          ? 'ارتباط با مدیریت' 
                          : 'management_contact_label'.tr(),
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Text(
                      "info@safir.af",
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () {},
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
