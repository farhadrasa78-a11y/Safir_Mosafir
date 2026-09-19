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
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
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
    const Color primaryColor = Color(0xFF117656);
    const Color textColor = Color(0xFF2D3142);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppInfo()),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ],
      child: MaterialApp(
        title: 'Safir Passengers',
        debugShowCheckedModeBanner: false,

        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,

        theme: ThemeData(
          useMaterial3: true,
          fontFamily: defaultFont,
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          scaffoldBackgroundColor: Colors.white,

          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: defaultFont,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(
              fontFamily: defaultFont,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
            floatingLabelStyle: const TextStyle(
              fontFamily: defaultFont,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
            hintStyle: TextStyle(
              fontFamily: defaultFont,
              fontSize: 13,
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

          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontFamily: defaultFont,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
            titleMedium: TextStyle(
              fontFamily: defaultFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
            bodyLarge: TextStyle(
              fontFamily: defaultFont,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
            bodyMedium: TextStyle(
              fontFamily: defaultFont,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
            bodySmall: TextStyle(
              fontFamily: defaultFont,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
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

class _AuthCheckState extends State<AuthCheck>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  Widget? _targetScreen;

  // رنگ دقیق برند لوگوی سفیر
  static const Color safirGreen = Color(0xFF127C59);

  late AnimationController _loadingController;
  late Animation<double> _dot1;
  late Animation<double> _dot2;
  late Animation<double> _dot3;
  late Animation<double> _dot4;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dot1 = _createDotAnimation(0.00);
    _dot2 = _createDotAnimation(0.18);
    _dot3 = _createDotAnimation(0.36);
    _dot4 = _createDotAnimation(0.54);

    _checkAuthAndNavigation();
  }

  /// انیمیشن نقطه‌ها از حالت بزرگ (1.0) به کوچک (0.0) و برگشت به حالت اولیه
  Animation<double> _createDotAnimation(double begin) {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Interval(
          begin,
          (begin + 0.45).clamp(0.0, 1.0),
          curve: Curves.linear,
        ),
      ),
    );
  }

  Future<void> _checkAuthAndNavigation() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      // افزایش زمان نمایش Splash به ۳ ثانیه
      await Future.delayed(const Duration(milliseconds: 3000));

      final User? user = FirebaseAuth.instance.currentUser;

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
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Widget _buildSafirLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Image.asset(
        'assets/images/safir_logo.png',
        width: 220,
        height: 90,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Text(
            'Safir',
            style: TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w800,
              letterSpacing: -2,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDot(double animationValue) {
    // تغییر سایز دینامیک بر اساس مقدار انیمیشن (از ۷ تا ۱۴)
    final double size = 7 + (animationValue * 7);

    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (animationValue * 0.4),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                0.35 + (animationValue * 0.65),
              ),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotLoading() {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _dot1,
            builder: (_, __) => _buildDot(_dot1.value),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _dot2,
            builder: (_, __) => _buildDot(_dot2.value),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _dot3,
            builder: (_, __) => _buildDot(_dot3.value),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _dot4,
            builder: (_, __) => _buildDot(_dot4.value),
          ),
        ],
      ),
    );
  }

  Widget _buildSplashContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSafirLogo(),
          const SizedBox(height: 18),
          _buildDotLoading(),
        ],
      ),
    );
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
                    _buildSafirLogo(),
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
        body: _buildSplashContent(),
      );
    }

    return _targetScreen!;
  }
}
