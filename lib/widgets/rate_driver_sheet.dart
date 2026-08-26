import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:safir_passengers/theme/app_colors.dart';

class RateDriverScreen extends StatefulWidget {
  final String tripId;
  final String driverId;
  final String driverName;
  final String carModel;
  final String plateNumber;
  final String driverPhoto;

  const RateDriverScreen({
    Key? key,
    required this.tripId,
    required this.driverId,
    required this.driverName,
    required this.carModel,
    required this.plateNumber,
    this.driverPhoto = '',
  }) : super(key: key);

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> with SingleTickerProviderStateMixin {
  int _rating = 0;
  bool _isSubmitting = false;
  late TabController _tabController;
  final List<String> _selectedTags = [];
  final TextEditingController _commentController = TextEditingController();

  final List<String> _positiveTags = [
    'rate_tag_punctual',
    'rate_tag_polite',
    'rate_tag_clean_car',
    'rate_tag_safe_driving',
    'rate_tag_good_route',
    'rate_tag_fair_price',
  ];

  final List<String> _negativeTags = [
    'rate_tag_delay',
    'rate_tag_impolite',
    'rate_tag_dirty_car',
    'rate_tag_unsafe_driving',
    'rate_tag_wrong_route',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0 || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      // ۱. ذخیره اطلاعات ثبت نظر در سفر
      await FirebaseDatabase.instance
          .ref()
          .child('All Ride Requests')
          .child(widget.tripId)
          .child('driver_rating')
          .set({
        'rating': _rating,
        'tags': _selectedTags,
        'comment': _commentController.text.trim(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // ۲. به روز رسانی میانگین امتیاز راننده
      if (widget.driverId.isNotEmpty) {
        DatabaseReference driverRef = FirebaseDatabase.instance
            .ref()
            .child('drivers')
            .child(widget.driverId)
            .child('ratings');

        await driverRef.push().set(_rating);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_occurred'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'rate_driver_title'.tr(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDriverCard(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'select_your_rating'.tr(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: index < _rating ? Colors.amber : Colors.grey.shade400,
                          size: 38,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() => _rating = index + 1);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primaryBrand,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primaryBrand,
                    tabs: [
                      Tab(text: 'positive_points'.tr()),
                      Tab(text: 'negative_points'.tr()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTagsGrid(_positiveTags),
                        _buildTagsGrid(_negativeTags),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'comments_label'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'comment_hint'.tr(),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBrand, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_rating == 0 || _isSubmitting) ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrand,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'submit_feedback_btn'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: widget.driverPhoto.isNotEmpty
                ? NetworkImage(widget.driverPhoto)
                : null,
            child: widget.driverPhoto.isEmpty
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.carModel.isNotEmpty ? widget.carModel : 'تویوتا کرولا',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  widget.driverName.isNotEmpty ? widget.driverName : 'راننده سفیر',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.plateNumber.isNotEmpty ? widget.plateNumber : 'کابل 44892 ش',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsGrid(List<String> tags) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tagKey = tags[index];
        final isSelected = _selectedTags.contains(tagKey);

        return InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (isSelected) {
                _selectedTags.remove(tagKey);
              } else {
                _selectedTags.add(tagKey);
              }
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              tagKey.tr(),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.green.shade800 : AppColors.textPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}
