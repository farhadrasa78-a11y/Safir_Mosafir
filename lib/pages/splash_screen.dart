import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';

class SafirSplashScreen extends StatefulWidget {
  const SafirSplashScreen({Key? key}) : super(key: key);

  @override
  State<SafirSplashScreen> createState() => _SafirSplashScreenState();
}

class _SafirSplashScreenState extends State<SafirSplashScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // 🟢 رنگ اختصاصی برند سفیر
  static const Color safirGreen = Color(0xFF145A41);

  @override
  void initState() {
    super.initState();

    // تنظیمات انیمیشن ورودی لوگو
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 🌐 بررسی واقعی اتصال به اینترنت
  Future<bool> _checkRealInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  void _showErrorState() {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _initializeApp() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    try {
      // ۱. بررسی شبکه
      var connectivityResult = await (Connectivity().checkConnectivity());
      bool isNetworkActive = !connectivityResult.contains(ConnectivityResult.none);

      if (!isNetworkActive) {
        _showErrorState();
        return;
      }

      // ۲. بررسی اینترنت واقعی
      bool hasRealInternet = await _checkRealInternetConnection();
      if (!hasRealInternet) {
        _showErrorState();
        return;
      }

      // ۳. بررسی وضعیت لاگین
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (currentUser != null) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      debugPrint("Splash Error: $e");
      _showErrorState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: safirGreen,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 📍 لوگوی سفیر
                      Image.asset(
                        'assets/images/safir_logo.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint("خطا در بارگذاری تصویر لوگو: $error");
                          return _buildSafirVectorIcon();
                        },
                      ),

                      const SizedBox(height: 32),

                      if (_hasError)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Text(
                            'splash_error_msg'.tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),

                      if (_isLoading)
                        const SizedBox(
                          height: 28,
                          width: 28,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            if (_hasError)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _initializeApp();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'retry_btn'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: safirGreen,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🎯 لوگوی برداری جایگزین در صورت عدم وجود تصویر
  Widget _buildSafirVectorIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'S',
          style: TextStyle(
            fontSize: 90,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 0.9,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
