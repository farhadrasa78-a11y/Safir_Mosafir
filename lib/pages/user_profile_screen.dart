import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:safir_passengers/global/global_var.dart';
import 'package:safir_passengers/theme/app_colors.dart';

// -------------------------------------------------------------
// ۱. صفحه اصلی پروفایل
// -------------------------------------------------------------
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref();

  bool _useWheelchair = false;
  bool _isLoading = true;
  String _userName = '';
  String _userPhone = '';
  String _userRating = '4.5';
  String _photoUrl = '';

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
      _photoUrl = currentUser.photoURL ?? '';

      try {
        DatabaseEvent event = await _userRef
            .child("users")
            .child(currentUser.uid)
            .once()
            .timeout(const Duration(seconds: 8));

        if (event.snapshot.value != null && mounted) {
          Map userData = event.snapshot.value as Map;
          setState(() {
            _userName = userData["name"] ??
                userData["fullName"] ??
                userData["userName"] ??
                currentUser.displayName ??
                '';
            _userPhone = userData["phone"] ??
                userData["phoneNumber"] ??
                currentUser.phoneNumber ??
                '';
            _userRating = userData["rating"]?.toString() ?? '4.5';
            _useWheelchair = userData["useWheelchair"] ?? false;
            _photoUrl = userData["photoUrl"] ?? currentUser.photoURL ?? '';
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
      await _userRef.child("users").child(currentUser.uid).update({"useWheelchair": val});
    }
  }

  Future<void> _signOut() async {
    HapticFeedback.mediumImpact();
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("sign_out".tr().isEmpty ? "خروج از حساب" : "sign_out".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text("sign_out_confirm_msg".tr().isEmpty ? "آیا مایل به خروج از حساب کاربری هستید؟" : "sign_out_confirm_msg".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("cancel".tr().isEmpty ? "انصراف" : "cancel".tr(), style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text("exit".tr().isEmpty ? "خروج" : "exit".tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  Future<void> _switchAccount() async {
    HapticFeedback.mediumImpact();
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("switch_account_title".tr().isEmpty ? "تغییر حساب کاربری" : "switch_account_title".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text("switch_account_confirm_msg".tr().isEmpty ? "برای ورود با حساب دیگر باید از حساب فعلی خارج شوید. ادامه می‌دهید؟" : "switch_account_confirm_msg".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("cancel".tr().isEmpty ? "انصراف" : "cancel".tr(), style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrand,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text("confirm".tr().isEmpty ? "تایید" : "confirm".tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
                          child: _photoUrl.isEmpty ? Icon(Icons.person, size: 50, color: Colors.grey[400]) : null,
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
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "user_info_section_title".tr().isEmpty ? "اطلاعات کاربری" : "user_info_section_title".tr(),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      TextButton(
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                          _loadProfileData();
                        },
                        child: Text(
                          "edit_button_label".tr().isEmpty ? "ویرایش" : "edit_button_label".tr(),
                          style: const TextStyle(color: AppColors.originBlue, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _userName.isEmpty ? ("default_user_name".tr().isEmpty ? "کاربر سفیر" : "default_user_name".tr()) : _userName, 
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatNumberByLocale(context, _userPhone), 
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      "badges_section_title".tr().isEmpty ? "نشان‌های افتخار" : "badges_section_title".tr(),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 120,
                          margin: const EdgeInsetsDirectional.only(end: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2ECE89), Color(0xFF15A968)],
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
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
                                  "badge_polite_label".tr().isEmpty ? "مسافر باخلاق" : "badge_polite_label".tr(),
                                  style: const TextStyle(color: Color(0xFF15A968), fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 120,
                          margin: const EdgeInsetsDirectional.only(start: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
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
                    ],
                  ),
                  const SizedBox(height: 25),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      "accessibility_section_title".tr().isEmpty ? "دسترس‌پذیری" : "accessibility_section_title".tr(),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      "accessibility_subtitle".tr().isEmpty ? "تنظیمات ویژه افراد دارای معلولیت" : "accessibility_subtitle".tr(),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
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
                          "wheelchair_option_label".tr().isEmpty ? "نیاز به صندلی چرخ‌دار" : "wheelchair_option_label".tr(),
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
                  const SizedBox(height: 25),
                  Container(
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
                          onTap: _switchAccount,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.redAccent),
                          title: Text(
                            "exit".tr().isEmpty ? "خروج از حساب" : "exit".tr(),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.redAccent),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          onTap: _signOut,
                        ),
                      ],
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
// ۲. صفحه ویرایش مشخصات و آپلود عکس
// -------------------------------------------------------------
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String _initialName = "";
  String _initialPhone = "";
  String _initialEmail = "";
  String _initialAddress = "";
  String _initialDob = "";
  bool _initialPremium = false;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPremium = false;
  bool _isChanged = false;

  File? _imageFile;
  String _photoUrl = "";

  @override
  void initState() {
    super.initState();
    _getUserData();

    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _emailController.addListener(_checkChanges);
    _addressController.addListener(_checkChanges);
    _dobController.addListener(_checkChanges);
  }

  void _checkChanges() {
    String currentName = _nameController.text.trim();
    String currentPhone = toEnglishDigits(_phoneController.text.trim());
    String currentEmail = _emailController.text.trim();
    String currentAddress = _addressController.text.trim();
    String currentDob = toEnglishDigits(_dobController.text.trim());

    String cleanInitialPhone = toEnglishDigits(_initialPhone);
    String cleanInitialDob = toEnglishDigits(_initialDob);

    bool hasChanged = (currentName != _initialName) ||
        (currentPhone != cleanInitialPhone) ||
        (currentEmail != _initialEmail) ||
        (currentAddress != _initialAddress) ||
        (currentDob != cleanInitialDob) ||
        (_isPremium != _initialPremium) ||
        (_imageFile != null);

    if (hasChanged != _isChanged) {
      setState(() {
        _isChanged = hasChanged;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _checkChanges();
    }
  }

  Future<void> _getUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _initialPhone = currentUser.phoneNumber ?? "";
      _initialEmail = currentUser.email ?? "";
      _initialName = currentUser.displayName ?? "";
      _photoUrl = currentUser.photoURL ?? "";

      try {
        DatabaseEvent event = await _userRef
            .child("users")
            .child(currentUser.uid)
            .once()
            .timeout(const Duration(seconds: 8));

        if (event.snapshot.value != null && mounted) {
          Map userData = event.snapshot.value as Map;
          setState(() {
            _initialName = userData["name"] ?? userData["fullName"] ?? userData["userName"] ?? currentUser.displayName ?? "";
            _initialPhone = userData["phone"] ?? userData["phoneNumber"] ?? currentUser.phoneNumber ?? "";
            _initialEmail = userData["email"] ?? currentUser.email ?? "";
            _initialAddress = userData["address"] ?? "";
            _initialDob = userData["dob"] ?? "";
            _initialPremium = userData["isPremium"] ?? false;
            _photoUrl = userData["photoUrl"] ?? currentUser.photoURL ?? "";

            _nameController.text = _initialName;
            _phoneController.text = formatNumberByLocale(context, _initialPhone);
            _emailController.text = _initialEmail;
            _addressController.text = _initialAddress;
            _dobController.text = formatNumberByLocale(context, _initialDob);
            _isPremium = _initialPremium;
          });
        } else if (mounted) {
          setState(() {
            _nameController.text = _initialName;
            _phoneController.text = formatNumberByLocale(context, _initialPhone);
            _emailController.text = _initialEmail;
          });
        }
      } catch (e) {
        debugPrint("Error fetching edit data: $e");
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isChanged = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    String cleanedPhone = toEnglishDigits(_phoneController.text.trim());
    String cleanedDob = toEnglishDigits(_dobController.text.trim());
    String uploadedPhotoUrl = _photoUrl;

    try {
      // ۱. آپلود تصویر در صورت تغییر
      if (_imageFile != null) {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child("user_profiles")
            .child("${currentUser.uid}.jpg");

        UploadTask uploadTask = storageRef.putFile(_imageFile!);
        TaskSnapshot snapshot = await uploadTask;
        uploadedPhotoUrl = await snapshot.ref.getDownloadURL();
      }

      Map<String, dynamic> updateData = {
        "name": _nameController.text.trim(),
        "phone": cleanedPhone,
        "email": _emailController.text.trim(),
        "address": _addressController.text.trim(),
        "dob": cleanedDob,
        "isPremium": _isPremium,
        "photoUrl": uploadedPhotoUrl,
      };

      // ۲. آپدیت دیتابیس Realtime
      await _userRef.child("users").child(currentUser.uid).update(updateData);
      
      // ۳. آپدیت نام و تصویر در FirebaseAuth
      if (_nameController.text.trim().isNotEmpty) {
        await currentUser.updateDisplayName(_nameController.text.trim());
      }
      if (uploadedPhotoUrl.isNotEmpty) {
        await currentUser.updatePhotoURL(uploadedPhotoUrl);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("profile_update_success".tr().isEmpty ? "اطلاعات با موفقیت به‌روزرسانی شد" : "profile_update_success".tr()),
            backgroundColor: AppColors.primaryBrand,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${"profile_update_error".tr().isEmpty ? "خطا در بروزرسانی" : "profile_update_error".tr()}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showChangePhoneBottomSheet() {
    HapticFeedback.lightImpact();
    final TextEditingController newPhoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                    'change_phone_title'.tr().isEmpty ? 'تغییر شماره تماس' : 'change_phone_title'.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'change_phone_subtitle'.tr().isEmpty ? 'شماره جدید خود را جهت ارسال کد تایید وارد کنید' : 'change_phone_subtitle'.tr(),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: newPhoneController,
                keyboardType: TextInputType.phone,
                textDirection: ui.TextDirection.ltr,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: "phone_number_label".tr().isEmpty ? "شماره تلفن" : "phone_number_label".tr(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    overlayColor: AppColors.primaryButtonPressed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (newPhoneController.text.trim().isNotEmpty) {
                      HapticFeedback.mediumImpact();
                      String newPhone = newPhoneController.text.trim();
                      _phoneController.text = formatNumberByLocale(context, newPhone);
                      _checkChanges();
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('verification_code_sent'.tr(args: [_phoneController.text]))),
                      );
                    }
                  },
                  child: Text('continue_btn'.tr().isEmpty ? 'ادامه' : 'continue_btn'.tr(), style: const TextStyle(color: AppColors.buttonText, fontSize: 16)),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          "user_info_section_title".tr().isEmpty ? "ویرایش مشخصات" : "user_info_section_title".tr(),
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (_photoUrl.isNotEmpty ? NetworkImage(_photoUrl) as ImageProvider : null),
                          child: (_imageFile == null && _photoUrl.isEmpty)
                              ? Icon(Icons.person, size: 55, color: Colors.grey[400])
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickProfileImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBrand,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  Text(
                    "main_account_info_title".tr().isEmpty ? "اطلاعات حساب اصلی" : "main_account_info_title".tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBrand),
                  ),
                  const SizedBox(height: 15),

                  _buildInputField(
                    _nameController, 
                    "full_name_label".tr().isEmpty ? "نام و نام خانوادگی" : "full_name_label".tr(), 
                    textInputAction: TextInputAction.next
                  ),
                  
                  GestureDetector(
                    onTap: _showChangePhoneBottomSheet,
                    child: AbsorbPointer(
                      child: _buildInputField(
                        _phoneController, 
                        "phone_number_label".tr().isEmpty ? "شماره تلفن" : "phone_number_label".tr(), 
                        readOnly: true,
                        isLtr: true
                      ),
                    ),
                  ),

                  _buildInputField(
                    _emailController, 
                    "email_label".tr().isEmpty ? "ایمیل" : "email_label".tr(), 
                    keyboardType: TextInputType.emailAddress, 
                    textInputAction: TextInputAction.next,
                    isLtr: true
                  ),
                  _buildInputField(
                    _addressController, 
                    "address_label".tr().isEmpty ? "آدرس" : "address_label".tr(), 
                    textInputAction: TextInputAction.next
                  ),
                  _buildInputField(
                    _dobController, 
                    "dob_label".tr().isEmpty ? "تاریخ تولد" : "dob_label".tr(), 
                    keyboardType: TextInputType.datetime, 
                    textInputAction: TextInputAction.done,
                    isLtr: true
                  ),
                  
                  const SizedBox(height: 20),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: SwitchListTile(
                      activeColor: AppColors.primaryBrand,
                      title: Text(
                        "premium_account_title".tr().isEmpty ? "حساب ویژه (پریمیوم)" : "premium_account_title".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        "premium_account_subtitle".tr().isEmpty ? "دریافت قابلیت‌ها و تخفیف‌های ویژه سفیر" : "premium_account_subtitle".tr(),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      value: _isPremium,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        setState(() => _isPremium = val);
                        _checkChanges();
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isChanged ? AppColors.primaryButton : Colors.grey.shade300,
                        overlayColor: AppColors.primaryButtonPressed,
                        elevation: _isChanged ? 2 : 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: (_isChanged && !_isSaving) ? _updateUserData : null,
                      child: _isSaving
                          ? const CircularProgressIndicator(color: AppColors.buttonText)
                          : Text(
                              "save_changes_btn".tr().isEmpty ? "ذخیره تغییرات" : "save_changes_btn".tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _isChanged ? AppColors.buttonText : Colors.grey.shade600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller, 
    String label, {
    bool readOnly = false, 
    bool isLtr = false,
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
        textDirection: isLtr ? ui.TextDirection.ltr : ui.TextDirection.rtl,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.primaryBrand, width: 1.5),
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
    _dobController.dispose();
    super.dispose();
  }
}
