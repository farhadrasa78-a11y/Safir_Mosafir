import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // متد ایجاد درخواست سفر جدید در Firestore
  Future<String?> createRideRequest({
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String destinationAddress,
    required double destinationLat,
    required double destinationLng,
    required double fareAmount,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        debugPrint("کاربر وارد نشده است!");
        return null;
      }

      // ایجاد سند جدید با کلید اختصاصی در مجموعه rides
      DocumentReference rideRef = _firestore.collection('rides').doc();

      Map<String, dynamic> rideData = {
        'rideId': rideRef.id,
        'passengerId': user.uid,
        'passengerPhone': user.phoneNumber ?? '',
        'driverId': null, // در انتظار قبول راننده
        'status': 'requested', // وضعیت اولیه سفر
        'pickup': {
          'address': pickupAddress,
          'lat': pickupLat,
          'lng': pickupLng,
        },
        'destination': {
          'address': destinationAddress,
          'lat': destinationLat,
          'lng': destinationLng,
        },
        'fareAmount': fareAmount,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await rideRef.set(rideData);
      return rideRef.id; // بازگرداندن آیدی سفر برای پیگیری بعدی
    } catch (e) {
      debugPrint("خطا در ثبت درخواست سفر: $e");
      return null;
    }
  }
}
