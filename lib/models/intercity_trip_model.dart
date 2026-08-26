import 'package:cloud_firestore/cloud_firestore.dart';

class IntercityTripModel {
  final String? id;
  final String userId;
  final String userPhone;
  final String originAddress;
  final double originLat;
  final double originLng;
  final String destinationAddress;
  final double destinationLat;
  final double destinationLng;
  final int passengerCount;
  final String travelTiming;
  final double estimatedFare;
  final String status;
  final DateTime? createdAt;

  IntercityTripModel({
    this.id,
    required this.userId,
    required this.userPhone,
    required this.originAddress,
    required this.originLat,
    required this.originLng,
    required this.destinationAddress,
    required this.destinationLat,
    required this.destinationLng,
    required this.passengerCount,
    required this.travelTiming,
    required this.estimatedFare,
    required this.status,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userPhone': userPhone,
      'originAddress': originAddress,
      'originLat': originLat,
      'originLng': originLng,
      'destinationAddress': destinationAddress,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'passengerCount': passengerCount,
      'travelTiming': travelTiming,
      'estimatedFare': estimatedFare,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory IntercityTripModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return IntercityTripModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userPhone: data['userPhone'] ?? '',
      originAddress: data['originAddress'] ?? '',
      originLat: (data['originLat'] ?? 0).toDouble(),
      originLng: (data['originLng'] ?? 0).toDouble(),
      destinationAddress: data['destinationAddress'] ?? '',
      destinationLat: (data['destinationLat'] ?? 0).toDouble(),
      destinationLng: (data['destinationLng'] ?? 0).toDouble(),
      passengerCount: data['passengerCount'] ?? 1,
      travelTiming: data['travelTiming'] ?? '',
      estimatedFare: (data['estimatedFare'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
