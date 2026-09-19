import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_colors.dart';
import '../widgets/animated_menus.dart';
import '../widgets/cargo_sheets.dart';
import 'map_screen.dart';

class CargoScreen extends StatefulWidget {
  const CargoScreen({super.key});

  @override
  State<CargoScreen> createState() => _CargoScreenState();
}

class _CargoScreenState extends State<CargoScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  String _originAddress = '';
  String _destinationAddress = '';
  double _distanceInKm = 5.0; // مسافت پیش‌فرض (در صورت دریافت از نقشه مقدار واقعی ست می‌شود)

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_originAddress.isEmpty) {
      _originAddress = 'cargo.fetching_origin'.tr();
      _destinationAddress = 'cargo.fetching_destination'.tr();
    }
  }

  // فیلدهای فرستنده
  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();
  final TextEditingController _senderPlaqueController = TextEditingController();
  final TextEditingController _senderUnitController = TextEditingController();
  final TextEditingController _senderDescController = TextEditingController();

  // فیلدهای گیرنده
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _receiverPlaqueController = TextEditingController();
  final TextEditingController _receiverUnitController = TextEditingController();
  final TextEditingController _receiverDescController = TextEditingController();

  String _selectedCargoType = 'cargo.type_other'.tr();
  String _insuranceAmount = 'cargo.insurance_50k'.tr();
  String _paymentPayer = 'cargo.sender'.tr();

  // نوع وسیله نقلیه و کرایه
  String _selectedVehicle = 'suzuki';
  double _calculatedFare = 850.0;

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _senderPlaqueController.dispose();
    _senderUnitController.dispose();
    _senderDescController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _receiverPlaqueController.dispose();
    _receiverUnitController.dispose();
    _receiverDescController.dispose();
    super.dispose();
  }

  // 🚀 انتخاب مبدأ و مقصد از نقشه
  Future<void> _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SafirMapScreen(
          serviceType: 'cargo',
          isPickerOnly: true,
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        if (result['origin'] != null) {
          _originAddress = result['origin'].placeName ?? _originAddress;
        }
        if (result['destination'] != null) {
          _destinationAddress = result['destination'].placeName ?? _destinationAddress;
        }
        if (result['distance'] != null) {
          _distanceInKm = (result['distance'] as num).toDouble();
        }
        // محاسبه مجدد کرایه پس از تغییر مسافت
        _updateFare(_selectedVehicle);
      });
    }
  }

  // 📐 محاسبه و به‌روزرسانی قیمت بر اساس نوع خودرو
  void _updateFare(String vehicleType) {
    setState(() {
      _selectedVehicle = vehicleType;
      _calculatedFare = CargoSheets.calculateFareForVehicle(vehicleType, _distanceInKm);
    });
  }

  // 🔥 متد ثبت سفارش در فایربیس
  Future<void> _submitOrderToFirebase() async {
    setState(() => _isLoading = true);

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('cargo_orders').add({
        'userId': user?.uid ?? 'anonymous',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'originAddress': _originAddress,
        'destinationAddress': _destinationAddress,
        'vehicleType': _selectedVehicle,
        'calculatedFare': _calculatedFare,
        'paymentPayer': _paymentPayer,
        'cargoType': _selectedCargoType,
        'insuranceAmount': _insuranceAmount,
        'senderDetails': {
          'name': _senderNameController.text.trim(),
          'phone': _senderPhoneController.text.trim(),
          'plaque': _senderPlaqueController.text.trim(),
          'unit': _senderUnitController.text.trim(),
          'description': _senderDescController.text.trim(),
        },
        'receiverDetails': {
          'name': _receiverNameController.text.trim(),
          'phone': _receiverPhoneController.text.trim(),
          'plaque': _receiverPlaqueController.text.trim(),
          'unit': _receiverUnitController.text.trim(),
          'description': _receiverDescController.text.trim(),
        },
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('cargo.success_msg'.tr()),
          backgroundColor: AppColors.primaryBrand,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در ثبت سفارش: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // نمایش BottomSheetها بر اساس مرحله
  void _openSenderBottomSheet() {
    CargoSheets.showSenderDialog(
      context: context,
      nameController: _senderNameController,
      phoneController: _senderPhoneController,
      addressController: TextEditingController(text: _originAddress),
      unitController: _senderUnitController,
      floorController: _senderPlaqueController,
      noteController: _senderDescController,
      onConfirm: () {
        setState(() => _currentStep = 2);
        _openReceiverBottomSheet();
      },
    );
  }

  void _openReceiverBottomSheet() {
    CargoSheets.showReceiverDialog(
      context: context,
      nameController: _receiverNameController,
      phoneController: _receiverPhoneController,
      addressController: TextEditingController(text: _destinationAddress),
      unitController: _receiverUnitController,
      floorController: _receiverPlaqueController,
      noteController: _receiverDescController,
      selectedPackageType: _selectedCargoType,
      onPackageTypeChanged: (val) {
        if (val != null) setState(() => _selectedCargoType = val);
      },
      selectedInsurance: _insuranceAmount,
      onInsuranceChanged: (val) {
        if (val != null) setState(() => _insuranceAmount = val);
      },
      onConfirm: () {
        setState(() => _currentStep = 3);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'cargo.title'.tr(),
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
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBrand))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildAddressCard(),
                      const SizedBox(height: 16),

                      if (_currentStep == 0) ...[
                        _buildVehicleSelectionCard(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryButton,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              setState(() => _currentStep = 1);
                              _openSenderBottomSheet();
                            },
                            child: Text(
                              'cargo.continue_details'.tr(),
                              style: const TextStyle(color: AppColors.buttonText, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

          // شیت خلاصه سفارش در مرحله نهایی
          if (_currentStep == 3)
            CargoSheets.buildCargoSummarySheet(
              context: context,
              fareAmount: _calculatedFare,
              distanceInKm: _distanceInKm,
              selectedVehicleType: _selectedVehicle,
              onVehicleSelected: (vehicleId) {
                _updateFare(vehicleId);
              },
              paymentPayer: _paymentPayer,
              onPayerChanged: (val) {
                setState(() => _paymentPayer = val);
              },
              onRequestTrip: _submitOrderToFirebase,
              isLoading: _isLoading,
            ),
        ],
      ),
    );
  }

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
            leading: const Icon(Icons.circle, color: Color(0xFF2563EB), size: 16),
            title: Text('cargo.origin'.tr(), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            subtitle: Text(_originAddress, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            trailing: const Icon(Icons.edit, size: 18, color: AppColors.primaryBrand),
            onTap: _openMapPicker,
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on, color: AppColors.primaryButton, size: 22),
            title: Text('cargo.destination'.tr(), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            subtitle: Text(_destinationAddress, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            trailing: const Icon(Icons.edit, size: 18, color: AppColors.primaryBrand),
            onTap: _openMapPicker,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('cargo.select_vehicle'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildVehicleTypeCard('zaranj', 'cargo.vehicle_zaranj'.tr(), Icons.electric_rickshaw),
                _buildVehicleTypeCard('suzuki', 'cargo.vehicle_suzuki'.tr(), Icons.local_shipping_outlined),
                _buildVehicleTypeCard('mazda', 'cargo.vehicle_mazda'.tr(), Icons.fire_truck_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeCard(String type, String title, IconData icon) {
    bool isSelected = _selectedVehicle == type;
    return GestureDetector(
      onTap: () => _updateFare(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBrand.withOpacity(0.08) : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryBrand : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: isSelected ? AppColors.primaryBrand : AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryBrand : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
