import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:safir_passengers/appInfo/app_info.dart';
import 'package:safir_passengers/constants/trip_status.dart';
import 'package:safir_passengers/models/address_models.dart';
import 'package:safir_passengers/global/global_var.dart'; 
import 'package:safir_passengers/global/trip_var.dart';
import 'package:safir_passengers/theme/app_colors.dart';
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

/// 🔹 تبدیل ویجت به تصویر برای MapLibre
Future<Uint8List> widgetToImageBytes(Widget widget) async {
  final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
  final PipelineOwner pipelineOwner = PipelineOwner();
  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

  final MediaQueryData mediaQueryData = MediaQueryData.fromView(ui.PlatformDispatcher.instance.views.first);

  final RenderView renderView = RenderView(
    view: ui.PlatformDispatcher.instance.views.first,
    child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
      logicalConstraints: BoxConstraints.tight(mediaQueryData.size),
      devicePixelRatio: mediaQueryData.devicePixelRatio,
    ),
  );

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final RenderObjectToWidgetElement<RenderBox> rootElement = RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: Directionality(
      textDirection: ui.TextDirection.rtl,
      child: widget,
    ),
  ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  final ui.Image image = await repaintBoundary.toImage(pixelRatio: 3.0);
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return byteData!.buffer.asUint8List();
}

/// 🚗 ویجت مخصوص نمایش مارکر ماشین راننده روی نقشه
class DriverCarMarker extends StatelessWidget {
  const DriverCarMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Image.asset(
        'assets/images/tracking_car.png', // آدرس عکس ماشین در پروژه شما
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.directions_car_rounded,
            size: 38,
            color: Color(0xFF0066FF),
          );
        },
      ),
    );
  }
}

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

  Symbol? _originSymbol;
  Symbol? _destinationSymbol;

  Symbol? _driverLiveSymbol;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _driverLocationStreamSubscription;
  String? _assignedDriverId;
  Uint8List? _cachedDriverCarBytes; // بایت‌های کش‌شده برای جلوگیری از افت فریم

  bool _isMapMoving = false;
  bool _isProgrammaticMove = false;
  bool _isSheetExpanded = true; 
  Timer? _debounceTimer;

  bool _hasNotification = false; 

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
  final AudioPlayer _tripAudioPlayer = AudioPlayer();

String? _lastTripStatus;
bool _hasPlayedAcceptedSound = false;
bool _hasPlayedArrivedSound = false;

  double actualFareAmount = 50.0;
  double? bidAmount;
  String selectedVehicle = "Car";
  double _tripDistanceInKm = 0.0;

  String _driverPlateProvince = "";
  String _driverPlateCategory = "";
  String _driverPlateFarsiNum = "";
  String _driverPlateNum = "";
  bool _driverIsTempPlate = false;
  String _driverCarColor = "";

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
    _driverLocationStreamSubscription?.cancel();
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
    _tripAudioPlayer.dispose();
    super.dispose();
  }

  void _listenToDriverLiveLocation(String driverId) {
    if (_assignedDriverId == driverId && _driverLocationStreamSubscription != null) return;

    _driverLocationStreamSubscription?.cancel();
    _assignedDriverId = driverId;

    _driverLocationStreamSubscription = FirebaseFirestore.instance
        .collection('driver_locations')
        .doc(driverId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists || snapshot.data() == null || _mapController == null) return;

      final data = snapshot.data()!;
      final double? lat = double.tryParse(data['latitude']?.toString() ?? '');
      final double? lng = double.tryParse(data['longitude']?.toString() ?? '');
      final double heading = double.tryParse(data['heading']?.toString() ?? '') ?? 0.0;

      if (lat != null && lng != null) {
        final driverLatLng = LatLng(lat, lng);
        await _updateDriverMarkerOnMap(driverLatLng, heading);
      }
    });
  }

  /// 🚀 بروزرسانی مارکر ماشین راننده روی نقشه با چرخش جهت حرکت
  Future<Uint8List?> _loadCarIconBytes() async {
  if (_cachedDriverCarBytes != null) return _cachedDriverCarBytes;

  try {
    final ByteData data = await rootBundle.load('assets/images/tracking_car.png');
    _cachedDriverCarBytes = data.buffer.asUint8List();
    return _cachedDriverCarBytes;
  } catch (e) {
    debugPrint('Error loading car icon asset: $e');
    return null;
  }
}

Future<void> _updateDriverMarkerOnMap(
  LatLng position,
  double heading,
) async {
  final controller = _mapController;
  if (controller == null) return;

  try {
    final Uint8List? carBytes = await _loadCarIconBytes();
    if (carBytes == null) return;

    await controller.addImage('driver-car-icon', carBytes);

    final SymbolOptions options = SymbolOptions(
      geometry: position,
      iconImage: 'driver-car-icon',
      iconAnchor: 'center',
      iconRotate: heading,
      iconSize: 1.2,
    );

    if (_driverLiveSymbol == null) {
      _driverLiveSymbol = await controller.addSymbol(options);
    } else {
      await controller.updateSymbol(_driverLiveSymbol!, options);
    }
  } catch (e) {
    debugPrint('Error updating driver live marker: $e');
  }
}


  Future<void> _stopListeningToDriverLocation() async {
    await _driverLocationStreamSubscription?.cancel();
    _driverLocationStreamSubscription = null;
    _assignedDriverId = null;

    if (_driverLiveSymbol != null && _mapController != null) {
      await _mapController!.removeSymbol(_driverLiveSymbol!);
      _driverLiveSymbol = null;
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
    _isProgrammaticMove = true;
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

          if (!mounted) return;

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

  Future<void> _confirmOrigin() async {
    HapticFeedback.mediumImpact();

    if (_mapController == null) return;
    final camera = await _mapController!.queryCameraPosition();
    if (camera == null) return;

    final currentCenter = camera.target;
    if (!mounted) return;
    final appInfo = Provider.of<AppInfo>(context, listen: false);

    appInfo.updatePickUpLocation(
      AddressModel(
        latitudePosition: currentCenter.latitude,
        longitudePosition: currentCenter.longitude,
        placeName: appInfo.pickUpLocation?.placeName ?? 'مبدأ',
      ),
    );

    final bytes = await widgetToImageBytes(
      const MapOriginLabel(labelText: 'مبدأ'),
    );
    await _mapController!.addImage('origin-marker-icon', bytes);

    if (_originSymbol != null) await _mapController!.removeSymbol(_originSymbol!);
    _originSymbol = await _mapController!.addSymbol(
      SymbolOptions(
        geometry: currentCenter,
        iconImage: 'origin-marker-icon',
        iconAnchor: 'bottom',
      ),
    );

    setState(() {
      _originLatLng = currentCenter;
    });

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

  Future<void> _confirmDestination() async {
    HapticFeedback.mediumImpact();

    if (_mapController == null) return;
    final camera = await _mapController!.queryCameraPosition();
    if (camera == null) return;

    final currentCenter = camera.target;
    if (!mounted) return;
    final appInfo = Provider.of<AppInfo>(context, listen: false);

    appInfo.updateDropOffLocation(
      AddressModel(
        latitudePosition: currentCenter.latitude,
        longitudePosition: currentCenter.longitude,
        placeName: appInfo.dropOffLocation?.placeName ?? 'مقصد',
      ),
    );

    final bytes = await widgetToImageBytes(
      MapDestinationLabel(
        labelText: 'مقصد',
        arrivalTime: _estimatedArrivalTime,
      ),
    );
    await _mapController!.addImage('dest-marker-icon', bytes);

    if (_destinationSymbol != null) await _mapController!.removeSymbol(_destinationSymbol!);
    _destinationSymbol = await _mapController!.addSymbol(
      SymbolOptions(
        geometry: currentCenter,
        iconImage: 'dest-marker-icon',
        iconAnchor: 'bottom',
      ),
    );

    setState(() {
      _destinationLatLng = currentCenter;
    });

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
    LatLng destLatLng = _destinationLatLng ?? _mapController!.cameraPosition!.target;

    MapControllerLogic.getOSRMRoute(
      context: context,
      selectedVehicle: selectedVehicle,
      customOrigin: originLatLng,
      customDestination: destLatLng,
      onRouteFetched: (points, fare, durationText, arrivalTime) async {
        if (mounted) {
          double totalMeters = 0.0;
          for (int i = 0; i < points.length - 1; i++) {
            totalMeters += Geolocator.distanceBetween(
              points[i].latitude,
              points[i].longitude,
              points[i + 1].latitude,
              points[i + 1].longitude,
            );
          }

          setState(() {
            _routePolylinePoints = points;
            _tripDistanceInKm = totalMeters / 1000.0;
            actualFareAmount = fare;
            _tripDurationText = durationText;
            _estimatedArrivalTime = arrivalTime;
          });

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

            _isProgrammaticMove = true;
            _mapController!.animateCamera(
              CameraUpdate.newLatLngBounds(
                LatLngBounds(
                  southwest: LatLng(minLat, minLng),
                  northeast: LatLng(maxLat, maxLng),
                ),
                left: 50, top: 120, right: 50, bottom: 100,
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
            if (!mounted) return;
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
  Future<void> _playTripStatusSound(String tripStatus) async {
  try {
    if (tripStatus == TripStatus.accepted && !_hasPlayedAcceptedSound) {
      _hasPlayedAcceptedSound = true;

      await _tripAudioPlayer.stop();
      await _tripAudioPlayer.play(
        AssetSource('audio/fa/driver_accepted.mp3'),
        volume: 1.0,
      );
    }

    if (tripStatus == TripStatus.arrived && !_hasPlayedArrivedSound) {
      _hasPlayedArrivedSound = true;

      await _tripAudioPlayer.stop();
      await _tripAudioPlayer.play(
        AssetSource('audio/fa/driver_arrived.mp3'),
        volume: 1.0,
      );
    }
  } catch (e) {
    debugPrint('Trip status audio error: $e');
  }
  }

  void startTrip() async {
    HapticFeedback.heavyImpact();
    
    var appInfo = Provider.of<AppInfo>(context, listen: false);
    
    if (appInfo.pickUpLocation == null || appInfo.dropOffLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "لطفاً مبدأ و مقصد را مشخص کنید.",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
      );
      return;
    }

    setState(() => _currentStep = 3);
    _hasPlayedAcceptedSound = false;
    _hasPlayedArrivedSound = false;
    _lastTripStatus = null;

    try {
      tripRequestRef = FirebaseFirestore.instance.collection('rides').doc();

      String passengerUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      String passengerNameVal = FirebaseAuth.instance.currentUser?.displayName ?? 'مسافر سفیر';
      String passengerPhoneVal = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

      Map<String, dynamic> passengerTripDetails = {
        'ride_id': tripRequestRef!.id,
        'status': TripStatus.searching,
        'driver_id': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
        
        'passenger_id': passengerUid,
        'passenger_name': passengerNameVal,
        'passenger_phone': passengerPhoneVal,
        'userName': passengerNameVal,
        'userPhone': passengerPhoneVal,
        'userRating': '4.8',
        
        'originAddress': appInfo.pickUpLocation!.placeName ?? '',
        'destinationAddress': appInfo.dropOffLocation!.placeName ?? '',
        'origin_address': appInfo.pickUpLocation!.placeName ?? '',
        'destination_address': appInfo.dropOffLocation!.placeName ?? '',
        'pickup_address': appInfo.pickUpLocation!.placeName ?? '',
        'dropoff_address': appInfo.dropOffLocation!.placeName ?? '',

        'origin': {
          'latitude': appInfo.pickUpLocation!.latitudePosition,
          'longitude': appInfo.pickUpLocation!.longitudePosition,
        },
        'destination': {
          'latitude': appInfo.dropOffLocation!.latitudePosition,
          'longitude': appInfo.dropOffLocation!.longitudePosition,
        },
        'originLatLng': GeoPoint(
          appInfo.pickUpLocation!.latitudePosition!,
          appInfo.pickUpLocation!.longitudePosition!,
        ),
        'destinationLatLng': GeoPoint(
          appInfo.dropOffLocation!.latitudePosition!,
          appInfo.dropOffLocation!.longitudePosition!,
        ),
        
        'fareAmount': actualFareAmount,
        'fare': actualFareAmount,
        'price': actualFareAmount,
        'distance': _tripDistanceInKm,
        'duration': _tripDurationText,
        'service_type': widget.serviceType,
        'vehicle_type': selectedVehicle,
      };

      await tripRequestRef!.set(passengerTripDetails);

      tripStreamSubscription = tripRequestRef!.snapshots().listen((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) return;
        
        var data = snapshot.data() as Map<String, dynamic>;
        String tripStatus = data["status"] ?? TripStatus.searching;
        String driverId = data["driver_id"] ?? data["driverId"] ?? "";
        if (_lastTripStatus != tripStatus) {
       _lastTripStatus = tripStatus;
       _playTripStatusSound(tripStatus);
        }

        if (mounted) {
          setState(() {
            nameDriver = data["driver_name"] ?? data["driverName"] ?? nameDriver;
            phoneNumberDriver = data["driver_phone"] ?? data["driverPhone"] ?? phoneNumberDriver;
            photoDriver = data["driver_photo"] ?? data["driverPhoto"] ?? photoDriver;
            carDetailsDriver = data["car_details"] ?? data["carModel"] ?? carDetailsDriver;

            _driverCarColor = data["car_color"] ?? data["carColor"] ?? "سفید";
            _driverPlateProvince = data["plate_province"] ?? "کابل";
            _driverPlateCategory = data["plate_category"] ?? "ش";
            _driverPlateFarsiNum = data["plate_farsi_num"] ?? data["plateNumber"] ?? "";
            _driverPlateNum = data["plate_num"] ?? data["plateNumber"] ?? "";
            _driverIsTempPlate = data["is_temp_plate"] ?? false;

            if (tripStatus == TripStatus.accepted || 
                tripStatus == TripStatus.arrived || 
                tripStatus == TripStatus.onTrip) {
              
              setState(() {
                _currentStep = 4;

                nameDriver = data["driver_name"] ?? data["driverName"] ?? nameDriver;
                phoneNumberDriver = data["driver_phone"] ?? data["driverPhone"] ?? phoneNumberDriver;
                photoDriver = data["driver_photo"] ?? data["driverPhoto"] ?? photoDriver;
                carDetailsDriver = data["car_details"] ?? data["carModel"] ?? carDetailsDriver;

                _driverCarColor = data["car_color"] ?? data["carColor"] ?? "سفید";
                _driverPlateProvince = data["plate_province"] ?? "کابل";
                _driverPlateCategory = data["plate_category"] ?? "ش";
                _driverPlateFarsiNum = data["plate_farsi_num"] ?? data["plateNumber"] ?? "";
                _driverPlateNum = data["plate_num"] ?? data["plateNumber"] ?? "";
                _driverIsTempPlate = data["is_temp_plate"] ?? false;
              });

              if (driverId.isNotEmpty && driverId != "waiting") {
                _listenToDriverLiveLocation(driverId);
              }

              _fetchRoute();
            }

            if (tripStatus == TripStatus.arrived) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "راننده به مبدأ شما رسید.",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
              );
            }

            if (tripStatus == TripStatus.cancelledByDriver) {
              _currentStep = 2;
              tripStreamSubscription?.cancel();
              _stopListeningToDriverLocation();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "سفر توسط سفیر لغو گردید.",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
        }

        if (tripStatus == TripStatus.completed || tripStatus == TripStatus.ended) {
          tripStreamSubscription?.cancel();
          _stopListeningToDriverLocation();

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RateDriverScreen(
                  tripId: tripRequestRef?.id ?? "",
                  driverId: driverId,
                  driverName: nameDriver,
                  carModel: carDetailsDriver,
                  plateNumber: _driverPlateFarsiNum.isNotEmpty ? _driverPlateFarsiNum : _driverPlateNum,
                  driverPhoto: photoDriver,
                ),
              ),
            );
          }
        }
      });
    } catch (e) {
      debugPrint("Error starting trip: $e");
      if (mounted) {
        setState(() => _currentStep = 2);
      }
    }
  }

  void cancelTrip() async {
    HapticFeedback.lightImpact();

    if (tripRequestRef != null) {
      await tripRequestRef!.update({
        'status': TripStatus.cancelledByPassenger,
        'cancelled_at': FieldValue.serverTimestamp(),
      });
    }

    tripStreamSubscription?.cancel();
    _stopListeningToDriverLocation();

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
          if (_originSymbol != null) {
            _mapController?.removeSymbol(_originSymbol!);
            _originSymbol = null;
          }
          _routePolylinePoints.clear();
          _mapController?.clearLines();
        } else if (_currentStep == 1) {
          _destinationLatLng = null;
          if (_destinationSymbol != null) {
            _mapController?.removeSymbol(_destinationSymbol!);
            _destinationSymbol = null;
          }
          _routePolylinePoints.clear();
          _mapController?.clearLines();
        }
      });
    }
  }

  void _showAdvancedProfile() {
    if (_hasNotification) {
      setState(() => _hasNotification = false);
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileAnimatedMenu(),
      ),
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
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 🗺️ ۱. نقشه تمام صفحه
          RepaintBoundary(
            child: MapLibreMap(
              initialCameraPosition: CameraPosition(
                target: widget.targetLocation ?? _currentUserLatLng,
                zoom: 15.0,
              ),
              styleString: 'assets/map/style.json',
              trackCameraPosition: true,
              onMapCreated: (controller) {
                _mapController = controller;
                _isProgrammaticMove = true;
                if (widget.targetLocation != null) {
                  _animatedMapMove(widget.targetLocation!, 17.8);
                }
              },
              onCameraMove: (CameraPosition position) {
                if (!_isProgrammaticMove) {
                  if (!_isMapMoving) {
                    _isMapMoving = true;
                    if (_isSheetExpanded) {
                      setState(() {
                        _isSheetExpanded = false;
                      });
                    }
                  }
                }
              },
              onCameraIdle: () {
                final bool wasProgrammaticMove = _isProgrammaticMove;
                _isProgrammaticMove = false;

                if (_isMapMoving && mounted) {
                  setState(() {
                    _isMapMoving = false;
                  });
                }

                if (!wasProgrammaticMove && _currentStep < 2 && _mapController != null) {
                  _updateAddressFromCamera(
                    _mapController!.cameraPosition!.target,
                  );
                }
              },
              onMapClick: (_, __) {},
            ),
          ),

          // 📍 ۲. پین شناور در وسط نقشه
          if (_currentStep < 2)
            IgnorePointer(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: _isMapMoving ? 42 : 32,
                      height: _isMapMoving ? 42 : 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isMapMoving
                            ? Colors.black.withOpacity(0.08)
                            : Colors.black.withOpacity(0.15),
                      ),
                      child: Center(
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.40),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOutCubic,
                      transform: Matrix4.translationValues(
                        0,
                        _isMapMoving ? -45.0 : -20.0,
                        0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: activePinColor,
                              shape: _currentStep == 0 ? BoxShape.circle : BoxShape.rectangle,
                              borderRadius: _currentStep == 0 ? null : BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: _currentStep == 0 ? BoxShape.circle : BoxShape.rectangle,
                                  borderRadius: _currentStep == 0 ? null : BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 2.0,
                            height: 18,
                            color: const Color(0xFF333333),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 🔘 ۳. دکمه‌های شناور بالای صفحه
          Positioned(
            top: statusBarHeight + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // دکمه پروفایل شناور سمت چپ
                GestureDetector(
                  onTap: _showAdvancedProfile,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: Colors.grey[800],
                          size: 26,
                        ),
                        if (_hasNotification)
                          Positioned(
                            top: 3,
                            right: 3,
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

                // دکمه بیضی "برای خودم" در وسط
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard_arrow_down, size: 22, color: Colors.green.shade700),
                      const SizedBox(width: 6),
                      Text(
                        'برای خودم',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),

                // دکمه خانه / بازگشت شناور سمت راست
                GestureDetector(
                  onTap: _handleBackAction,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      _currentStep == 0 ? Icons.home_outlined : Icons.arrow_back,
                      color: Colors.grey[800],
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📄 ۴. باتم‌شیت‌ها بر اساس مراحل
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

          if (_currentStep == 2)
            widget.serviceType == 'cargo'
                ? CargoSheets.buildCargoSummarySheet(
                    context: context,
                    fareAmount: actualFareAmount,
                    distanceInKm: _tripDistanceInKm,
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
                        distanceInKm: _tripDistanceInKm,
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
                        distanceInKm: _tripDistanceInKm,
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

          if (_currentStep == 3) ...[
            MapBottomSheets.buildStep3(
              safirColor: AppColors.primaryBrand,
              originAddress: currentOrigin,
              destinationAddress: currentDestination,
              fareAmount: actualFareAmount,
              onCancel: cancelTrip,
              onBidPricePressed: () {},
            ),
          ] else if (_currentStep == 4) ...[
            MapBottomSheets.buildStep4(
              AppColors.primaryBrand,
              tripId: tripRequestRef?.id ?? "",
              nameDriver: nameDriver,
              photoDriver: photoDriver,
              phoneNumberDriver: phoneNumberDriver,
              carDetailsDriver: carDetailsDriver,
              carColorDriver: _driverCarColor,
              plateProvinceDriver: _driverPlateProvince,
              plateCategoryDriver: _driverPlateCategory,
              plateFarsiNumDriver: _driverPlateFarsiNum,
              plateNumDriver: _driverPlateNum,
              isTempPlateDriver: _driverIsTempPlate,
              tripFareAmount: actualFareAmount,
              estimatedArrivalTime: _tripDurationText.isNotEmpty ? _tripDurationText : "۵ دقیقه",
              onCancelTrip: cancelTrip,
            ),
          ],
        ],
      ),
    );
  }
}
