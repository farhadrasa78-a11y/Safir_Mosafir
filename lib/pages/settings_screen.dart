import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/urban_list_tile.dart';

class SettingsScreen extends StatefulWidget {
  final String currentLanguage;
  final ValueChanged<String>? onLanguageChanged;

  const SettingsScreen({
    super.key,
    this.currentLanguage = 'fa',
    this.onLanguageChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // پالت رنگی مرجع پروژه
  final Color safirBrandColor = const Color(0xFF145A41);   // رنگ اصلی برند
  final Color successColor = const Color(0xFF22C55E);       // رنگ موفقیت

  // وضعیت سوییچ‌های تنظیمات
  bool _enableNotifications = true;
  bool _enableSoundEffects = true;
  bool _isLoadingCache = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ۱. بارگذاری وضعیت تنظیمات از SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableNotifications = prefs.getBool('enable_notifications') ?? true;
      _enableSoundEffects = prefs.getBool('enable_sounds') ?? true;
    });
  }

  // ۲. ذخیره وضعیت سوییچ‌ها
  Future<void> _toggleNotification(bool val) async {
    HapticFeedback.selectionClick();
    setState(() => _enableNotifications = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_notifications', val);
  }

  Future<void> _toggleSound(bool val) async {
    HapticFeedback.selectionClick();
    setState(() => _enableSoundEffects = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_sounds', val);
  }

  // متد هوشمند تغییر زبان و اعمال روی easy_localization
  Future<void> _applyLanguageChange(String langCode) async {
    await context.setLocale(Locale(langCode));

    if (widget.onLanguageChanged != null) {
      widget.onLanguageChanged!(langCode);
    }

    if (mounted) {
      setState(() {}); 
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'pa':
      case 'ps':
        return 'lang_pashto'.tr().isEmpty ? 'پښتو' : 'lang_pashto'.tr();
      case 'en':
        return 'lang_english'.tr().isEmpty ? 'English' : 'lang_english'.tr();
      case 'fa':
      case 'dr':
      default:
        return 'lang_dari'.tr().isEmpty ? 'فارسی / دری' : 'lang_dari'.tr();
    }
  }

  void _showLanguageDialog() {
    final currentLang = context.locale.languageCode;
    String selectedTempLang = (currentLang == 'pa' || currentLang == 'ps') 
        ? 'ps' 
        : (currentLang == 'en' ? 'en' : 'fa');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.language, color: safirBrandColor),
                  const SizedBox(width: 8),
                  Text(
                    'select_language_title'.tr().isEmpty ? 'انتخاب زبان' : 'select_language_title'.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text('lang_dari'.tr().isEmpty ? 'فارسی / دری' : 'lang_dari'.tr()),
                    value: 'fa',
                    groupValue: selectedTempLang,
                    activeColor: safirBrandColor,
                    onChanged: (value) {
                      if (value != null) setDialogState(() => selectedTempLang = value);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: Text('lang_pashto'.tr().isEmpty ? 'پښتو' : 'lang_pashto'.tr()),
                    value: 'ps',
                    groupValue: selectedTempLang,
                    activeColor: safirBrandColor,
                    onChanged: (value) {
                      if (value != null) setDialogState(() => selectedTempLang = value);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: Text('lang_english'.tr().isEmpty ? 'English' : 'lang_english'.tr()),
                    value: 'en',
                    groupValue: selectedTempLang,
                    activeColor: safirBrandColor,
                    onChanged: (value) {
                      if (value != null) setDialogState(() => selectedTempLang = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'cancel'.tr().isEmpty ? 'انصراف' : 'cancel'.tr(),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: safirBrandColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _applyLanguageChange(selectedTempLang);
                  },
                  child: Text(
                    'confirm'.tr().isEmpty ? 'تایید' : 'confirm'.tr(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ۳. عملیات واقعی پاکسازی حافظه کش اپلیکیشن
  Future<void> _performClearCache() async {
    setState(() => _isLoadingCache = true);
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (e) {
      debugPrint("خطا در پاکسازی کش: $e");
    } finally {
      setState(() => _isLoadingCache = false);
    }
  }

  void _clearCacheDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('clear_cache_title'.tr().isEmpty ? 'پاکسازی حافظه موقت' : 'clear_cache_title'.tr()),
        content: Text('clear_cache_desc'.tr().isEmpty ? 'آیا از پاکسازی فایل‌های موقت برنامه اطمینان دارید؟' : 'clear_cache_desc'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr().isEmpty ? 'انصراف' : 'cancel'.tr(), style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: safirBrandColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _performClearCache();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('cache_cleared_msg'.tr().isEmpty ? 'حافظه موقت با موفقیت پاکسازی شد' : 'cache_cleared_msg'.tr()),
                    backgroundColor: successColor,
                  ),
                );
              }
            },
            child: Text('confirm'.tr().isEmpty ? 'تایید' : 'confirm'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ۴. دیالوگ قوانین و شرایط استفاده
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('terms_of_service'.tr().isEmpty ? 'قوانین و مقررات' : 'terms_of_service'.tr()),
        content: SingleChildScrollView(
          child: Text(
            'terms_of_service_detail'.tr().isEmpty
                ? 'استفاده از اپلیکیشن تاکسی آنلاین سفیر به منزله پذیرش تمامی قوانین مربوط به حریم خصوصی، امنیت سفر و پرداخت‌ها می‌باشد.'
                : 'terms_of_service_detail'.tr(),
            style: const TextStyle(fontSize: 13, height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr().isEmpty ? 'بستن' : 'close'.tr(), style: TextStyle(color: safirBrandColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLangCode = context.locale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'settings_title'.tr().isEmpty ? 'تنظیمات' : 'settings_title'.tr(),
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        children: [
          // ۱. عمومی و زبان
          _buildSectionHeader('general_settings_header'.tr().isEmpty ? 'عمومی' : 'general_settings_header'.tr()),
          _buildCardGroup([
            UrbanListTile(
              leading: Icon(Icons.language, color: safirBrandColor),
              title: Text(
                'app_language_label'.tr().isEmpty ? 'زبان برنامه' : 'app_language_label'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              subtitle: Text(
                "${'current_language_prefix'.tr().isEmpty ? 'زبان فعلی' : 'current_language_prefix'.tr()}: ${_getLanguageName(currentLangCode)}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: const Icon(Icons.chevron_left, color: Colors.grey),
              onTap: _showLanguageDialog,
            ),
          ]),

          const SizedBox(height: 20),

          // ۲. اعلانات و صداها
          _buildSectionHeader('notifications_header'.tr().isEmpty ? 'اعلانات و صداها' : 'notifications_header'.tr()),
          _buildCardGroup([
            SwitchListTile(
              activeColor: safirBrandColor,
              secondary: Icon(Icons.notifications_active_outlined, color: safirBrandColor),
              title: Text(
                'enable_notifications_label'.tr().isEmpty ? 'دریافت اعلانات' : 'enable_notifications_label'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              value: _enableNotifications,
              onChanged: _toggleNotification,
            ),
            const Divider(height: 1, indent: 50),
            SwitchListTile(
              activeColor: safirBrandColor,
              secondary: Icon(Icons.volume_up_outlined, color: safirBrandColor),
              title: Text(
                'enable_sounds_label'.tr().isEmpty ? 'افکت‌های صوتی' : 'enable_sounds_label'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              value: _enableSoundEffects,
              onChanged: _toggleSound,
            ),
          ]),

          const SizedBox(height: 20),

          // ۳. حافظه و امنیت
          _buildSectionHeader('privacy_cache_header'.tr().isEmpty ? 'حافظه و داده‌ها' : 'privacy_cache_header'.tr()),
          _buildCardGroup([
            UrbanListTile(
              leading: _isLoadingCache 
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: safirBrandColor))
                  : Icon(Icons.cleaning_services_outlined, color: safirBrandColor),
              title: Text(
                'clear_cache_btn'.tr().isEmpty ? 'پاکسازی حافظه موقت' : 'clear_cache_btn'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              subtitle: Text(
                'clear_cache_subtitle'.tr().isEmpty ? 'آزادسازی فضای اشغال‌شده توسط عکس‌ها و نقشه‌ها' : 'clear_cache_subtitle'.tr(),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              trailing: const Icon(Icons.chevron_left, color: Colors.grey),
              onTap: _isLoadingCache ? null : _clearCacheDialog,
            ),
          ]),

          const SizedBox(height: 20),

          // ۴. درباره و پشتیبانی
          _buildSectionHeader('about_app_header'.tr().isEmpty ? 'درباره سفیر' : 'about_app_header'.tr()),
          _buildCardGroup([
            UrbanListTile(
              leading: Icon(Icons.description_outlined, color: safirBrandColor),
              title: Text(
                'terms_of_service'.tr().isEmpty ? 'شرایط و قوانین استفاده' : 'terms_of_service'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              trailing: const Icon(Icons.chevron_left, color: Colors.grey),
              onTap: _showTermsDialog,
            ),
            const Divider(height: 1, indent: 50),
            UrbanListTile(
              leading: Icon(Icons.info_outline, color: safirBrandColor),
              title: Text(
                'app_version_label'.tr().isEmpty ? 'نسخه برنامه' : 'app_version_label'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              subtitle: const Text(
                "v1.0.0 (Safir Passengers)",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: safirBrandColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'up_to_date'.tr().isEmpty ? 'به‌روز است' : 'up_to_date'.tr(),
                  style: TextStyle(color: safirBrandColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: safirBrandColor,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(children: children),
    );
  }
}
