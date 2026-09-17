import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:safir_passengers/global/global_var.dart';
import 'package:safir_passengers/authentication/register_screen.dart';

class AppColors {
  static const Color primaryBrand = Color(0xFF0066FF);
  static const Color primaryButton = Color(0xFF0066FF);
  static const Color primaryButtonPressed = Color(0xFF4348D6);
  static const Color buttonText = Colors.white;
  static const Color textPrimary = Color(0xFF26293D);
  static const Color textSecondary = Color(0xFF9AA0A6);
  static const Color appBarDivider = Color(0xFFD6DADF);
  static const Color sectionDivider = Color(0xFFF1F5F9);
  static const Color fieldBorder = Color(0xFFD8DBE0);
  static const Color wheelGreen = Color(0xFF39B169);
}

String toEnglishDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  for (int i = 0; i < 10; i++) {
    input = input.replaceAll(farsi[i], english[i]).replaceAll(arabic[i], english[i]);
  }
  return input;
}

// -------------------------------------------------------------
// ۱. صفحه اصلی پروفایل (حساب کاربری)
// -------------------------------------------------------------
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _useWheelchair = false;
  bool _isLoading = true;
  String _userName = '';
  String _userPhone = '';
  String _userRating = '4.5';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _userName = currentUser.displayName ?? '';
      _userPhone = currentUser.phoneNumber ?? '';

      try {
        DocumentSnapshot userDoc = await _firestore
            .collection("users")
            .doc(currentUser.uid)
            .get()
            .timeout(const Duration(seconds: 8));

        if (userDoc.exists && userDoc.data() != null && mounted) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _userName = userData["name"] ??
                userData["full_name"] ??
                userData["fullName"] ??
                userData["userName"] ??
                currentUser.displayName ??
                '';
            _userPhone = userData["phone"] ??
                userData["phoneNumber"] ??
                userData["phone_number"] ??
                currentUser.phoneNumber ??
                '';
            _userRating = userData["rating"]?.toString() ?? '4.5';
            _useWheelchair = userData["useWheelchair"] ?? false;
          });
        }
      } catch (e) {
        debugPrint("Error loading profile data: $e");
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateWheelchair(bool val) async {
    HapticFeedback.selectionClick();
    setState(() => _useWheelchair = val);
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection("users").doc(currentUser.uid).set(
        {"useWheelchair": val},
        SetOptions(merge: true),
      );
    }
  }

  Future<void> _openEditProfileDrawer() async {
    HapticFeedback.lightImpact();

    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const EditProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );

    _loadProfileData();
  }

  void _showBadgeDetails(String title, String description, IconData icon, Color color) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrand,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "got_it_btn".tr().isEmpty ? "متوجه شدم" : "got_it_btn".tr(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogout({bool isSwitchAccount = false}) async {
    HapticFeedback.mediumImpact();

    String title = isSwitchAccount
        ? ("switch_account_title".tr().isEmpty ? "تغییر حساب کاربری" : "switch_account_title".tr())
        : ("sign_out".tr().isEmpty ? "خروج از حساب" : "sign_out".tr());

    String content = isSwitchAccount
        ? ("switch_account_confirm_msg".tr().isEmpty ? "برای ورود با حساب دیگر، باید از حساب فعلی خارج شوید. ادامه می‌دهید؟" : "switch_account_confirm_msg".tr())
        : ("sign_out_confirm_msg".tr().isEmpty ? "آیا مایل به خروج از حساب کاربری هستید؟" : "sign_out_confirm_msg".tr());

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(content, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text("cancel".tr().isEmpty ? "انصراف" : "cancel".tr(), style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSwitchAccount ? AppColors.primaryBrand : Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text("confirm".tr().isEmpty ? "تأیید" : "confirm".tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        try {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          if (await googleSignIn.isSignedIn()) {
            await googleSignIn.signOut();
          }
        } catch (e) {
          debugPrint("Google sign out error: $e");
        }

        await FirebaseAuth.instance.signOut();

        if (mounted) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        debugPrint("Error signing out: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "user_account_title".tr().isEmpty ? "حساب کاربری" : "user_account_title".tr(),
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBrand))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE5E5E5),
                              width: 0.8,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/default_profile.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              formatNumberByLocale(context, _userRating),
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "main_account_info_title".tr().isEmpty ? "اطلاعات کاربری" : "main_account_info_title".tr(),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              GestureDetector(
                                onTap: _openEditProfileDrawer,
                                child: Text(
                                  "edit".tr().isEmpty ? "ویرایش" : "edit".tr(),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF5E60CE)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _userName.isEmpty
                                    ? ("default_user_name".tr().isEmpty ? "کاربر سفیر" : "default_user_name".tr())
                                    : _userName,
                                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                formatNumberByLocale(context, _userPhone),
                                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        "badges_section_title".tr().isEmpty ? "مدال‌های افتخار" : "badges_section_title".tr(),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _showBadgeDetails(
                              "badge_polite_title".tr().isEmpty ? "مسافر بااخلاق" : "badge_polite_title".tr(),
                              "badge_polite_desc".tr().isEmpty ? "رانندگان سفیر رفتار محترمانه و صمیمانه شما در طول سفر را تحسین کرده‌اند. از همراهی باارزش شما سپاسگزاریم!" : "badge_polite_desc".tr(),
                              Icons.stars,
                              const Color(0xFF15A968),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 120,
                              margin: const EdgeInsetsDirectional.only(end: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2ECE89), Color(0xFF15A968)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.stars, size: 40, color: Colors.amber),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                    child: Text(
                                      "badge_polite_label".tr().isEmpty ? "خوش‌رفتار" : "badge_polite_label".tr(),
                                      style: const TextStyle(color: Color(0xFF15A968), fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _showBadgeDetails(
                              "badge_punctual_title".tr().isEmpty ? "مسافر وقت‌شناس" : "badge_punctual_title".tr(),
                              "badge_punctual_desc".tr().isEmpty ? "حضور به موقع شما در مبدأ باعث سفری سریع‌تر و روان‌تر برای شما و راننده می‌شود. شما الگوی وقت‌شناسی هستید!" : "badge_punctual_desc".tr(),
                              Icons.access_time_filled,
                              const Color(0xFF7B1FA2),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 120,
                              margin: const EdgeInsetsDirectional.only(start: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.access_time_filled, size: 40, color: Colors.amber),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                    child: Text(
                                      "badge_punctual_label".tr().isEmpty ? "وقت‌شناس" : "badge_punctual_label".tr(),
                                      style: const TextStyle(color: Color(0xFF7B1FA2), fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        "accessibility_section_title".tr().isEmpty ? "دسترس‌پذیری" : "accessibility_section_title".tr(),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        "accessibility_subtitle".tr().isEmpty ? "با فعال کردن گزینه متناسب با شرایطتان می‌توانیم تجربه بهتری از سفر برایتان ایجاد کنیم." : "accessibility_subtitle".tr(),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "wheelchair_option_label".tr().isEmpty ? "از ویلچر استفاده می‌کنم" : "wheelchair_option_label".tr(),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Switch(
                            value: _useWheelchair,
                            activeColor: AppColors.primaryBrand,
                            onChanged: _updateWheelchair,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.switch_account_outlined, color: AppColors.primaryBrand),
                            title: Text(
                              "switch_account_title".tr().isEmpty ? "تغییر حساب کاربری" : "switch_account_title".tr(),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            onTap: () => _handleLogout(isSwitchAccount: true),
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: const Icon(Icons.logout, color: Colors.redAccent),
                            title: Text(
                              "exit".tr().isEmpty ? "خروج" : "exit".tr(),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.redAccent),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            onTap: () => _handleLogout(isSwitchAccount: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

// -------------------------------------------------------------
// ۲. صفحه اطلاعات کاربری (ویرایش)
// -------------------------------------------------------------
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _initialName = '';
  String _initialPhone = '';
  String _initialEmail = '';
  String _initialAddress = '';
  String _initialGender = '';
  String _initialDob = '';

  String _selectedGender = '';
  String _selectedDob = '';

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isChanged = false;

  final List<String> _dariMonths = [
    'month_hamal'.tr().isEmpty ? 'حمل' : 'month_hamal'.tr(),
    'month_sawr'.tr().isEmpty ? 'ثور' : 'month_sawr'.tr(),
    'month_jawza'.tr().isEmpty ? 'جوزا' : 'month_jawza'.tr(),
    'month_saratan'.tr().isEmpty ? 'سرطان' : 'month_saratan'.tr(),
    'month_asad'.tr().isEmpty ? 'اسد' : 'month_asad'.tr(),
    'month_sonbola'.tr().isEmpty ? 'سنبله' : 'month_sonbola'.tr(),
    'month_mizan'.tr().isEmpty ? 'میزان' : 'month_mizan'.tr(),
    'month_aqrab'.tr().isEmpty ? 'عقرب' : 'month_aqrab'.tr(),
    'month_qaws'.tr().isEmpty ? 'قوس' : 'month_qaws'.tr(),
    'month_jady'.tr().isEmpty ? 'جدی' : 'month_jady'.tr(),
    'month_dalwa'.tr().isEmpty ? 'دلو' : 'month_dalwa'.tr(),
    'month_hoot'.tr().isEmpty ? 'حوت' : 'month_hoot'.tr(),
  ];

  int _getMaxDays(int monthIndex) {
    if (monthIndex < 6) return 31;
    if (monthIndex < 11) return 30;
    return 29;
  }

  @override
  void initState() {
    super.initState();
    _getUserData();

    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _emailController.addListener(_checkChanges);
    _addressController.addListener(_checkChanges);
  }

  Future<void> _getUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _initialPhone = currentUser.phoneNumber ?? '';
      _initialEmail = currentUser.email ?? '';
      _initialName = currentUser.displayName ?? '';

      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get()
            .timeout(const Duration(seconds: 8));

        if (userDoc.exists && userDoc.data() != null && mounted) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          _initialName = userData['name'] ??
              userData['full_name'] ??
              userData['fullName'] ??
              userData['userName'] ??
              _initialName;
          _initialPhone = userData['phone'] ??
              userData['phoneNumber'] ??
              userData['phone_number'] ??
              _initialPhone;
          _initialEmail = userData['email'] ?? _initialEmail;
          _initialAddress = userData['address'] ?? '';
          _initialGender = userData['gender'] ?? '';
          _initialDob = userData['dob'] ?? '';
        }
      } catch (e) {
        debugPrint('Error fetching edit data: $e');
      }

      if (mounted) {
        _nameController.text = _initialName;
        _phoneController.text = _initialPhone;
        _emailController.text = _initialEmail;
        _addressController.text = _initialAddress;
        _selectedGender = _initialGender;
        _selectedDob = _initialDob;
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isChanged = false;
      });
    }
  }

  void _checkChanges() {
    final String currentPhone = toEnglishDigits(_phoneController.text.trim());
    final String cleanInitialPhone = toEnglishDigits(_initialPhone);

    final bool hasChanged = (_nameController.text.trim() != _initialName) ||
        (currentPhone != cleanInitialPhone) ||
        (_emailController.text.trim() != _initialEmail) ||
        (_addressController.text.trim() != _initialAddress) ||
        (_selectedGender != _initialGender) ||
        (_selectedDob != _initialDob);

    if (hasChanged != _isChanged && mounted) {
      setState(() => _isChanged = hasChanged);
    }
  }

  Future<void> _updateUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    final String cleanedPhone = toEnglishDigits(_phoneController.text.trim());

    try {
      final Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'phone': cleanedPhone,
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'gender': _selectedGender,
        'dob': _selectedDob,
      };

      await _firestore.collection('users').doc(currentUser.uid).set(
            updateData,
            SetOptions(merge: true),
          );

      if (_nameController.text.trim().isNotEmpty) {
        await currentUser.updateDisplayName(_nameController.text.trim());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'profile_update_success'.tr().isEmpty
                  ? 'اطلاعات با موفقیت به‌روزرسانی شد'
                  : 'profile_update_success'.tr(),
            ),
            backgroundColor: AppColors.primaryBrand,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${'profile_update_error'.tr().isEmpty ? 'خطا در به‌روزرسانی' : 'profile_update_error'.tr()}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showGenderPicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String tempGender = _selectedGender;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'gender_sheet_title'.tr().isEmpty
                            ? 'جنسیت'
                            : 'gender_sheet_title'.tr(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _genderOptionTile(
                    label: 'gender_male'.tr().isEmpty ? 'مرد' : 'gender_male'.tr(),
                    value: 'gender_male'.tr().isEmpty ? 'مرد' : 'gender_male'.tr(),
                    groupValue: tempGender,
                    onTap: () => setModalState(() => tempGender = 'gender_male'.tr().isEmpty ? 'مرد' : 'gender_male'.tr()),
                  ),
                  const Divider(height: 1, color: AppColors.fieldBorder),
                  _genderOptionTile(
                    label: 'gender_female'.tr().isEmpty ? 'زن' : 'gender_female'.tr(),
                    value: 'gender_female'.tr().isEmpty ? 'زن' : 'gender_female'.tr(),
                    groupValue: tempGender,
                    onTap: () => setModalState(() => tempGender = 'gender_female'.tr().isEmpty ? 'زن' : 'gender_female'.tr()),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() => _selectedGender = tempGender);
                        _checkChanges();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'confirm_btn'.tr().isEmpty ? 'تایید' : 'confirm_btn'.tr(),
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
            );
          },
        );
      },
    );
  }

  Widget _genderOptionTile({
    required String label,
    required String value,
    required String groupValue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              activeColor: AppColors.primaryBrand,
              onChanged: (_) => onTap(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() {
    HapticFeedback.lightImpact();
    int selectedDay = 15;
    int selectedMonthIndex = 5;
    int selectedYear = 1375;

    final dayController =
        FixedExtentScrollController(initialItem: selectedDay - 1);
    final monthController =
        FixedExtentScrollController(initialItem: selectedMonthIndex);
    final yearController =
        FixedExtentScrollController(initialItem: selectedYear - 1340);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final int maxDays = _getMaxDays(selectedMonthIndex);

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'dob_label'.tr().isEmpty ? 'تاریخ تولد' : 'dob_label'.tr(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IgnorePointer(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(height: 2, color: AppColors.wheelGreen),
                              const SizedBox(height: 40),
                              Container(height: 2, color: AppColors.wheelGreen),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ListWheelScrollView.useDelegate(
                                controller: dayController,
                                itemExtent: 42,
                                perspective: 0.005,
                                diameterRatio: 1.3,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) =>
                                    setModalState(() => selectedDay = index + 1),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: maxDays,
                                  builder: (context, index) => Center(
                                    child: Text(
                                      formatNumberByLocale(context, '${index + 1}'),
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: selectedDay == index + 1
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontWeight: selectedDay == index + 1
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListWheelScrollView.useDelegate(
                                controller: monthController,
                                itemExtent: 42,
                                perspective: 0.005,
                                diameterRatio: 1.3,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) {
                                  setModalState(() {
                                    selectedMonthIndex = index;
                                    final int newMax = _getMaxDays(index);
                                    if (selectedDay > newMax) {
                                      selectedDay = newMax;
                                    }
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: _dariMonths.length,
                                  builder: (context, index) => Center(
                                    child: Text(
                                      _dariMonths[index],
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: selectedMonthIndex == index
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontWeight: selectedMonthIndex == index
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListWheelScrollView.useDelegate(
                                controller: yearController,
                                itemExtent: 42,
                                perspective: 0.005,
                                diameterRatio: 1.3,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) => setModalState(
                                    () => selectedYear = 1340 + index),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 70,
                                  builder: (context, index) => Center(
                                    child: Text(
                                      formatNumberByLocale(context, '${1340 + index}'),
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: selectedYear == 1340 + index
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontWeight: selectedYear == 1340 + index
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDob =
                              '${formatNumberByLocale(context, selectedDay.toString())} ${_dariMonths[selectedMonthIndex]} ${formatNumberByLocale(context, selectedYear.toString())}';
                        });
                        _checkChanges();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'confirm_btn'.tr().isEmpty ? 'تایید' : 'confirm_btn'.tr(),
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
            );
          },
        );
      },
    );
  }

  void _showChangePhoneBottomSheet() {
    HapticFeedback.lightImpact();
    final TextEditingController newPhoneController =
        TextEditingController(text: '+93');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'change_phone_title'.tr().isEmpty
                        ? 'تغییر شماره تماس'
                        : 'change_phone_title'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'change_phone_subtitle'.tr().isEmpty
                    ? 'شماره جدید خود را جهت ارسال کد تایید وارد کنید'
                    : 'change_phone_subtitle'.tr(),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: newPhoneController,
                keyboardType: TextInputType.phone,
                textDirection: ui.TextDirection.ltr,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'phone_number_label'.tr().isEmpty
                      ? 'شماره تلفن'
                      : 'phone_number_label'.tr(),
                  hintText: '+93 7XX XXX XXX',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final String cleaned =
                        toEnglishDigits(newPhoneController.text.trim());
                    if (cleaned.isNotEmpty && cleaned != '+93') {
                      HapticFeedback.mediumImpact();
                      _phoneController.text = cleaned;
                      _checkChanges();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'continue_btn'.tr().isEmpty ? 'ادامه' : 'continue_btn'.tr(),
                    style: const TextStyle(color: AppColors.buttonText, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'user_info_section_title'.tr().isEmpty
              ? 'اطلاعات کاربری'
              : 'user_info_section_title'.tr(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.appBarDivider),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBrand),
            )
          : SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5E5E5),
                      width: 0.8,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/default_profile.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF3F4F6),
                        child: Icon(
                          Icons.person,
                          size: 56,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'main_account_info_title'.tr().isEmpty
                          ? 'اطلاعات اصلی'
                          : 'main_account_info_title'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildInputField(
                      _nameController,
                      'full_name_label'.tr().isEmpty
                          ? 'نام و نام خانوادگی'
                          : 'full_name_label'.tr(),
                      textInputAction: TextInputAction.next,
                    ),
                    GestureDetector(
                      onTap: _showChangePhoneBottomSheet,
                      child: AbsorbPointer(
                        child: _buildInputField(
                          _phoneController,
                          'phone_number_label'.tr().isEmpty
                              ? 'شمارهٔ موبایل'
                              : 'phone_number_label'.tr(),
                          readOnly: true,
                        ),
                      ),
                    ),
                    _buildInputField(
                      _emailController,
                      'email_label'.tr().isEmpty ? 'ایمیل' : 'email_label'.tr(),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 8,
                width: double.infinity,
                color: AppColors.sectionDivider,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'sub_account_info_title'.tr().isEmpty
                          ? 'اطلاعات فرعی'
                          : 'sub_account_info_title'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildInputField(
                      _addressController,
                      'address_label'.tr().isEmpty ? 'آدرس' : 'address_label'.tr(),
                      hintText: 'address_hint'.tr().isEmpty
                          ? 'آدرس‌تان را بنویسید.'
                          : 'address_hint'.tr(),
                      textInputAction: TextInputAction.next,
                    ),
                    GestureDetector(
                      onTap: _showGenderPicker,
                      child: AbsorbPointer(
                        child: _buildInputField(
                          TextEditingController(text: _selectedGender),
                          'gender_label'.tr().isEmpty
                              ? 'جنسیت'
                              : 'gender_label'.tr(),
                          readOnly: true,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showDatePicker,
                      child: AbsorbPointer(
                        child: _buildInputField(
                          TextEditingController(text: _selectedDob),
                          'dob_label'.tr().isEmpty ? 'تاریخ تولد' : 'dob_label'.tr(),
                          readOnly: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isChanged
                              ? AppColors.primaryButton
                              : Colors.grey.shade300,
                          elevation: _isChanged ? 2 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed:
                            (_isChanged && !_isSaving) ? _updateUserData : null,
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: AppColors.buttonText,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'save_changes_btn'.tr().isEmpty
                                    ? 'ذخیره'
                                    : 'save_changes_btn'.tr(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _isChanged
                                      ? AppColors.buttonText
                                      : Colors.grey.shade600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // فیلد استاندارد مطابقت‌یافته با جهت کامل صفحه (LTR و RTL)
  Widget _buildInputField(
    TextEditingController controller,
    String label, {
    String? hintText,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          alignLabelWithHint: true,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
            final bool focused = states.contains(WidgetState.focused);
            return TextStyle(
              color: focused ? AppColors.primaryBrand : Colors.grey,
              fontSize: 13,
              fontWeight: focused ? FontWeight.w600 : FontWeight.normal,
            );
          }),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.fieldBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.fieldBorder),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.primaryBrand, width: 1.4),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
