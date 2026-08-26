import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:safir_passengers/global/global_var.dart';

class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {
  final DatabaseReference _tripRequestsRef =
      FirebaseDatabase.instance.ref().child("tripRequest");

  // پالت رنگی مرجع پروژه
  final Color safirBrandColor = const Color(0xFF145A41);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          getTranslation(context, "trips_history_title") ?? "تاریخچه سفرها",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _tripRequestsRef.onValue,
        builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshotData) {
          // ۱. خطای دریافت اطلاعات
          if (snapshotData.hasError) {
            return Center(
              child: Text(
                getTranslation(context, "data_fetch_error") ?? "خطا در دریافت اطلاعات",
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
            );
          }

          // ۲. حالت در حال بارگذاری (Loading)
          if (snapshotData.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(safirBrandColor),
              ),
            );
          }

          // ۳. اگر هیچ داده‌ای کلاً وجود نداشته باشد
          if (!snapshotData.hasData || snapshotData.data!.snapshot.value == null) {
            return _buildEmptyState(context);
          }

          final snapshotValue = snapshotData.data!.snapshot.value;

          if (snapshotValue is Map) {
            final Map<String, dynamic> dataTrips = snapshotValue.cast<String, dynamic>();
            final List<Map<String, dynamic>> tripsList = [];

            // فیلتر کردن سفرهای خاتمه یافته مربوط به کاربر فعلی
            dataTrips.forEach((key, value) {
              if (value is Map) {
                final tripMap = value.cast<String, dynamic>();
                if (tripMap["userID"] == currentUserId && tripMap["status"] == "ended") {
                  tripsList.add({"key": key, ...tripMap});
                }
              }
            });

            // اگر هیچ سفری با شرایط فیلتر شده پیدا نشد
            if (tripsList.isEmpty) {
              return _buildEmptyState(context);
            }

            // مرتب‌سازی برای نمایش جدیدترین سفرها در ابتدای لیست
            final reverseTripsList = tripsList.reversed.toList();

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: reverseTripsList.length,
              itemBuilder: (context, index) {
                final trip = reverseTripsList[index];
                final fareAmount = trip["fareAmount"] ?? "0";
                final currencySymbol = getTranslation(context, "currency_afghani") ?? "افغانی";
                final driverName = trip["driverName"] ?? trip["driverDetails"]?["name"];
                final tripDate = trip["publishDateTime"] ?? trip["time"] ?? "";

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.withOpacity(0.15)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // بخش بالایی: وضعیت، تاریخ و کرایه
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: safirBrandColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    getTranslation(context, "trip_status_completed") ?? "تکمیل شده",
                                    style: TextStyle(
                                      color: safirBrandColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (tripDate.toString().isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    tripDate.toString(),
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              "$fareAmount $currencySymbol",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: safirBrandColor,
                              ),
                            ),
                          ],
                        ),
                        
                        const Divider(height: 24, thickness: 0.8),

                        // مبدأ سفر
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(Icons.circle, color: safirBrandColor, size: 12),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                trip["pickUpAddress"]?.toString() ?? "-",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
                              ),
                            ),
                          ],
                        ),

                        // خط رابط بین مبدأ و مقصد
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
                          width: 2,
                          height: 16,
                          color: Colors.grey.withOpacity(0.3),
                        ),

                        // مقصد سفر
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(Icons.location_on, color: Colors.redAccent, size: 15),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                trip["dropOffAddress"]?.toString() ?? "-",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
                              ),
                            ),
                          ],
                        ),

                        // در صورت وجود اطلاعات راننده
                        if (driverName != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                "${getTranslation(context, "driver_label") ?? "راننده"}: $driverName",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                getTranslation(context, "invalid_data_format") ?? "فرمت اطلاعات نامعتبر است",
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }
        },
      ),
    );
  }

  // ویجت اختصاصی حالت خالی (Empty State)
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_toggle_off_round,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            getTranslation(context, "no_trips_found") ?? "هیچ سفری ثبت نشده است",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}