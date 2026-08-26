import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:safir_passengers/appInfo/app_info.dart';
import 'package:safir_passengers/global/global_var.dart';
import 'package:safir_passengers/models/address_models.dart';
import 'package:safir_passengers/models/predicted_places.dart';
import 'package:safir_passengers/widgets/place_prediction_tile.dart';

class SearchDestinationPlace extends StatefulWidget {
  const SearchDestinationPlace({super.key});

  @override
  State<SearchDestinationPlace> createState() => _SearchDestinationPlaceState();
}

class _SearchDestinationPlaceState extends State<SearchDestinationPlace> {
  List<PredictedPlaces> placesPredictedList = [];
  bool isLoading = false;
  Timer? _searchDebounce;
  http.Client? _activeClient; // ⚡ کلینت برای لغو درخواست‌های قبلی

  TextEditingController pickupTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController = TextEditingController();

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _activeClient?.close(); // بسته شدن درخواست‌های باز هنگام خروج
    pickupTextEditingController.dispose();
    destinationTextEditingController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String inputText) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    if (inputText.trim().length <= 1) {
      if (mounted) {
        setState(() {
          placesPredictedList = [];
          isLoading = false;
        });
      }
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      findPlaceAutoCompleteSearch(inputText);
    });
  }

  // 📡 متد بهینه‌شده جستجو با محدودسازی جغرافیایی شهر کاربر
  void findPlaceAutoCompleteSearch(String inputText) async {
    if (!mounted) return;

    // لغو درخواست قبلی در صورت تایپ سریع کاربر
    _activeClient?.close();
    _activeClient = http.Client();

    setState(() {
      isLoading = true;
    });

    try {
      final appInfo = Provider.of<AppInfo>(context, listen: false);
      final userLat = appInfo.pickUpLocation?.latitudePosition;
      final userLng = appInfo.pickUpLocation?.longitudePosition;

      final encodedQuery = Uri.encodeComponent(inputText.trim());

      String boundingBoxParams = "";
      if (userLat != null && userLng != null) {
        // ایجاد محدوده جغرافیایی (شعاع حدوداً ۳۰ کیلومتری حول موقعیت کاربر)
        double delta = 0.3; // مقدار تقریبی مختصات شهری
        double left = userLng - delta;
        double bottom = userLat - delta;
        double right = userLng + delta;
        double top = userLat + delta;

        // viewbox=left,top,right,bottom & bounded=1 باعث می‌شود نتایج فقط از همین محدوده برگردند
        boundingBoxParams = "&viewbox=$left,$top,$right,$bottom&bounded=1&lat=$userLat&lon=$userLng";
      }

      // افزودن countrycodes=af جهت اطمینان از جستجو در محدوده کشور
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$encodedQuery$boundingBoxParams&countrycodes=af&addressdetails=1&limit=15&accept-language=fa,ps,en',
      );

      final response = await _activeClient!.get(
        url,
        headers: {'User-Agent': 'safir_passengers_app'},
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200 && mounted) {
        final List<dynamic> responseData = json.decode(response.body);

        List<PredictedPlaces> tempPlaces = responseData
            .map<PredictedPlaces>((data) => PredictedPlaces.fromJson(data))
            .toList();

        setState(() {
          placesPredictedList = tempPlaces;
          isLoading = false;
        });
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching places: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _onPlaceSelected(PredictedPlaces place) {
    HapticFeedback.lightImpact();

    if (place.lat != null && place.lng != null) {
      AddressModel selectedDestination = AddressModel(
        placeName: place.mainText,
        humanReadableAddress: place.mainText,
        latitudePosition: place.lat,
        longitudePosition: place.lng,
      );

      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocation(selectedDestination);

      Navigator.pop(context, "placeSelected");
    }
  }

  @override
  void initState() {
    super.initState();
    var pickUpLocation = Provider.of<AppInfo>(context, listen: false).pickUpLocation;
    if (pickUpLocation != null) {
      pickupTextEditingController.text = pickUpLocation.placeName ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context);
          },
        ),
        title: Text(
          getTranslation(context, "search_address_and_destination_title"),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // مبدأ
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: pickupTextEditingController,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: getTranslation(context, "pickup_location_hint"),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // مقصد
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: destinationTextEditingController,
                          autofocus: true,
                          onChanged: _onSearchTextChanged,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: getTranslation(context, "where_to_destination_hint"),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF169365),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: LinearProgressIndicator(color: Color(0xFF169365)),
            ),

          const SizedBox(height: 10),

          // لیست نتایج
          (placesPredictedList.isNotEmpty)
              ? Expanded(
                  child: ListView.separated(
                    itemCount: placesPredictedList.length,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          _onPlaceSelected(placesPredictedList[index]);
                        },
                        child: PlacePredictionTileDesign(
                          predictedPlaces: placesPredictedList[index],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(
                        height: 1,
                        color: Colors.black12,
                        thickness: 0.5,
                      );
                    },
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      Text(
                        getTranslation(context, "search_address_empty_prompt"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
