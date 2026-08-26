import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:provider/provider.dart';

// ایمپورت‌های هماهنگ با ساختار پروژه سفیر
import '../global/global_var.dart';
import '../pages/app_info.dart';

class PushNotificationService {
  
  // دریافت توکن امنیتی موقت OAuth2 از گوگل جهت ارسال نوتیفیکیشن FCM v1
  static Future<String> getAccessToken() async {
    try {
      // TODO: برای امنیت کامل پروژه، در آینده این بخش را به Firebase Cloud Functions منتقل کنید.
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
      
      List<String> scopes = [
        "https://www.googleapis.com/auth/userinfo.email",
        "https://www.googleapis.com/auth/firebase.database",
        "https://www.googleapis.com/auth/firebase.messaging"
      ];

      http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );

      auth.AccessCredentials credentials =
          await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client,
      );
      client.close();
      return credentials.accessToken.data;
    } catch (e) {
      debugPrint("Error fetching Google Access Token: $e");
      rethrow;
    }
  }

  // ارسال درخواست سفر زنده به اپلیکیشن رانندگان سفیر
  static Future<void> sendNotificationToSelectedDriver(
      String deviceToken, BuildContext context, String tripID) async {
    
    debugPrint('Driver Device Token: $deviceToken');
    
    // استخراج مبدأ و مقصد
    String dropOffDestinationAddress =
        Provider.of<AppInfoClass>(context, listen: false)
            .dropOffLocation
            ?.placeName ?? "";
            
    String pickUpAddress = Provider.of<AppInfoClass>(context, listen: false)
        .pickUpLocation
        ?.placeName ?? "";
        
    final String serverKeyTokenKey = await getAccessToken();
    const String endpointFirebaseCloudMessaging =
        "https://fcm.googleapis.com/v1/projects/everyone-2de50/messages:send";
        
    // استفاده از سیستم ترجمه پویا برای نوتیفیکیشن‌ها
    String notifTitle = getTranslation(context, "notification_new_trip_title")
        .replaceAll("{user}", userName);
    String pickUpLabel = getTranslation(context, "pickup_location");
    String dropOffLabel = getTranslation(context, "destination_location");

    // بدنه نوتیفیکیشن سفیر
    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': notifTitle,
          'body': "$pickUpLabel: $pickUpAddress\n$dropOffLabel: $dropOffDestinationAddress"
        },
        'data': {
          'tripID': tripID,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        }
      }
    };
    
    try {
      final http.Response response = await http.post(
        Uri.parse(endpointFirebaseCloudMessaging),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKeyTokenKey'
        },
        body: jsonEncode(message),
      );
      
      if (response.statusCode == 200) {
        debugPrint("Notification successfully sent to Safir driver.");
      } else {
        debugPrint('Failed to send notification. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error sending push notification: $e");
    }
  }
}
