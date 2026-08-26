import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'package:safir_passengers/theme/app_colors.dart';
import 'package:safir_passengers/widgets/map_location_label.dart';
import 'package:safir_passengers/widgets/smart_location_sheet.dart';

enum SelectionState { pickingOrigin, pickingDestination, confirmed }

class SafirMapPicker extends StatefulWidget {
  const SafirMapPicker({super.key});

  @override
  State<SafirMapPicker> createState() => _SafirMapPickerState();
}

class _SafirMapPickerState extends State<SafirMapPicker> with TickerProviderStateMixin {
  MapLibreMapController? _mapController;
  
  LatLng _mapCenter = const LatLng(34.5553, 69.2075); // کابل
  LatLng? _lastSnappedPoint;

  LatLng? _confirmedOriginLatLng;
  LatLng? _confirmedDestinationLatLng;

  SelectionState _currentState = SelectionState.pickingOrigin; 
  bool _isMapMoving = false; 
  bool _isSheetExpanded = false;

  String _originAddress = '';
  String _destinationAddress = '';

  static const Color destinationColor = Color(0xFF169365);

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  // 🛣️ متد هوشمند اسنپ: پیدا کردن خیابان و هدایت نرم نقشه روی آن
  Future<void> _snapToNearestRoadAndGetAddress(LatLng point) async {
    try {
      final osrmUrl = Uri.parse(
        'https://router.project-osrm.org/nearest/v1/driving/${point.longitude},${point.latitude}?number=1',
      );

      final response = await http.get(osrmUrl).timeout(
        const Duration(seconds: 4),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['waypoints'] != null && (data['waypoints'] as List).isNotEmpty) {
          final way = data['waypoints'][0];
          final double snappedLat = way['location'][1];
          final double snappedLng = way['location'][0];
          final String streetName = way['name'] ?? '';

          final LatLng snappedPoint = LatLng(snappedLat, snappedLng);
          _lastSnappedPoint = snappedPoint;

          // 🎬 انیمیشن سر خوردن نرم نقشه به سمت خیابان
          _animateMapToRoad(snappedPoint);

          if (mounted) {
            setState(() {
              final String finalAddress = streetName.trim().isNotEmpty 
                  ? streetName 
                  : 'main_street'.tr().isEmpty ? 'خیابان اصلی' : 'main_street'.tr();

              if (_currentState == SelectionState.pickingOrigin) {
                _originAddress = finalAddress;
              } else if (_currentState == SelectionState.pickingDestination) {
                _destinationAddress = finalAddress;
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching road data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isMapMoving = false;
        });
      }
    }
  }

  // 🎬 متد ایجاد انیمیشن حرکت نرم به خیابان با استفاده از MapLibre CameraUpdate
  void _animateMapToRoad(LatLng targetLatLng) {
    if (_mapController == null) return;
    double currentZoom = _mapController!.cameraPosition?.zoom ?? 16.0;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(targetLatLng, currentZoom),
    );
  }

  void _handleConfirmation() {
    final LatLng finalRoadPoint = _lastSnappedPoint ?? 
        (_mapController?.cameraPosition?.target ?? _mapCenter);

    if (_currentState == SelectionState.pickingOrigin) {
      setState(() {
        _confirmedOriginLatLng = finalRoadPoint;
        _currentState = SelectionState.pickingDestination;
      });
    } else if (_currentState == SelectionState.pickingDestination) {
      setState(() {
        _confirmedDestinationLatLng = finalRoadPoint;
        _currentState = SelectionState.confirmed;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: destinationColor,
          content: Text('trip_confirmed_searching_driver'.tr().isEmpty 
              ? 'درخواست ثبت شد، در حال جستجوی راننده...' 
              : 'trip_confirmed_searching_driver'.tr()),
        ),
      );
    }
  }

  void _revertToOriginSelection() {
    if (_currentState == SelectionState.pickingDestination) {
      setState(() {
        _currentState = SelectionState.pickingOrigin;
        _confirmedOriginLatLng = null;
      });
      if (_confirmedOriginLatLng != null) {
        _animateMapToRoad(_confirmedOriginLatLng!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentStep = _currentState == SelectionState.pickingOrigin ? 0 : 1;
    bool isOrigin = _currentState == SelectionState.pickingOrigin;
    Color activePinColor = isOrigin ? AppColors.originBlue : destinationColor;

    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            styleString: "https://demotiles.maplibre.org/style.json",
            initialCameraPosition: CameraPosition(
              target: _mapCenter,
              zoom: 16.0,
            ),
            onMapCreated: _onMapCreated,
            onCameraMoveStarted: () {
              if (!_isMapMoving) {
                setState(() {
                  _isMapMoving = true;
                });
              }
            },
            onCameraIdle: () {
              if (_mapController != null && _mapController!.cameraPosition != null) {
                _mapCenter = _mapController!.cameraPosition!.target;
                _snapToNearestRoadAndGetAddress(_mapCenter);
              }
            },
            trackCameraPosition: true,
            myLocationEnabled: false,
          ),

          // 📍 پین متحرک وسط صفحه
          if (_currentState != SelectionState.confirmed)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  transform: Matrix4.translationValues(0, _isMapMoving ? -12 : 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: activePinColor,
                          shape: isOrigin ? BoxShape.circle : BoxShape.rectangle,
                          borderRadius: isOrigin ? null : BorderRadius.circular(7),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 3,
                        height: 16,
                        color: Colors.grey.shade800,
                      ),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: _isMapMoving ? 6 : 12,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(_isMapMoving ? 0.15 : 0.35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 📋 شیت پایین صفحه
          SmartLocationSheet(
            currentStep: currentStep,
            currentAddress: _originAddress,
            currentDestination: _destinationAddress,
            isMapIdle: !_isMapMoving,
            isExpanded: _isSheetExpanded,
            onExpandChanged: (expanded) {
              setState(() {
                _isSheetExpanded = expanded;
              });
            },
            onConfirmStep: _handleConfirmation,
            onSearchOriginTap: (address) {},
            onSearchDestinationTap: () {},
            onGpsTap: () {
              // هدایت به موقعیت فعلی پیش‌فرض
              _animateMapToRoad(_mapCenter);
            },
          ),
        ],
      ),
    );
  }
}
