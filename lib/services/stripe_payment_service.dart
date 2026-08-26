import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

// ایمپورت ثوابت و متدهای عمومی برند سفیر
import '../globle/global_var.dart';

class StripePaymentService {
  
  // پالت رنگی رسمی برند سفیر
  static const Color safirBrandColor = Color(0xFF145A41);
  static const Color safirButtonTextColor = Color(0xFFFFFFFF);

  // ایجاد فاکتور یا توکن پرداخت (Payment Intent) در سرور استرایپ
  Future<Map<String, dynamic>?> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var secretKey = stripeSecretAPIKey;
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      print('Stripe Payment Intent Info: ${response.body}');
      return jsonDecode(response.body);
    } catch (err) {
      print('Error creating payment intent: ${err.toString()}');
      return null;
    }
  }

  // نمایش پیام‌های سیستم (SnackBar) با تم استاندارد سفیر و پشتیبانی چندزبانه
  void _showSafirSnackBar(BuildContext context, String translationKey, String fallbackText) {
    final String message = getTranslation(translationKey) ?? fallbackText;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'IRANSans', // یا فونت دلخواه سفیر
            color: safirButtonTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: safirBrandColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // نمایش صفحه یا شیت رسمی پرداخت کارت بانکی به مسافر
  Future<void> displayPaymentSheet(
      BuildContext context, String clientSecret) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      
      // پیام موفقیت‌آمیز بودن پرداخت
      _showSafirSnackBar(
        context, 
        'payment_success', 
        'پرداخت شما با موفقیت انجام شد.'
      );
    } on StripeException catch (e) {
      print('Stripe Exception: $e');
      
      // پیام لغو توسط کاربر
      _showSafirSnackBar(
        context, 
        'payment_cancelled', 
        'پرداخت توسط کاربر لغو شد.'
      );
    } catch (e) {
      print("Error presenting payment sheet: $e");
      
      // پیام خطای کلی در پرداخت
      _showSafirSnackBar(
        context, 
        'payment_failed', 
        'عملیات پرداخت با خطا مواجه شد.'
      );
    }
  }

  // مقداردهی اولیه و تنظیمات صفحه پرداخت استرایپ
  Future<void> initPaymentSheet(
      BuildContext context, String clientSecret, String currency) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          googlePay: PaymentSheetGooglePay(
            testEnv: true,
            currencyCode: currency,
            merchantCountryCode: "AF", // کد کشور افغانستان
          ),
          merchantDisplayName: 'Safir Passengers', // نام برند سفیر در درگاه
        ),
      );
    } catch (e) {
      print("Error initializing payment sheet: $e");
    }
  }
}
