import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final Color safirBrandColor = const Color(0xFF145A41);
final Color safirAccentColor = const Color(0xFF22C55E);

// ----------------------------------------------------
// ۱. صفحه تاریخچه سفرها (با تب‌بندی مدرن)
// ----------------------------------------------------
class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            "trips_history_title".tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: safirBrandColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "tab_completed".tr()),
              Tab(text: "tab_active".tr()),
              Tab(text: "tab_canceled".tr()),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEmptyState(context, Icons.history, "trips_history_empty_msg"),
            _buildEmptyState(context, Icons.directions_car_filled_outlined, "no_active_trips"),
            _buildEmptyState(context, Icons.cancel_outlined, "no_canceled_trips"),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String translationKey) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            translationKey.tr(),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// ۲. صفحه دعوت از دوستان (با قابلیت کپی کد)
// ----------------------------------------------------
class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String referralCode = "SAFIR-8820";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "invite_friends_title".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: safirBrandColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: safirBrandColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.card_giftcard_rounded, size: 80, color: safirBrandColor),
            ),
            const SizedBox(height: 24),
            Text(
              "invite_friends_main_title".tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              "invite_friends_subtext".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: safirBrandColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    referralCode,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: safirBrandColor, letterSpacing: 2),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: safirBrandColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: referralCode));
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("code_copied".tr())),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                    label: Text("copy_btn".tr(), style: const TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// ۳. صفحه پیام‌ها و صندوق اعلانات
// ----------------------------------------------------
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "messages_title".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: safirBrandColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: safirBrandColor.withOpacity(0.1),
                child: Icon(Icons.mark_email_read_outlined, color: safirBrandColor),
              ),
              title: Text("welcome_title".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text("welcome_msg".tr(), style: const TextStyle(fontSize: 12)),
              trailing: Text("today_label".tr(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// ۴. صفحه کدهای تخفیف (ورودی و لیست)
// ----------------------------------------------------
class DiscountCodeScreen extends StatelessWidget {
  const DiscountCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "discounts_title".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: safirBrandColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      hintText: "enter_discount_code".tr(),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: safirBrandColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                  },
                  child: Text("apply_btn".tr(), style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text("no_active_discounts".tr(), style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// ۵. صفحه سفر بین شهری (ولایات)
// ----------------------------------------------------
class BinShahriScreen extends StatelessWidget {
  const BinShahriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "intercity_title".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: safirBrandColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.my_location, color: Colors.blue),
                      title: Text("origin".tr()),
                      subtitle: Text("kabul_city".tr()),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: Text("destination".tr()),
                      subtitle: Text("select_destination".tr()),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: safirBrandColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                child: Text("search_intercity_driver".tr(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// ۶. صفحه باربری سفیر
// ----------------------------------------------------
class BarbariScreen extends StatelessWidget {
  const BarbariScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "freight_title".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: safirBrandColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildFreightCard(context, Icons.electric_rickshaw, "rickshaw_freight".tr(), "rickshaw_weight".tr()),
          _buildFreightCard(context, Icons.local_shipping_outlined, "pickup_freight".tr(), "pickup_weight".tr()),
          _buildFreightCard(context, Icons.fire_truck_outlined, "truck_freight".tr(), "truck_weight".tr()),
          _buildFreightCard(context, Icons.inventory_2_outlined, "packing_services".tr(), "moving_help".tr()),
        ],
      ),
    );
  }

  Widget _buildFreightCard(BuildContext context, IconData icon, String title, String subtitle) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: safirBrandColor),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// ۷. صفحه ثبت‌نام رانندگان
// ----------------------------------------------------
class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "driver_registration_title".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: safirBrandColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.time_to_leave_rounded, size: 90, color: safirBrandColor),
            const SizedBox(height: 20),
            Text(
              "join_safir_drivers".tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "driver_reg_desc".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: safirBrandColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                child: Text("start_driver_registration".tr(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
