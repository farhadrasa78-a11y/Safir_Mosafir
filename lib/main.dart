import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  await EasyLocalization.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  Stripe.publishableKey = stripePublishedKey;
  await Firebase.initializeApp();

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
      Permission.locationWhenInUse.request();
    }
  });

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fa'), Locale('ps'), Locale('en')],
      path: 'assets/lang',
      startLocale: const Locale('fa'),
      fallbackLocale: const Locale('fa'),
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
    const String defaultFont = 'IranYekan';
    const Color primaryColor = Color(0xFF145A41);
    const Color textColor = Color(0xFF2D3142);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppInfo()),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider())
      ],
      child: MaterialApp(
        title: 'Safir Passengers',
        debugShowCheckedModeBanner: false,

        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,

        // 🎨 تنظیمات متمرکز و یکدست‌سازی فونت در کل اپلیکیشن (مشابه اسنپ)
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: defaultFont,
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          scaffoldBackgroundColor: Colors.white,

          // 🔹 ۱. تنظیم یکدست تمامی فیلدهای ورودی (TextFieldها)
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(
              fontFamily: defaultFont,
              fontSize: 12,
              fontWeight: FontWeight.w400, // نازک و استاندارد
              color: Colors.grey,
            ),
            floatingLabelStyle: const TextStyle(
              fontFamily: defaultFont,
              fontSize: 12,
              fontWeight: FontWeight.w400, // نازک
              color: primaryColor,
            ),
            hintStyle: TextStyle(
              fontFamily: defaultFont,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade400,
            ),
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
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),

          // 🔹 ۲. تنظیم وزن و ضخامت یکنواخت برای تمام متون و عناوین
          textTheme: const TextTheme(
            // عناوین اصلی صفحات (مثل «اطلاعات کاربری»)
            titleLarge: TextStyle(
              fontFamily: defaultFont,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            // عناوین بخش‌ها (مانند «اطلاعات اصلی» / «اطلاعات فرعی»)
            titleMedium: TextStyle(
              fontFamily: defaultFont,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            // متن‌های داخل فیلدهای متنی (نام، ایمیل، آدرس)
            bodyLarge: TextStyle(
              fontFamily: defaultFont,
              fontSize: 14,
              fontWeight: FontWeight.w400, // نازک و استاندارد اسنپی
              color: textColor,
            ),
            // متن‌های بدنه و توضیحات عمومی
            bodyMedium: TextStyle(
              fontFamily: defaultFont,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
            // متن‌های کوچک زیرنویس
            bodySmall: TextStyle(
              fontFamily: defaultFont,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
            // متن دکمه‌ها
            labelLarge: TextStyle(
              fontFamily: defaultFont,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
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
      await Future.delayed(const Duration(milliseconds: 1500));

      User? user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (user == null) {
        setState(() {
          _isLoading = false;
          _targetScreen = const RegisterScreen();
        });
      } else {
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
                    Image.asset(
                      'assets/images/logo.png',
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

    if (_isLoading || _targetScreen == null) {
      return Scaffold(
        backgroundColor: safirGreen,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
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

    return _targetScreen!;
  }
}
