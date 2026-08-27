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
import '../widgets/map_location_label.dart';
import 'package:safir_passengers/widgets/live_location_marker.dart';

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

class _SafirMapScreenState extends State<SafirMapScreen> with TickerProviderStateMixin {
  MapLibreMapController? _mapController;
  
  LatLng _currentUserLatLng = const LatLng(34.5333, 69.1667);
  double _currentGpsAccuracy = 0.0;

  StreamSubscription<Position>? _positionStreamSubscription;

  LatLng? _originLatLng;
  LatLng? _destinationLatLng;

  Point<num>? _originScreenPoint;
  Point<num>? _destinationScreenPoint;

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

  bool get _hasActiveTripOptions =>
      _secondDestinationAddress != null ||
      _stopDurationMinutes > 0 ||
      _isRoundTrip ||
      _hasExtraLuggage ||
      _preferSilence;

  bool get _isScheduled => _scheduledDateTime != null;
  bool get _hasPromoCode => _appliedPromoCode != null && _appliedPromoCode!.isNotEmpty;

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
    if (selectedVehicle == "Bike") {
      _selectedCategory = 1;
    } else if (selectedVehicle == "Auto") {
      _selectedCategory = 0;
      _selectedVehicleType = 1;
    } else {
      _selectedCategory = 0;
      _selectedVehicleType = 0;
    }

    _startLiveLocationUpdates();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _positionStreamSubscription?.cancel();
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

  Future<void> _updateMarkerPositions() async {
  if (_mapController == null) return;

  try {
    if (_originLatLng != null) {
      // استفاده از متد جدید و استاندارد maplibre_gl 0.26.2
      final originPoint = await _mapController!.toScreenCoordinate(_originLatLng!);
      if (mounted) {
        setState(() {
          _originScreenPoint = Point<num>(originPoint.x, originPoint.y);
        });
      }
    }
    if (_destinationLatLng != null) {
      final destPoint = await _mapController!.toScreenCoordinate(_destinationLatLng!);
      if (mounted) {
        setState(() {
          _destinationScreenPoint = Point<num>(destPoint.x, destPoint.y);
        });
      }
    }
  } catch (e) {
    debugPrint("Error updating marker positions: $e");
  }
}



  Future<void> _startLiveLocationUpdates() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      if (mounted) {
        final targetLatLng = LatLng(initialPosition.latitude, initialPosition.longitude);
        setState(() {
          _currentUserLatLng = targetLatLng;
          _currentGpsAccuracy = initialPosition.accuracy;
        });

        // 🔹 نمای دور اولیه (مشابه اسنپ)
        _animatedMapMove(targetLatLng, 15.0);
        if (_currentStep < 2) {
          _updateAddressFromCamera(targetLatLng);
        }
      }

      final LocationSettings locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 3,
        intervalDuration: const Duration(seconds: 1),
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        if (mounted) {
          setState(() {
            _currentUserLatLng = LatLng(position.latitude, position.longitude);
            _currentGpsAccuracy = position.accuracy;
          });
        }
      });
    } catch (e) {
      debugPrint("Error fetching GPS location stream: $e");
    }
  }

  Future<void> _handleGpsTap() async {
    HapticFeedback.lightImpact();
    // 🔹 زوم نزدیک‌تر هنگام لمس دکمه GPS
    _animatedMapMove(_currentUserLatLng, 17.8);

    try {
      Position pos = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 2),
      );
      
      LatLng freshPoint = LatLng(pos.latitude, pos.longitude);

      if (mounted) {
        setState(() {
          _currentUserLatLng = freshPoint;
          _currentGpsAccuracy = pos.accuracy;
        });

        if (_currentStep < 2) {
          _updateAddressFromCamera(freshPoint);
        }
      }
    } catch (_) {}
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    if (_mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(destLocation, destZoom),
    );
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
            String road = addressObj['road'] ?? addressObj['pedestrian'] ?? addressObj['path'] ?? addressObj['suburb'] ?? '';

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
            _senderAddressController.text = formattedAddress;
          } else if (_currentStep == 1) {
            appInfo.updateDropOffLocation(userLocation);
            _receiverAddressController.text = formattedAddress;
          }
        }
      } catch (e) {
        debugPrint("Error reverse geocoding: $e");
      }
    });
  }

  void _confirmOrigin() async {
    HapticFeedback.mediumImpact();
    if (_mapController == null) return;
    
    LatLng currentCenter = _mapController!.cameraPosition!.target;

    var appInfo = Provider.of<AppInfo>(context, listen: false);
    appInfo.updatePickUpLocation(AddressModel(
      latitudePosition: currentCenter.latitude,
      longitudePosition: currentCenter.longitude,
      placeName: appInfo.pickUpLocation?.placeName ?? 'origin_label'.tr(),
    ));

    setState(() {
      _originLatLng = currentCenter;
    });
    _updateMarkerPositions();

    // 🔹 زوم نزدیک به مبدأ جهت انتخاب دقیق‌تر مقصد
    _animatedMapMove(currentCenter, 17.8);

    if (widget.serviceType == 'cargo') {
      CargoSheets.showSenderDialog(
        context: context,
        nameController: _senderNameController,
        phoneController: _senderPhoneController,
        addressController: _senderAddressController,
        unitController: _senderUnitController,
        floorController: _senderFloorController,
        noteController: _senderNoteController,
        onConfirm: () {
          setState(() {
            _currentStep = 1;
            _isSheetExpanded = true;
          });
        },
      );
    } else if (widget.serviceType == 'intercity') {
      setState(() {
        _currentStep = 1;
        _isSheetExpanded = true;
      });
      IntercitySheets.showCityPicker(
        context: context,
        targetCities: _intercityCities,
        onCitySelected: (selectedCity) {
          LatLng cityLatLng = LatLng(selectedCity['lat'], selectedCity['lng']);
          _animatedMapMove(cityLatLng, 13.0);
        },
      );
    } else {
      setState(() {
        _currentStep = 1;
        _isSheetExpanded = true;
      });
    }
  }

  void _confirmDestination() async {
    HapticFeedback.mediumImpact();
    if (_mapController == null) return;
    
    LatLng currentCenter = _mapController!.cameraPosition!.target;

    var appInfo = Provider.of<AppInfo>(context, listen: false);
    appInfo.updateDropOffLocation(AddressModel(
      latitudePosition: currentCenter.latitude,
      longitudePosition: currentCenter.longitude,
      placeName: appInfo.dropOffLocation?.placeName ?? 'destination_label'.tr(),
    ));

    setState(() {
      _destinationLatLng = currentCenter;
    });
    _updateMarkerPositions();

    if (widget.serviceType == 'cargo') {
      CargoSheets.showReceiverDialog(
        context: context,
        nameController: _receiverNameController,
        phoneController: _receiverPhoneController,
        addressController: _receiverAddressController,
        unitController: _receiverUnitController,
        floorController: _receiverFloorController,
        noteController: _receiverNoteController,
        selectedPackageType: _cargoPackageType,
        onPackageTypeChanged: (val) => setState(() => _cargoPackageType = val ?? ''),
        selectedInsurance: _cargoInsurance,
        onInsuranceChanged: (val) => setState(() => _cargoInsurance = val ?? ''),
        onConfirm: () {
          setState(() => _currentStep = 2);
          _fetchRoute();
        },
      );
    } else {
      setState(() => _currentStep = 2);
      _fetchRoute();
    }
  }

  void _fetchRoute() {
    var appInfo = Provider.of<AppInfo>(context, listen: false);
    if (appInfo.pickUpLocation == null || _mapController == null) return;

    setState(() {
      _routePolylinePoints.clear();
      _mapController!.clearLines();
    });

    LatLng originLatLng = _originLatLng ?? 
        LatLng(appInfo.pickUpLocation!.latitudePosition!, appInfo.pickUpLocation!.longitudePosition!);
    LatLng destLatLng = _mapController!.cameraPosition!.target;

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
            _destinationLatLng = destLatLng;
          });

          _updateMarkerPositions();

          if (_routePolylinePoints.isNotEmpty) {
            await _mapController!.addLine(
              LineOptions(
                geometry: _routePolylinePoints,
                lineColor: "#0066FF",
                lineWidth: 5.5,
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

  void _openTripOptionsSheet() {
    MapBottomSheets.showTripOptions(
      context,
      TripOptionsSheet(
        secondDestination: _secondDestinationAddress,
        stopMinutes: _stopDurationMinutes,
        isRoundTrip: _isRoundTrip,
        hasLuggage: _hasExtraLuggage,
        preferSilence: _preferSilence,
        onSelectSecondDestinationOnMap: () async {
          var response = await Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const SearchDestinationPlace()),
          );
          if (response == "placeSelected") {
            var appInfo = Provider.of<AppInfo>(context, listen: false);
            setState(() {
              _secondDestinationAddress = appInfo.dropOffLocation?.placeName;
            });
            _fetchRoute();
          }
        },
        onSave: (secondDest, stop, round, luggage, silence) {
          setState(() {
            _secondDestinationAddress = secondDest;
            _stopDurationMinutes = stop;
            _isRoundTrip = round;
            _hasExtraLuggage = luggage;
            _preferSilence = silence;
          });
          _fetchRoute();
        },
      ),
    );
  }

  void _openScheduleSheet() {
    MapBottomSheets.showScheduleTrip(
      context,
      ScheduleTripSheet(
        initialDateTime: _scheduledDateTime,
        onScheduleConfirmed: (selectedTime) {
          setState(() {
            _scheduledDateTime = selectedTime;
          });
        },
      ),
    );
  }

  void _openPromoCodeSheet() {
    MapBottomSheets.showPromoCode(
      context,
      PromoCodeSheet(
        onApply: (code) {
          setState(() {
            _appliedPromoCode = code;
          });
        },
      ),
    );
  }

  void startTrip() {
    HapticFeedback.heavyImpact();
    setState(() => _currentStep = 3);

    try {
      tripRequestRef = MapControllerLogic.makeTripRequest(
        context: context,
        actualFareAmount: actualFareAmount,
        bidAmount: bidAmount,
        selectedVehicle: widget.serviceType == 'cargo' ? _cargoSelectedVehicle : selectedVehicle,
        tripDurationText: _tripDurationText,
        estimatedArrivalTime: _estimatedArrivalTime,
        onStatusChanged: (newStatus) {
          if (mounted) setState(() => status = newStatus);
        },
        onTripEnded: () {},
      );

      if (tripRequestRef != null) {
        tripStreamSubscription = tripRequestRef!.snapshots().listen((snapshot) async {
          if (!snapshot.exists || snapshot.data() == null) return;
          var data = snapshot.data() as Map<String, dynamic>;

          if (mounted) {
            setState(() {
              status = data["status"] ?? status;
              nameDriver = data["driverName"] ?? data["driver_phone"] ?? nameDriver;
              phoneNumberDriver = data["driverPhone"] ?? data["driver_phone"] ?? phoneNumberDriver;
              photoDriver = data["driverPhoto"] ?? data["driver_photo"] ?? photoDriver;
              carDetailsDriver = data["carDetails"] ?? data["car_details"] ?? carDetailsDriver;

              if (status == "accepted") {
                _currentStep = 4;
              }
            });
          }

          if (status == "ended" || status == "completed") {
            tripStreamSubscription?.cancel();
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RateDriverScreen(
                    tripId: tripRequestRef?.id ?? "",
                    driverId: data["driverId"] ?? "",
                    driverName: nameDriver,
                    carModel: carDetailsDriver,
                    plateNumber: data["carNumber"] ?? data["plateNumber"] ?? "",
                    driverPhoto: photoDriver,
                  ),
                ),
              );
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error starting trip: $e");
    }
  }

  void cancelTrip() {
    HapticFeedback.lightImpact();
    tripRequestRef?.delete();
    tripStreamSubscription?.cancel();
    if (mounted) setState(() => _currentStep = 2);
  }

  void _handleBackAction() {
    HapticFeedback.lightImpact();
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else {
      setState(() {
        _currentStep--;
        if (_currentStep == 0) {
          _originLatLng = null;
          _routePolylinePoints.clear();
          _mapController?.clearLines();
        } else if (_currentStep == 1) {
          _destinationLatLng = null;
          _routePolylinePoints.clear();
          _mapController?.clearLines();
        }
      });
    }
  }

  void _showRideForWhomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'ride_for_whom_title'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.person, color: AppColors.primaryBrand),
                title: Text('for_myself'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                trailing: _rideForWhomKey == "for_myself" ? const Icon(Icons.check_circle, color: AppColors.success) : null,
                onTap: () {
                  setState(() => _rideForWhomKey = "for_myself");
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.group_outlined, color: Colors.orange),
                title: Text('for_someone_else'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                trailing: _rideForWhomKey == "for_someone_else" ? const Icon(Icons.check_circle, color: AppColors.success) : null,
                onTap: () {
                  setState(() => _rideForWhomKey = "for_someone_else");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAdvancedProfile() {
    if (_hasNotification) {
      setState(() => _hasNotification = false);
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withOpacity(0.22),
      builder: (context) {
        return const SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ProfileAnimatedMenu(),
              ],
            ),
          ),
        );
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

    Color activePinColor = _currentStep == 0 ? AppColors.originBlue : AppColors.primaryBrand;

    return Scaffold(
      body: Stack(
        children: [
          // ۱. نقشه بومی MapLibre HD
          MapLibreMap(
            initialCameraPosition: CameraPosition(
              target: widget.targetLocation ?? _currentUserLatLng,
              zoom: 15.0, // 🔹 نمای دور در شروع جهت دید کلی (مشابه اسنپ)
            ),
            styleString: 'assets/map/style.json',
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.tracking,
            myLocationRenderMode: MyLocationRenderMode.normal,
            onMapCreated: (controller) {
              _mapController = controller;
              if (widget.targetLocation != null) {
                _animatedMapMove(widget.targetLocation!, 17.8);
              }
            },
            onCameraMove: (CameraPosition position) {
              if (!_isMapMoving) {
                setState(() {
                  _isMapMoving = true;
                  _isSheetExpanded = false;
                });
              }
              _updateMarkerPositions();
            },
            onCameraIdle: () {
              setState(() => _isMapMoving = false);
              _updateMarkerPositions();
              if (_currentStep < 2 && _mapController != null) {
                _updateAddressFromCamera(_mapController!.cameraPosition!.target);
              }
            },
            onMapClick: (_, __) {
              if (_isSheetExpanded) {
                setState(() => _isSheetExpanded = false);
              }
            },
          ),

          // 🔹 مارکر مبدأ
          if (_originLatLng != null && _originScreenPoint != null)
            Positioned(
              left: _originScreenPoint!.x.toDouble() - 55,
              top: _originScreenPoint!.y.toDouble() - 40,
              child: MapOriginLabel(
                labelText: 'origin_label'.tr(),
              ),
            ),

          // 🔹 مارکر مقصد
          if (_destinationLatLng != null && _destinationScreenPoint != null)
            Positioned(
              left: _destinationScreenPoint!.x.toDouble() - 100,
              top: _destinationScreenPoint!.y.toDouble() - 60,
              child: MapDestinationLabel(
                labelText: 'destination_label'.tr(),
                arrivalTime: _estimatedArrivalTime,
              ),
            ),

          // ۲. پین مرکز صفحه (در مراحل ۰ و ۱)
          if (_currentStep < 2)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: SizedBox(
                  width: 50,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 14,
                        height: 7,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.22),
                          borderRadius: const BorderRadius.all(Radius.elliptical(14, 7)),
                        ),
                      ),
                      if (_isMapMoving)
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 3.5,
                            height: 3.5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF424242),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        bottom: _isMapMoving ? 16 : 4,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _currentStep == 0
                                ? Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: activePinColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2.5),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: activePinColor,
                                      borderRadius: BorderRadius.circular(9),
                                      border: Border.all(color: Colors.white, width: 2.5),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ),
                            Container(
                              width: 3,
                              height: 14,
                              color: const Color(0xFF424242),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ۳. نوار بالای صفحه
          Positioned(
            top: 45,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _handleBackAction,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
                      ],
                    ),
                    child: Icon(
                      _currentStep == 0 ? Icons.home_rounded : Icons.arrow_back,
                      color: AppColors.primaryBrand,
                      size: 24,
                    ),
                  ),
                ),

                if (_currentStep < 2)
                  GestureDetector(
                    onTap: _showRideForWhomSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textPrimary),
                          const SizedBox(width: 4),
                          Text(
                            _rideForWhomKey.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                GestureDetector(
                  onTap: _showAdvancedProfile,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.person_outline,
                          color: AppColors.primaryBrand,
                          size: 26,
                        ),
                        if (_hasNotification)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ۴. شیت موقعیت (گام ۰ و ۱)
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
                if (response == "placeSelected") {
                  _confirmOrigin();
                }
              },
              onSearchDestinationTap: () async {
                if (widget.serviceType == 'intercity') {
                  IntercitySheets.showCityPicker(
                    context: context,
                    targetCities: _intercityCities,
                    onCitySelected: (selectedCity) {
                      LatLng cityLatLng = LatLng(selectedCity['lat'], selectedCity['lng']);
                      _animatedMapMove(cityLatLng, 13.0);
                    },
                  );
                } else {
                  var response = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const SearchDestinationPlace()),
                  );
                  if (response == "placeSelected") {
                    if (widget.serviceType == 'cargo') {
                      _confirmDestination();
                    } else {
                      _fetchRoute();
                      setState(() => _currentStep = 2);
                    }
                  }
                }
              },
              onGpsTap: _handleGpsTap,
            ),

          // ۵. شیت گام ۲
          if (_currentStep == 2)
            widget.serviceType == 'cargo'
                ? CargoSheets.buildCargoSummarySheet(
                    context: context,
                    fareAmount: actualFareAmount,
                    selectedVehicleType: _cargoSelectedVehicle,
                    onVehicleSelected: (vehicleId) {
                      setState(() => _cargoSelectedVehicle = vehicleId);
                    },
                    paymentPayer: _cargoPaymentPayer,
                    onPayerChanged: (payer) {
                      setState(() => _cargoPaymentPayer = payer);
                    },
                    onRequestTrip: () => startTrip(),
                  )
                : widget.serviceType == 'intercity'
                    ? IntercitySheets.buildStep2IntercitySheet(
                        context: context,
                        fareAmount: actualFareAmount,
                        travelDate: _intercityTravelDate,
                        passengerCount: _intercityPassengers,
                        onDateSelected: (date) => setState(() => _intercityTravelDate = date),
                        onPassengersChanged: (count) => setState(() => _intercityPassengers = count),
                        onRequestTrip: () => startTrip(),
                      )
                    : MapBottomSheets.buildStep2(
                        selectedCategory: _selectedCategory,
                        selectedVehicleType: _selectedVehicleType,
                        actualFareAmount: actualFareAmount,
                        safirColor: AppColors.primaryBrand,
                        hasActiveTripOptions: _hasActiveTripOptions,
                        isScheduled: _isScheduled,
                        hasPromoCode: _hasPromoCode,
                        onCategoryChanged: (cat) {
                          setState(() {
                            _selectedCategory = cat;
                            _selectedVehicleType = 0;
                            selectedVehicle = cat == 0 ? "Car" : "Bike";
                          });
                          _fetchRoute();
                        },
                        onVehicleSelected: (index, vType) {
                          setState(() {
                            _selectedVehicleType = index;
                            selectedVehicle = vType;
                          });
                          _fetchRoute();
                        },
                        onRequestTrip: () => startTrip(),
                        onTripOptionsTap: _openTripOptionsSheet,
                        onScheduleTap: _openScheduleSheet,
                        onPromoCodeTap: _openPromoCodeSheet,
                      ),

          // ۶. در حال جستجوی راننده (گام ۳)
          if (_currentStep == 3)
            MapBottomSheets.buildStep3(
              safirColor: AppColors.primaryBrand,
              originAddress: currentOrigin,
              destinationAddress: currentDestination,
              fareAmount: actualFareAmount,
              onCancel: cancelTrip,
              onBidPricePressed: () {},
            ),

          // ۷. قبول سفر (گام ۴)
          if (_currentStep == 4)
            MapBottomSheets.buildStep4(AppColors.primaryBrand),
        ],
      ),
    );
  }
}
