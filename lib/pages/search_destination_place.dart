import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // جهت بازخورد لمسی (Haptic)
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
  Timer? _searchDebounce; // ⚡ تایمر کنترلی برای جلوگیری از درخواست‌های پیاپی

  TextEditingController pickupTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController = TextEditingController();

  @override
  void dispose() {
    _searchDebounce?.cancel(); // آزادسازی حافظه تایمر
    pickupTextEditingController.dispose();
    destinationTextEditingController.dispose();
    super.dispose();
  }

  // 🔍 متد بهینه‌شده جستجوی آدرس با کنترل Debounce (کاهش بار اینترنت و سرور)
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

    // ⏱️ صبر ۵۰۰ میلی‌ثانیه‌ای پس از آخرین کلید تایپ‌شده توسط کاربر
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      findPlaceAutoCompleteSearch(inputText);
    });
  }

  // 📡 متد واقعی دریافت پیشنهادها از Nominatim
  void findPlaceAutoCompleteSearch(String inputText) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final appInfo = Provider.of<AppInfo>(context, listen: false);
      final userLat = appInfo.pickUpLocation?.latitudePosition;
      final userLng = appInfo.pickUpLocation?.longitudePosition;

      final encodedQuery = Uri.encodeComponent(inputText.trim());

      // 📍 اولویت‌دهی جغرافیایی بر اساس موقعیت فعلی مسافر
      String locationBias = "";
      if (userLat != null && userLng != null) {
        locationBias = "&lat=$userLat&lon=$userLng";
      }

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$encodedQuery$locationBias&addressdetails=1&limit=10&accept-language=fa,ps,en',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'safir_passengers_app'},
      ).timeout(const Duration(seconds: 8)); // اضافه شدن Timeout جهت جلوگیری از معطلی

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

  // 🎯 انتخاب مکان و ثبت در Provider
  void _onPlaceSelected(PredictedPlaces place) {
    HapticFeedback.lightImpact();

    if (place.lat != null && place.lng != null) {
      AddressModel selectedDestination = AddressModel(
        placeName: place.mainText,
        humanReadableAddress: place.mainText,
        latitudePosition: place.lat,
        longitudePosition: place.lng,
      );

      // ذخیره مقصد در AppInfo Provider
      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocation(selectedDestination);

      // بازگشت به نقشه
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
          // کارت ورودی‌های مبدأ و مقصد
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 🔵 ۱. ورودی مبدأ
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
                    // آیکون دایره آبی مبدأ
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

                // 🟩 ۲. ورودی مقصد
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
                          onChanged: _onSearchTextChanged, // 👈 متد بهینه‌شده با Debounce
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
                    // آیکون مربع سبز مقصد
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

          // نمایش نتایج
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
