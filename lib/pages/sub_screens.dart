import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safir_passengers/global/global_var.dart';

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
            getTranslation(context, "trips_history_title") ?? "تاریخچه سفرها",
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
              Tab(text: getTranslation(context, "tab_completed") ?? "تکمیل‌شده"),
              Tab(text: getTranslation(context, "tab_active") ?? "جاری"),
              Tab(text: getTranslation(context, "tab_canceled") ?? "لغوشده"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEmptyState(context, Icons.history, "trips_history_empty_msg", "هنوز سفری انجام نداده‌اید"),
            _buildEmptyState(context, Icons.directions_car_filled_outlined, "no_active_trips", "سفر جاری وجود ندارد"),
            _buildEmptyState(context, Icons.cancel_outlined, "no_canceled_trips", "سفر لغوشده‌ای ندارید"),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String key, String fallback) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            getTranslation(context, key) ?? fallback,
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
          getTranslation(context, "invite_friends_title") ?? "دعوت از دوستان",
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
              getTranslation(context, "invite_friends_main_title") ?? "سفر رایگان هدیه بدهید!",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              getTranslation(context, "invite_friends_subtext") ??
                  "با ارسال کد زیر به دوستانتان، پس از اولین سفر آن‌ها، یک کد تخفیف سفر رایگان دریافت کنید.",
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
                        SnackBar(content: Text(getTranslation(context, "code_copied") ?? "کد در حافظه کپی شد")),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                    label: Text(getTranslation(context, "copy_btn") ?? "کپی", style: const TextStyle(color: Colors.white)),
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
          getTranslation(context, "messages_title") ?? "پیام‌ها و اعلانات",
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
              title: const Text("خوش آمدید!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text("به اپلیکیشن تاکسی سفیر خوش آمدید. سفر خوشی را برایتان آرزومندیم.", style: TextStyle(fontSize: 12)),
              trailing: const Text("امروز", style: TextStyle(fontSize: 10, color: Colors.grey)),
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
          getTranslation(context, "discounts_title") ?? "کدهای تخفیف",
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
                      hintText: getTranslation(context, "enter_discount_code") ?? "کد تخفیف را وارد کنید",
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
                  child: Text(getTranslation(context, "apply_btn") ?? "اعمال", style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text("هیچ کد تخفیف فعالی ندارید", style: TextStyle(color: Colors.grey)),
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
          getTranslation(context, "intercity_title") ?? "سفر بین شهری (ولایات)",
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
                      title: Text(getTranslation(context, "origin") ?? "مبدأ (ولایت فعلی)"),
                      subtitle: const Text("کابل"),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: Text(getTranslation(context, "destination") ?? "مقصد (ولایت مقصد)"),
                      subtitle: const Text("انتخاب کنید..."),
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
                child: Text(getTranslation(context, "search_intercity_driver") ?? "جستجوی موتر ولایتی",
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
          getTranslation(context, "freight_title") ?? "باربری سفیر",
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
          _buildFreightCard(context, Icons.electric_rickshaw, "سه‌چرخ باربری", "تا ۵۰۰ کیلوگرم"),
          _buildFreightCard(context, Icons.local_shipping_outlined, "پیکاپ / کاماز", "تا ۲ تن"),
          _buildFreightCard(context, Icons.fire_truck_outlined, "کامیون سنگین", "بالای ۵ تن"),
          _buildFreightCard(context, Icons.inventory_2_outlined, "بسته‌بندی و کارگر", "خدمات اسباب‌کشی"),
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
          getTranslation(context, "driver_registration_title") ?? "ثبت‌نام راننده",
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
              getTranslation(context, "join_safir_drivers") ?? "به ناوگان سفیر بپیوندید",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              getTranslation(context, "driver_reg_desc") ?? "با ثبت‌نام به‌عنوان راننده در سفیر، در ساعات دلخواه کار کنید و درآمد عالی داشته باشید.",
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
                child: Text(getTranslation(context, "start_driver_registration") ?? "شروع ثبت‌نام راننده",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
