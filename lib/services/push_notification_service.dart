import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../global/global_var.dart';
import '../appInfo/app_info.dart';

class PushNotificationService {
  
  /// 🔑 دریافت توکن امنیتی موقت OAuth2 برای FCM v1
  static Future<String?> getAccessToken() async {
    try {
      // ⚠️ هشدار امنیتی: کلیدهای زیر را با اطلاعات واقعی Service Account فایربیس خود پر کنید.
      final serviceAccountJson = {
        "type": "service_account",
        "project_id": "everyone-2de50",
        "private_key_id": "YOUR_PRIVATE_KEY_ID",
        "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n",
        "client_email": "flutteruberclone-fahad@everyone-2de50.iam.gserviceaccount.com",
        "client_id": "105514248289566554622",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/flutteruberclone-fahad%40everyone-2de50.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      };

      final List<String> scopes = [
        "https://www.googleapis.com/auth/firebase.messaging",
      ];

      final accountCredentials = auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
      final client = await auth.clientViaServiceAccount(accountCredentials, scopes);
      
      final String accessToken = client.credentials.accessToken.data;
      client.close(); // بستن کلاینت پس از دریافت موفقیت‌آمیز توکن
      
      return accessToken;
    } catch (e) {
      debugPrint(" Error fetching Google Access Token: $e");
      return null;
    }
  }

  /// 📲 ارسال درخواست سفر زنده به اپلیکیشن راننده سفیر
  static Future<bool> sendNotificationToSelectedDriver(
      String deviceToken, BuildContext context, String tripID) async {
    
    if (deviceToken.isEmpty) {
      debugPrint(" Driver device token is empty.");
      return false;
    }

    debugPrint('Driver Device Token: $deviceToken');

    // استخراج مبدأ و مقصد با ساختار جدید AppInfo
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    String pickUpAddress = appInfo.pickUpLocation?.placeName ?? "origin_unknown".tr();
    String dropOffAddress = appInfo.dropOffLocation?.placeName ?? "destination_unknown".tr();

    final String? serverKeyTokenKey = await getAccessToken();
    if (serverKeyTokenKey == null) {
      debugPrint(" Failed to get access token for FCM.");
      return false;
    }

    const String endpointFirebaseCloudMessaging =
        "https://fcm.googleapis.com/v1/projects/everyone-2de50/messages:send";

    // ساخت عنوان و متن نوتیفیکیشن با سیستم ترجمه
    String currentUserName = userName.isNotEmpty ? userName : "مسافر سفیر";
    String notifTitle = "درخواست سفر جدید از $currentUserName";
    String pickUpLabel = "مبدأ";
    String dropOffLabel = "مقصد";

    // بدنه بهینه‌شده برای نمایش آنی (High Priority) در اندروید و iOS
    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': notifTitle,
          'body': "$pickUpLabel: $pickUpAddress\n$dropOffLabel: $dropOffAddress",
        },
        'data': {
          'tripID': tripID,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'type': 'new_trip_request',
        },
        'android': {
          'priority': 'HIGH',
          'notification': {
            'sound': 'default',
            'channel_id': 'high_importance_channel',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
        'apns': {
          'headers': {
            'apns-priority': '10',
          },
          'payload': {
            'aps': {
              'sound': 'default',
              'badge': 1,
            },
          },
        },
      }
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(endpointFirebaseCloudMessaging),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKeyTokenKey',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        debugPrint(" Push notification sent to Safir driver successfully.");
        return true;
      } else {
        debugPrint(' Failed to send notification. Status Code: ${response.statusCode}');
        debugPrint(' Response Body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint(" Exception in sending push notification: $e");
      return false;
    }
  }
}
