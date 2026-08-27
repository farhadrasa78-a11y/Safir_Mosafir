import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:safir_passengers/appInfo/auth_provider.dart';
import 'package:safir_passengers/authentication/user_information_screen.dart';
import 'package:safir_passengers/methods/common_methods.dart';
import 'package:safir_passengers/pages/blocked_screen.dart';
import 'package:safir_passengers/pages/safir_home_screen.dart';
import 'package:safir_passengers/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController phoneController = TextEditingController();
  final CommonMethods commonMethods = CommonMethods();

  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();

    // دری/Farsi اولویت دارد؛ فقط اگر زبان ذخیره‌شده انگلیسی نبود تغییر نمی‌کند.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.locale.languageCode == 'en') {
        context.setLocale(const Locale('fa'));
      }
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  bool _isPhoneValid(String input) {
    final clean = input.trim();
    return RegExp(r'^[7][0-9]{8}$').hasMatch(clean);
  }

  void _showLanguageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'انتخاب زبان',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                _languageItem(
                  languageName: 'دری',
                  locale: const Locale('fa'),
                  icon: '🇦🇫',
                ),

                _languageItem(
                  languageName: 'پښتو',
                  locale: const Locale('ps'),
                  icon: '🇦🇫',
                ),

                _languageItem(
                  languageName: 'English',
                  locale: const Locale('en'),
                  icon: '🇬🇧',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _languageItem({
    required String languageName,
    required Locale locale,
    required String icon,
  }) {
    final bool selected = context.locale.languageCode == locale.languageCode;

    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 24)),
      title: Text(
        languageName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: selected
          ? const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primaryBrand,
            )
          : null,
      onTap: () async {
        await context.setLocale(locale);
        if (mounted) Navigator.pop(context);
      },
    );
  }

  Future<void> signInWithGoogleProcess(
    AuthenticationProvider authProvider,
  ) async {
    if (_isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user == null || !mounted) return;

      final bool userExists = await authProvider.checkUserExistById();

      if (userExists) {
        final bool isBlocked = await authProvider.checkIfUserIsBlocked();

        if (!mounted) return;

        if (isBlocked) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const BlockedScreen(),
            ),
          );
          return;
        }

        await authProvider.getUserDataFromFirebaseDatabase();

        if (!mounted) return;
        _navigateToHome();
      } else {
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const UserInformationScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      commonMethods.displaySnackBar(
        'خطا در ورود با گوگل: ${e.message ?? e.code}',
        context,
      );
    } catch (e) {
      if (!mounted) return;

      commonMethods.displaySnackBar(
        'خطا در ورود با گوگل. لطفاً دوباره تلاش کنید.',
        context,
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _continueAsGuest() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const SafirHomeScreen(),
      ),
      (route) => false,
    );
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const SafirHomeScreen(),
      ),
      (route) => false,
    );
  }

  void sendPhoneNumberViaFirebase() {
    final authRepo =
        Provider.of<AuthenticationProvider>(context, listen: false);

    String rawPhoneNumber = phoneController.text.trim();

    if (rawPhoneNumber.startsWith('0')) {
      rawPhoneNumber = rawPhoneNumber.substring(1);
    }

    if (!_isPhoneValid(rawPhoneNumber)) {
      commonMethods.displaySnackBar(
        'register.invalid_phone_warning'.tr(),
        context,
      );
      return;
    }

    final String fullPhoneNumber = '+93$rawPhoneNumber';

    authRepo.signInWithPhone(
      context: context,
      phoneNumber: fullPhoneNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrand.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_taxi_rounded,
                        color: AppColors.primaryBrand,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      tooltip: 'انتخاب زبان',
                      onPressed: _showLanguageSheet,
                      icon: const Icon(
                        Icons.language_rounded,
                        color: AppColors.primaryBrand,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'register.title'.tr(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'register.subtitle'.tr(),
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Text('🇦🇫', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 6),
                          Text(
                            '+93',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: phoneController,
                        maxLength: 9,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: AppColors.textPrimary,
                        ),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '781234567',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                            letterSpacing: 1,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBrand,
                              width: 1.8,
                            ),
                          ),
                          suffixIcon: _isPhoneValid(phoneController.text)
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                  size: 22,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : sendPhoneNumberViaFirebase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrand,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'register.send_sms_instead'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _continueAsGuest,
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primaryBrand,
                    ),
                    label: const Text(
                      'ادامه بدون ثبت‌نام',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'register.or_continue_with'.tr(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isGoogleLoading
                        ? null
                        : () => signInWithGoogleProcess(authProvider),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isGoogleLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBrand,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.g_mobiledata_rounded,
                                color: Colors.redAccent,
                                size: 30,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'register.google_sign_in'.tr(),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
