import 'dart:io';
import 'dart:ui';
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
  final Color primaryAccent = const Color(0xFF0066FF);
  final Color darkTextColor = const Color(0xFF0F172A);
  final Color successColor = const Color(0xFF22C55E);
  final Color borderLightColor = const Color(0xFFF1F5F9);

  bool _enableNotifications = true;
  bool _enableSoundEffects = true;
  bool _isLoadingCache = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableNotifications = prefs.getBool('enable_notifications') ?? true;
      _enableSoundEffects = prefs.getBool('enable_sounds') ?? true;
    });
  }

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

  Future<void> _applyLanguageChange(String langCode) async {
    // تغییر locale در easy_localization
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
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.language_rounded, color: darkTextColor),
                  const SizedBox(width: 10),
                  Text(
                    'select_language_title'.tr().isEmpty ? 'انتخاب زبان' : 'select_language_title'.tr(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor),
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
                    activeColor: primaryAccent,
                    onChanged: (value) {
                      if (value != null) setDialogState(() => selectedTempLang = value);
                    },
                  ),
                  Divider(height: 1, color: borderLightColor),
                  RadioListTile<String>(
                    title: Text('lang_pashto'.tr().isEmpty ? 'پښتو' : 'lang_pashto'.tr()),
                    value: 'ps',
                    groupValue: selectedTempLang,
                    activeColor: primaryAccent,
                    onChanged: (value) {
                      if (value != null) setDialogState(() => selectedTempLang = value);
                    },
                  ),
                  Divider(height: 1, color: borderLightColor),
                  RadioListTile<String>(
                    title: Text('lang_english'.tr().isEmpty ? 'English' : 'lang_english'.tr()),
                    value: 'en',
                    groupValue: selectedTempLang,
                    activeColor: primaryAccent,
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
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'clear_cache_title'.tr().isEmpty ? 'پاکسازی حافظه موقت' : 'clear_cache_title'.tr(),
          style: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
        ),
        content: Text('clear_cache_desc'.tr().isEmpty ? 'آیا از پاکسازی فایل‌های موقت برنامه اطمینان دارید؟' : 'clear_cache_desc'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr().isEmpty ? 'انصراف' : 'cancel'.tr(), style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _performClearCache();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('cache_cleared_msg'.tr().isEmpty ? 'حافظه موقت با موفقیت پاکسازی شد' : 'cache_cleared_msg'.tr()),
                    backgroundColor: successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            child: Text('confirm'.tr().isEmpty ? 'تایید' : 'confirm'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'terms_of_service'.tr().isEmpty ? 'قوانین و مقررات' : 'terms_of_service'.tr(),
          style: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            'terms_of_service_detail'.tr().isEmpty
                ? 'استفاده از اپلیکیشن تاکسی آنلاین سفیر به منزله پذیرش تمامی قوانین مربوط به حریم خصوصی، امنیت سفر و پرداخت‌ها می‌باشد.'
                : 'terms_of_service_detail'.tr(),
            style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF334155)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr().isEmpty ? 'بستن' : 'close'.tr(), style: TextStyle(color: primaryAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLangCode = context.locale.languageCode;
    final bool isRtl = currentLangCode != 'en';
    final IconData chevronIcon = isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'settings_title'.tr().isEmpty ? 'تنظیمات' : 'settings_title'.tr(),
            style: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_back_ios_new_rounded : Icons.arrow_back_ios_rounded,
              color: darkTextColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: borderLightColor, height: 1),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          children: [
            // ۱. عمومی و زبان
            _buildSectionHeader('general_settings_header'.tr().isEmpty ? 'عمومی' : 'general_settings_header'.tr()),
            _buildCardGroup([
              UrbanListTile(
                leading: Icon(Icons.language_rounded, color: darkTextColor),
                title: Text(
                  'app_language_label'.tr().isEmpty ? 'زبان برنامه' : 'app_language_label'.tr(),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: darkTextColor),
                ),
                subtitle: Text(
                  "${'current_language_prefix'.tr().isEmpty ? 'زبان فعلی' : 'current_language_prefix'.tr()}: ${_getLanguageName(currentLangCode)}",
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                trailing: Icon(chevronIcon, color: const Color(0xFF94A3B8)),
                onTap: _showLanguageDialog,
              ),
            ]),

            const SizedBox(height: 24),

            // ۲. اعلانات و صداها
            _buildSectionHeader('notifications_header'.tr().isEmpty ? 'اعلانات و صداها' : 'notifications_header'.tr()),
            _buildCardGroup([
              SwitchListTile(
                activeColor: Colors.white,
                activeTrackColor: primaryAccent,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE2E8F0),
                secondary: Icon(Icons.notifications_active_outlined, color: darkTextColor),
                title: Text(
                  'enable_notifications_label'.tr().isEmpty ? 'دریافت اعلانات' : 'enable_notifications_label'.tr(),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: darkTextColor),
                ),
                value: _enableNotifications,
                onChanged: _toggleNotification,
              ),
              Divider(height: 1, indent: 56, color: borderLightColor),
              SwitchListTile(
                activeColor: Colors.white,
                activeTrackColor: primaryAccent,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE2E8F0),
                secondary: Icon(Icons.volume_up_outlined, color: darkTextColor),
                title: Text(
                  'enable_sounds_label'.tr().isEmpty ? 'افکت‌های صوتی' : 'enable_sounds_label'.tr(),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: darkTextColor),
                ),
                value: _enableSoundEffects,
                onChanged: _toggleSound,
              ),
            ]),

            const SizedBox(height: 24),

            // ۳. حافظه و داده‌ها
            _buildSectionHeader('privacy_cache_header'.tr().isEmpty ? 'حافظه و داده‌ها' : 'privacy_cache_header'.tr()),
            _buildCardGroup([
              UrbanListTile(
                leading: _isLoadingCache 
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: primaryAccent))
                    : Icon(Icons.cleaning_services_outlined, color: darkTextColor),
                title: Text(
                  'clear_cache_btn'.tr().isEmpty ? 'پاکسازی حافظه موقت' : 'clear_cache_btn'.tr(),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: darkTextColor),
                ),
                subtitle: Text(
                  'clear_cache_subtitle'.tr().isEmpty ? 'آزادسازی فضای اشغال‌شده توسط عکس‌ها و نقشه‌ها' : 'clear_cache_subtitle'.tr(),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                trailing: Icon(chevronIcon, color: const Color(0xFF94A3B8)),
                onTap: _isLoadingCache ? null : _clearCacheDialog,
              ),
            ]),

            const SizedBox(height: 24),

            // ۴. درباره سفیر
            _buildSectionHeader('about_app_header'.tr().isEmpty ? 'درباره سفیر' : 'about_app_header'.tr()),
            _buildCardGroup([
              UrbanListTile(
                leading: Icon(Icons.description_outlined, color: darkTextColor),
                title: Text(
                  'terms_of_service'.tr().isEmpty ? 'شرایط و قوانین استفاده' : 'terms_of_service'.tr(),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: darkTextColor),
                ),
                trailing: Icon(chevronIcon, color: const Color(0xFF94A3B8)),
                onTap: _showTermsDialog,
              ),
              Divider(height: 1, indent: 56, color: borderLightColor),
              UrbanListTile(
                leading: Icon(Icons.info_outline_rounded, color: darkTextColor),
                title: Text(
                  'app_version_label'.tr().isEmpty ? 'نسخه برنامه' : 'app_version_label'.tr(),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: darkTextColor),
                ),
                subtitle: const Text(
                  "v1.0.0 (Safir Passengers)",
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'up_to_date'.tr().isEmpty ? 'به‌روز است' : 'up_to_date'.tr(),
                    style: TextStyle(color: primaryAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: darkTextColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLightColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }
}
