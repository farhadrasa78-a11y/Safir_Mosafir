import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
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

  // متد هوشمند تغییر زبان و اعمال روی easy_localization
  Future<void> _applyLanguageChange(String langCode) async {
    // تغییر زبان در EasyLocalization
    await context.setLocale(Locale(langCode));

    if (widget.onLanguageChanged != null) {
      widget.onLanguageChanged!(langCode);
    }

    if (mounted) {
      setState(() {}); // بازسازی UI صفحه فعلی
      Navigator.pop(context); // بستن دیالوگ
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'pa':
      case 'ps':
        return 'lang_pashto'.tr();
      case 'en':
        return 'lang_english'.tr();
      case 'fa':
      case 'dr':
      default:
        return 'lang_dari'.tr();
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
                    'select_language_title'.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text('lang_dari'.tr()),
                    value: 'fa',
                    groupValue: selectedTempLang,
                    activeColor: safirBrandColor,
                    onChanged: (value) {
                      if (value != null) setDialogState(() => selectedTempLang = value);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: Text('lang_pashto'.tr()),
                    value: 'ps',
                    groupValue: selectedTempLang,
                    activeColor: safirBrandColor,
                    onChanged: (value) {
                      if (value != null) setDialogState(() => selectedTempLang = value);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: Text('lang_english'.tr()),
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
                    'cancel'.tr(),
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
                    'confirm'.tr(),
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

  // دیالوگ پاکسازی حافظه موقت (Cache)
  void _clearCacheDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('clear_cache_title'.tr()),
        content: Text('clear_cache_desc'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr(), style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: safirBrandColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('cache_cleared_msg'.tr()),
                  backgroundColor: successColor,
                ),
              );
            },
            child: Text('confirm'.tr(), style: const TextStyle(color: Colors.white)),
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
          'settings_title'.tr(),
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
          // -------------------------------------------------------------
          // ۱. عمومی و زبان
          // -------------------------------------------------------------
          _buildSectionHeader('general_settings_header'.tr()),
          _buildCardGroup([
            UrbanListTile(
              leading: Icon(Icons.language, color: safirBrandColor),
              title: Text(
                'app_language_label'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              subtitle: Text(
                "${'current_language_prefix'.tr()}: ${_getLanguageName(currentLangCode)}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: const Icon(Icons.chevron_left, color: Colors.grey),
              onTap: _showLanguageDialog,
            ),
          ]),

          const SizedBox(height: 20),

          // -------------------------------------------------------------
          // ۲. اعلانات و صداها
          // -------------------------------------------------------------
          _buildSectionHeader('notifications_header'.tr()),
          _buildCardGroup([
            SwitchListTile(
              activeColor: safirBrandColor,
              secondary: Icon(Icons.notifications_active_outlined, color: safirBrandColor),
              title: Text(
                'enable_notifications_label'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              value: _enableNotifications,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _enableNotifications = val);
              },
            ),
            const Divider(height: 1, indent: 50),
            SwitchListTile(
              activeColor: safirBrandColor,
              secondary: Icon(Icons.volume_up_outlined, color: safirBrandColor),
              title: Text(
                'enable_sounds_label'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              value: _enableSoundEffects,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _enableSoundEffects = val);
              },
            ),
          ]),

          const SizedBox(height: 20),

          // -------------------------------------------------------------
          // ۳. حافظه و امنیت
          // -------------------------------------------------------------
          _buildSectionHeader('privacy_cache_header'.tr()),
          _buildCardGroup([
            UrbanListTile(
              leading: Icon(Icons.cleaning_services_outlined, color: safirBrandColor),
              title: Text(
                'clear_cache_btn'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              subtitle: Text(
                'clear_cache_subtitle'.tr(),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              trailing: const Icon(Icons.chevron_left, color: Colors.grey),
              onTap: _clearCacheDialog,
            ),
          ]),

          const SizedBox(height: 20),

          // -------------------------------------------------------------
          // ۴. درباره و پشتیبانی
          // -------------------------------------------------------------
          _buildSectionHeader('about_app_header'.tr()),
          _buildCardGroup([
            UrbanListTile(
              leading: Icon(Icons.description_outlined, color: safirBrandColor),
              title: Text(
                'terms_of_service'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              trailing: const Icon(Icons.chevron_left, color: Colors.grey),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 50),
            UrbanListTile(
              leading: Icon(Icons.info_outline, color: safirBrandColor),
              title: Text(
                'app_version_label'.tr(),
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
                  'up_to_date'.tr(),
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

  // ویجت عنوان بخش‌ها
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

  // ویجت گروه‌بندی کارت‌ها
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
