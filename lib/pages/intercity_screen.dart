import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_colors.dart'; 
import '../widgets/animated_menus.dart';
import '../widgets/intercity_sheets.dart';
import 'map_screen.dart';

class IntercityScreen extends StatefulWidget {
  const IntercityScreen({super.key});

  @override
  State<IntercityScreen> createState() => _IntercityScreenState();
}

class _IntercityScreenState extends State<IntercityScreen> {
  // مراحل سفارش:
  // 0: انتخاب مبدأ و مقصد
  // 1: مشخصات سفر (زمان، تعداد مسافر، تخفیف، هزینه و ثبت)
  int _currentStep = 0;
  bool _isLoading = false;

  String _originAddress = '';
  String _destinationAddress = '';
  String _travelTiming = '';

  LatLng? _originLatLng;
  LatLng? _destinationLatLng;

  int _passengerCount = 1;
  double _estimatedFare = 3200.0;

  final Color originBlueColor = const Color(0xFF2563EB);

  // لیست شهرهای محبوب افغانستان
  final List<Map<String, dynamic>> _allPopularCities = [
    {'name': 'هرات', 'province': 'هرات', 'lat': 34.3529, 'lng': 62.2040},
    {'name': 'مزار شریف', 'province': 'بلخ', 'lat': 36.7069, 'lng': 67.1108},
    {'name': 'جلال آباد', 'province': 'ننگرهار', 'lat': 34.4261, 'lng': 70.4515},
    {'name': 'کندهار', 'province': 'کندهار', 'lat': 31.6288, 'lng': 65.7372},
    {'name': 'غزنی', 'province': 'غزنی', 'lat': 33.5450, 'lng': 68.4174},
    {'name': 'بامیان', 'province': 'بامیان', 'lat': 34.8100, 'lng': 67.8200},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_originAddress.isEmpty) {
      _originAddress = "intercity.fetching_origin".tr();
      _destinationAddress = "intercity.fetching_destination".tr();
      _travelTiming = "intercity.now".tr();
    }
  }

  // 📍 ۱. باز کردن نقشه برای انتخاب مبدأ
  Future<void> _pickOriginOnMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SafirMapScreen(
          serviceType: 'intercity',
          isPickerOnly: true,
          pickerMode: 'origin_only',
        ),
      ),
    );

    if (result != null && result is Map && result['origin'] != null) {
      setState(() {
        _originAddress = result['origin'].placeName ?? _originAddress;
        _originLatLng = LatLng(result['origin'].latitudePosition, result['origin'].longitudePosition);
      });

      _openDestinationCitySheet();
    }
  }

  // 📍 ۲. باز کردن نقشه برای انتخاب مقصد
  Future<void> _pickDestinationOnMap({LatLng? initialTarget, String? cityName}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SafirMapScreen(
          serviceType: 'intercity',
          isPickerOnly: true,
          pickerMode: 'destination_only',
          targetLocation: initialTarget,
        ),
      ),
    );

    if (result != null && result is Map && result['destination'] != null) {
      setState(() {
        _destinationAddress = result['destination'].placeName ?? (cityName ?? _destinationAddress);
        _destinationLatLng = LatLng(result['destination'].latitudePosition, result['destination'].longitudePosition);
        _currentStep = 1;
        _calculateIntercityFare();
      });
    }
  }

  // 🏙️ فراخوانی شیت انتخاب شهر مقصد از IntercitySheets
  void _openDestinationCitySheet() {
    IntercitySheets.showSelectDestinationCitySheet(
      context: context,
      popularCities: _allPopularCities,
      onSelectOnMap: () => _pickDestinationOnMap(),
      onSelectCity: (city) {
        LatLng cityLatLng = LatLng(city['lat'], city['lng']);
        _pickDestinationOnMap(initialTarget: cityLatLng, cityName: city['name']);
      },
    );
  }

  // محاسبه کرایه بین‌شهری
  void _calculateIntercityFare() {
    setState(() {
      _estimatedFare = 3200.0;
    });
  }

  // ⏱️ فراخوانی شیت زمان سفر از IntercitySheets
  void _openTimingSheet() {
    IntercitySheets.showTimingSheet(
      context: context,
      currentTiming: _travelTiming,
      onTimingSelected: (timing) {
        setState(() => _travelTiming = timing);
      },
    );
  }

  // 👥 فراخوانی شیت تعداد مسافران از IntercitySheets
  void _openPassengersSheet() {
    IntercitySheets.showPassengersSheet(
      context: context,
      initialCount: _passengerCount,
      onPassengerCountChanged: (count) {
        setState(() => _passengerCount = count);
      },
    );
  }

  // 🔥 متد اصلی ثبت درخواست سفر بین‌شهری در فایربیس (Firestore)
  Future<void> _submitIntercityOrderToFirebase() async {
    setState(() => _isLoading = true);

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('intercity_orders').add({
        'userId': user?.uid ?? 'anonymous',
        'status': 'pending', // حالت اولیه: منتظر پذیرش راننده
        'createdAt': FieldValue.serverTimestamp(),
        'originAddress': _originAddress,
        'destinationAddress': _destinationAddress,
        'originLatLng': _originLatLng != null
            ? {'lat': _originLatLng!.latitude, 'lng': _originLatLng!.longitude}
            : null,
        'destinationLatLng': _destinationLatLng != null
            ? {'lat': _destinationLatLng!.latitude, 'lng': _destinationLatLng!.longitude}
            : null,
        'travelTiming': _travelTiming,
        'passengerCount': _passengerCount,
        'estimatedFare': _estimatedFare,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('intercity.trip_registered_success'.tr()),
          backgroundColor: AppColors.primaryBrand,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در ثبت درخواست: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'intercity.title'.tr(),
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBrand),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.textPrimary),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (_) => const ProfileAnimatedMenu(),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBrand))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // کارت آدرس‌های مبدأ و مقصد
                  _buildAddressCard(),
                  const SizedBox(height: 16),

                  if (_currentStep == 0)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _pickOriginOnMap,
                        icon: const Icon(Icons.map, color: Colors.white),
                        label: Text(
                          'intercity.select_on_map'.tr(),
                          style: const TextStyle(color: AppColors.buttonText, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  if (_currentStep == 1)
                    // کارت جزئیات سفر بین‌شهری از IntercitySheets
                    IntercitySheets.buildTripSummarySheet(
                      context: context,
                      travelTiming: _travelTiming,
                      passengerCount: _passengerCount,
                      estimatedFare: _estimatedFare,
                      onTapTiming: _openTimingSheet,
                      onTapPassengers: _openPassengersSheet,
                      onRequestTrip: _submitIntercityOrderToFirebase,
                    ),
                ],
              ),
            ),
    );
  }

  // کارت آدرس‌ها
  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.circle, color: originBlueColor, size: 16),
            title: Text('intercity.origin'.tr(), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            subtitle: Text(_originAddress, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            trailing: const Icon(Icons.edit, size: 18, color: AppColors.primaryBrand),
            onTap: _pickOriginOnMap,
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on, color: AppColors.primaryButton, size: 22),
            title: Text('intercity.destination'.tr(), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            subtitle: Text(_destinationAddress, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            trailing: const Icon(Icons.edit, size: 18, color: AppColors.primaryBrand),
            onTap: _openDestinationCitySheet,
          ),
        ],
      ),
    );
  }
}
