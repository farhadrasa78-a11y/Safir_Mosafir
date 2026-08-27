import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'package:safir_passengers/appInfo/app_info.dart';
import 'package:safir_passengers/models/address_models.dart';
import 'package:safir_passengers/global/global_var.dart'; 
import 'package:safir_passengers/global/trip_var.dart';
import 'package:safir_passengers/theme/app_colors.dart';
import 'package:safir_passengers/widgets/payment_dialog.dart';
import 'package:safir_passengers/widgets/rate_driver_sheet.dart';
import 'search_destination_place.dart';

import 'map_files/map_controller_logic.dart';
import 'map_files/map_bottom_sheets.dart';
import 'map_files/smart_location_sheet.dart'; 
import 'map_files/intercity_sheets.dart';
import 'map_files/cargo_sheets.dart';
import 'map_files/trip_options_sheet.dart';
import 'map_files/schedule_trip_sheet.dart';
import 'map_files/promo_code_sheet.dart';
import '../widgets/animated_menus.dart'; 

class SafirMapScreen extends StatefulWidget {
  final String serviceType;
  final String? pickerMode;
  final LatLng? targetLocation;
  final bool isPickerOnly;

  const SafirMapScreen({
    super.key,
    required this.serviceType,
    this.pickerMode,
    this.targetLocation,
    this.isPickerOnly = false,
  });

  @override
  State<SafirMapScreen> createState() => _SafirMapScreenState();
}

class _SafirMapScreenState extends State<SafirMapScreen> {
  MapLibreMapController? _mapController;
  
  LatLng _currentUserLatLng = const LatLng(34.5333, 69.1667);
  LatLng? _originLatLng;
  LatLng? _destinationLatLng;

  Symbol? _originSymbol;
  Symbol? _destinationSymbol;

  bool _isMapMoving = false;
  bool _isSheetExpanded = true; 
  Timer? _debounceTimer;

  bool _hasNotification = false; 
  String _rideForWhomKey = "for_myself"; 

  int _selectedCategory = 0; 
  int _selectedVehicleType = 0; 
  int _currentStep = 0; 

  String? _intercityTravelDate;
  int _intercityPassengers = 1;

  String? _secondDestinationAddress;
  int _stopDurationMinutes = 0;
  bool _isRoundTrip = false;
  bool _hasExtraLuggage = false;
  bool _preferSilence = false;

  DateTime? _scheduledDateTime;
  String? _appliedPromoCode;

  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();
  final TextEditingController _senderAddressController = TextEditingController();
  final TextEditingController _senderUnitController = TextEditingController();
  final TextEditingController _senderFloorController = TextEditingController();
  final TextEditingController _senderNoteController = TextEditingController();

  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _receiverAddressController = TextEditingController();
  final TextEditingController _receiverUnitController = TextEditingController();
  final TextEditingController _receiverFloorController = TextEditingController();
  final TextEditingController _receiverNoteController = TextEditingController();

  String _cargoPackageType = 'cargo.type_other'.tr();
  String _cargoInsurance = 'cargo.no_insurance'.tr();
  String _cargoSelectedVehicle = 'zaranj';
  String _cargoPaymentPayer = 'cargo.sender'.tr();

  String _tripDurationText = "";
  String _estimatedArrivalTime = "--:--";
  List<LatLng> _routePolylinePoints = [];

  DocumentReference? tripRequestRef;
  StreamSubscription<DocumentSnapshot>? tripStreamSubscription;

  double actualFareAmount = 50.0;
  double? bidAmount;
  String selectedVehicle = "Car";

  final List<Map<String, dynamic>> _intercityCities = [
    {'name': 'هرات', 'province': 'هرات', 'lat': 34.3529, 'lng': 62.2040},
    {'name': 'مزار شریف', 'province': 'بلخ', 'lat': 36.7069, 'lng': 67.1108},
    {'name': 'جلال آباد', 'province': 'ننگرهار', 'lat': 34.4261, 'lng': 70.4515},
    {'name': 'کندهار', 'province': 'کندهار', 'lat': 31.6288, 'lng': 65.7372},
  ];

  @override
  void initState() {
    super.initState();
    selectedVehicle = widget.serviceType;
    _getUserInitialLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    tripStreamSubscription?.cancel();
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _senderAddressController.dispose();
    _senderUnitController.dispose();
    _senderFloorController.dispose();
    _senderNoteController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _receiverAddressController.dispose();
    _receiverUnitController.dispose();
    _receiverFloorController.dispose();
    _receiverNoteController.dispose();
    super.dispose();
  }

  // 🔹 دریافت موقعیت اولیه بدون دستکاری کشو
  Future<void> _getUserInitialLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      if (mounted) {
        setState(() {
          _currentUserLatLng = LatLng(position.latitude, position.longitude);
        });

        _moveCameraWithoutClosingSheet(_currentUserLatLng, 15.0);
        _updateAddressFromCamera(_currentUserLatLng);
      }
    } catch (e) {
      debugPrint("Error location: $e");
    }
  }

  void _moveCameraWithoutClosingSheet(LatLng target, double zoom) {
    if (_mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(target, zoom),
    );
  }

  // 🔹 ایجاد مارکر استاندارد نقشه MapLibre
  Future<void> _addOrUpdateMarker({required bool isOrigin, required LatLng position}) async {
    if (_mapController == null) return;

    if (isOrigin) {
      if (_originSymbol != null) {
        await _mapController!.removeSymbol(_originSymbol!);
      }
      _originSymbol = await _mapController!.addSymbol(
        SymbolOptions(
          geometry: position,
          iconImage: "marker-15", // آیکون پیش‌فرض MapLibre
          iconSize: 1.8,
          iconOffset: const Offset(0, -10),
        ),
      );
    } else {
      if (_destinationSymbol != null) {
        await _mapController!.removeSymbol(_destinationSymbol!);
      }
      _destinationSymbol = await _mapController!.addSymbol(
        SymbolOptions(
          geometry: position,
          iconImage: "marker-15",
          iconSize: 1.8,
          iconOffset: const Offset(0, -10),
        ),
      );
    }
  }

  void _updateAddressFromCamera(LatLng center) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${center.latitude}&lon=${center.longitude}&accept-language=fa,ps,en',
        );
        final response = await http.get(url, headers: {'User-Agent': 'safir_passengers'});

        if (response.statusCode == 200 && mounted) {
          final data = json.decode(response.body);
          final addressObj = data['address'];

          String formattedAddress = 'selected_location'.tr();

          if (addressObj != null) {
            String city = addressObj['city'] ?? addressObj['town'] ?? addressObj['county'] ?? addressObj['state'] ?? '';
            String suburb = addressObj['suburb'] ?? addressObj['neighbourhood'] ?? addressObj['quarter'] ?? addressObj['residential'] ?? '';
            String road = addressObj['road'] ?? addressObj['pedestrian'] ?? addressObj['path'] ?? '';

            List<String> addressParts = [];
            if (city.isNotEmpty) addressParts.add(city);
            if (suburb.isNotEmpty && suburb != city) addressParts.add(suburb);
            if (road.isNotEmpty && road != suburb) addressParts.add(road);

            if (addressParts.isNotEmpty) {
              formattedAddress = addressParts.join('، ');
            } else {
              formattedAddress = data['display_name'] ?? formattedAddress;
            }
          }

          AddressModel userLocation = AddressModel(
            placeName: formattedAddress,
            humanReadableAddress: formattedAddress,
            latitudePosition: center.latitude,
            longitudePosition: center.longitude,
          );

          var appInfo = Provider.of<AppInfo>(context, listen: false);
          if (_currentStep == 0) {
            appInfo.updatePickUpLocation(userLocation);
          } else if (_currentStep == 1) {
            appInfo.updateDropOffLocation(userLocation);
          }
        }
      } catch (e) {
        debugPrint("Error geocoding: $e");
      }
    });
  }

  Future<void> _confirmOrigin() async {
    HapticFeedback.mediumImpact();
    if (_mapController == null) return;

    final camera = await _mapController!.queryCameraPosition();
    if (camera == null) return;

    final currentCenter = camera.target;
    setState(() => _originLatLng = currentCenter);

    await _addOrUpdateMarker(isOrigin: true, position: currentCenter);

    setState(() {
      _currentStep = 1;
      _isSheetExpanded = true;
    });
  }

  Future<void> _confirmDestination() async {
    HapticFeedback.mediumImpact();
    if (_mapController == null) return;

    final camera = await _mapController!.queryCameraPosition();
    if (camera == null) return;

    final currentCenter = camera.target;
    setState(() => _destinationLatLng = currentCenter);

    await _addOrUpdateMarker(isOrigin: false, position: currentCenter);

    setState(() => _currentStep = 2);
    _fetchRoute();
  }

  void _fetchRoute() {
    var appInfo = Provider.of<AppInfo>(context, listen: false);
    if (appInfo.pickUpLocation == null || _mapController == null) return;

    _mapController!.clearLines();

    LatLng originLatLng = _originLatLng ?? 
        LatLng(appInfo.pickUpLocation!.latitudePosition!, appInfo.pickUpLocation!.longitudePosition!);
    LatLng destLatLng = _destinationLatLng ?? _mapController!.cameraPosition!.target;

    MapControllerLogic.getOSRMRoute(
      context: context,
      selectedVehicle: selectedVehicle,
      customOrigin: originLatLng,
      customDestination: destLatLng,
      onRouteFetched: (points, fare, durationText, arrivalTime) async {
        if (mounted) {
          setState(() {
            _routePolylinePoints = points;
            actualFareAmount = fare;
            _tripDurationText = durationText;
            _estimatedArrivalTime = arrivalTime;
          });

          if (_routePolylinePoints.isNotEmpty) {
            await _mapController!.addLine(
              LineOptions(
                geometry: _routePolylinePoints,
                lineColor: "#0066FF",
                lineWidth: 5.0,
              ),
            );

            double minLat = _routePolylinePoints.map((p) => p.latitude).reduce(min);
            double maxLat = _routePolylinePoints.map((p) => p.latitude).reduce(max);
            double minLng = _routePolylinePoints.map((p) => p.longitude).reduce(min);
            double maxLng = _routePolylinePoints.map((p) => p.longitude).reduce(max);

            _mapController!.animateCamera(
              CameraUpdate.newLatLngBounds(
                LatLngBounds(
                  southwest: LatLng(minLat, minLng),
                  northeast: LatLng(maxLat, maxLng),
                ),
                left: 50, top: 100, right: 50, bottom: 100,
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AppInfo? appInfo;
    try {
      appInfo = Provider.of<AppInfo>(context, listen: true);
    } catch (_) {}

    String currentOrigin = appInfo?.pickUpLocation?.placeName ?? 'current_location_origin'.tr();
    String currentDestination = appInfo?.dropOffLocation?.placeName ?? 'select_destination_hint'.tr();

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 خود نقشه استاندار MapLibre
          MapLibreMap(
            initialCameraPosition: CameraPosition(
              target: widget.targetLocation ?? _currentUserLatLng,
              zoom: 15.0,
            ),
            styleString: 'assets/map/style.json',
            myLocationEnabled: true, // نمایش موقعیت زنده کاربر به صورت نیتیو
            myLocationTrackingMode: MyLocationTrackingMode.tracking,
            myLocationRenderMode: MyLocationRenderMode.normal,
            trackCameraPosition: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onCameraMove: (CameraPosition position) {
              if (!_isMapMoving) {
                setState(() => _isMapMoving = true);
              }
            },
            onCameraIdle: () {
              setState(() => _isMapMoving = false);
              if (_currentStep < 2 && _mapController != null) {
                _updateAddressFromCamera(_mapController!.cameraPosition!.target);
              }
            },
          ),

          // 🔹 پین شناور در مرکز نقشه (فقط برای مراحل انتخاب ۰ و ۱)
          if (_currentStep < 2)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Icon(
                  Icons.location_on,
                  size: 48,
                  color: _currentStep == 0 ? Colors.blue : Colors.red,
                ),
              ),
            ),

          // 🔹 دکمه‌های شناور بالای صفحه
          Positioned(
            top: 45,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_currentStep == 0) {
                      Navigator.pop(context);
                    } else {
                      setState(() => _currentStep--);
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                    ),
                    child: Icon(
                      _currentStep == 0 ? Icons.home : Icons.arrow_back,
                      color: AppColors.primaryBrand,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 کشوی هوشمند پایینی
          if (_currentStep == 0 || _currentStep == 1)
            SmartLocationSheet(
              currentStep: _currentStep,
              currentAddress: currentOrigin,
              currentDestination: currentDestination,
              isMapIdle: !_isMapMoving, 
              isExpanded: _isSheetExpanded,
              onExpandChanged: (expanded) {
                setState(() => _isSheetExpanded = expanded);
              },
              onConfirmStep: () {
                if (_currentStep == 0) {
                  _confirmOrigin();
                } else {
                  _confirmDestination();
                }
              },
              onSearchOriginTap: (addr) async {
                var response = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const SearchDestinationPlace()),
                );
                if (response == "placeSelected") _confirmOrigin();
              },
              onSearchDestinationTap: () async {
                var response = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const SearchDestinationPlace()),
                );
                if (response == "placeSelected") _confirmDestination();
              },
              onGpsTap: () async {
                Position pos = await Geolocator.getCurrentPosition();
                _moveCameraWithoutClosingSheet(LatLng(pos.latitude, pos.longitude), 17.0);
              },
            ),

          if (_currentStep == 2)
            MapBottomSheets.buildStep2(
              selectedCategory: _selectedCategory,
              selectedVehicleType: _selectedVehicleType,
              actualFareAmount: actualFareAmount,
              safirColor: AppColors.primaryBrand,
              hasActiveTripOptions: false,
              isScheduled: false,
              hasPromoCode: false,
              onCategoryChanged: (cat) {
                setState(() => _selectedCategory = cat);
              },
              onVehicleSelected: (index, vType) {
                setState(() {
                  _selectedVehicleType = index;
                  selectedVehicle = vType;
                });
                _fetchRoute();
              },
              onRequestTrip: () {
                setState(() => _currentStep = 3);
              },
              onTripOptionsTap: () {},
              onScheduleTap: () {},
              onPromoCodeTap: () {},
            ),
        ],
      ),
    );
  }
}
