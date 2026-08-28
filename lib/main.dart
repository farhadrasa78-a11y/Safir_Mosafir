import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 افزوده شده جهت مدیریت status bar
import 'package:flutter_stripe/flutter_stripe.dart' hide AppInfo;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

// ایمپورت‌های پروژه سفیر مسافر
import 'global/global_var.dart';
import 'authentication/register_screen.dart';
import 'pages/blocked_screen.dart';
import 'pages/safir_home_screen.dart'; 

// پرووایدرها
import 'appInfo/app_info.dart';
import 'appInfo/auth_provider.dart';

late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized(); // مقداردهی اولیه زبان

  // 🔹 ۱. فعال‌سازی حالت edgeToEdge جهت پوشش کامل نقشه در تمام صفحه
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  // 🔹 ۲. شفاف کردن کامل status bar و navigation bar مشابه اسنپ
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  Stripe.publishableKey = stripePublishedKey;
  await Firebase.initializeApp();

  // درخواست دسترسی به موقعیت مکانی برای نقشه سفیر
  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
      Permission.locationWhenInUse.request();
    }
  });

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fa'), Locale('ps'), Locale('en')],
      path: 'assets/lang', // مسیر فایل‌های ترجمه
      startLocale: const Locale('fa'), // 🇦ف اجبار شروع برنامه با زبان فارسی
      fallbackLocale: const Locale('fa'), // زبان رزرو
      saveLocale: true,
      useOnlyLangCode: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppInfo()),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider())
      ],
      child: MaterialApp(
        title: 'Safir Passengers',
        debugShowCheckedModeBanner: false,

        // اعمال خودکار زبان و راست‌چین/چپ‌چین شدن برنامه
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF145A41)),
          useMaterial3: true,
          fontFamily: 'IranYekan',
        ),
        home: const AuthCheck(),
      ),
    );
  }
}

/// 🛡️ چک‌کننده هوشمند و سریع وضعیت کاربر با اسپلش‌سکرین سفیر
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isLoading = true;
  bool _hasError = false;
  Widget? _targetScreen;

  static const Color safirGreen = Color(0xFF145A41);

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigation();
  }

  Future<void> _checkAuthAndNavigation() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // تاخیر ۱.۵ ثانیه‌ای جهت نمایش لوگوی برند سفیر
      await Future.delayed(const Duration(milliseconds: 1500));

      // 🟢 بررسی وضعیت لاگین کاربر در فایربیس
      User? user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (user == null) {
        // کاربر لاگین نیست -> هدایت به صفحه ثبت‌نام
        setState(() {
          _isLoading = false;
          _targetScreen = const RegisterScreen();
        });
      } else {
        // کاربر لاگین است -> ورود به صفحه اصلی
        setState(() {
          _isLoading = false;
          _targetScreen = const SafirHomeScreen();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ❌ حالت خطا
    if (_hasError) {
      return Scaffold(
        backgroundColor: safirGreen,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // نمایش لوگوی سفیر در حالت خطا
                    Image.asset(
                      'assets/images/logo.png', // 👈 مسیر لوگوی شما
                      width: 110,
                      height: 110,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.local_taxi_rounded, size: 80, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        'مشکلی در برقراری ارتباط پیش آمده است.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _checkAuthAndNavigation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'تلاش دوباره',
                        style: TextStyle(
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

    // ⏳ حالت بارگذاری اولیه (اسپلش سکرین مدرن با لوگوی سفیر)
    if (_isLoading || _targetScreen == null) {
      return Scaffold(
        backgroundColor: safirGreen,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🖼️ تصویر اصلی لوگوی سفیر
              Image.asset(
                'assets/images/logo.png', // 👈 مسیر لوگوی سفیر را چک کنید
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // در صورت عدم یافتن فایل عکس، آیکون تاکسی سفیر جایگزین می‌شود
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_taxi_rounded,
                      size: 60,
                      color: safirGreen,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      );
    }

    // ✅ هدایت به صفحه مقصد
    return _targetScreen!;
  }
}
