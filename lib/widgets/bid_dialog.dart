import 'package:flutter/material.dart';
import '../globle/global_var.dart';
import '../theme/app_colors.dart'; // حتماً آدرس فایل رنگ را اصلاح کنید

class BidDialogWidget extends StatefulWidget {
  final double? initialFareAmount;
  final ValueChanged<double?> onBidAmountChanged;

  const BidDialogWidget({
    super.key,
    required this.initialFareAmount,
    required this.onBidAmountChanged,
  });

  @override
  _BidDialogWidgetState createState() => _BidDialogWidgetState();
}

class _BidDialogWidgetState extends State<BidDialogWidget> {
  final TextEditingController bidController = TextEditingController();
  String? _enteredBidAmount;

  @override
  void initState() {
    super.initState();
    bidController.text = widget.initialFareAmount?.toStringAsFixed(0) ?? '';
    _enteredBidAmount = widget.initialFareAmount?.toStringAsFixed(0);
  }

  void _showBidDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                const Icon(Icons.local_offer_outlined, color: AppColors.primaryBrand),
                const SizedBox(width: 8),
                Text(
                  getTranslation('new_bid_offer') ?? 'پیشنهاد قیمت جدید',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslation('enter_desired_price') ?? 'قیمت مد نظر خود را وارد کنید:',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: bidController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    suffixText: getTranslation('currency_afghani') ?? 'افغانی',
                    suffixStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                    filled: true,
                    fillColor: AppColors.cardLightBg, // پس‌زمینه روشن کارت‌ها (#EAF6F1)
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryBrand, width: 1.5),
                    ),
                    errorText: _validateBidAmount(),
                    helperText:
                        '${getTranslation('allowed_range') ?? 'محدوده مجاز'}: ${getTranslation('from') ?? 'از'} ${_calculateLowerLimit().toStringAsFixed(0)} ${getTranslation('to') ?? 'تا'} ${_calculateUpperLimit().toStringAsFixed(0)} ${getTranslation('currency_afghani') ?? 'افغانی'}',
                    helperStyle: const TextStyle(color: Colors.black38, fontSize: 11),
                  ),
                  style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                  onChanged: (value) {
                    setState(() {
                      _enteredBidAmount = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  getTranslation('cancel') ?? 'انصراف',
                  style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_validateBidAmount() == null) {
                    double? bidAmount = double.tryParse(bidController.text);
                    widget.onBidAmountChanged(bidAmount);
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton, // دکمه اصلی (#1B7A57)
                  foregroundColor: AppColors.buttonPressed, // حالت لمس (#0F4A35)
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  getTranslation('confirm_price') ?? "تایید قیمت",
                  style: const TextStyle(color: AppColors.buttonText, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _validateBidAmount() {
    if (bidController.text.isEmpty) {
      return getTranslation('please_enter_amount') ?? 'لطفاً مبلغی وارد کنید';
    }
    double bid = double.tryParse(bidController.text) ?? 0.0;

    double lowerLimit = _calculateLowerLimit();
    double upperLimit = _calculateUpperLimit();

    if (bid < lowerLimit || bid > upperLimit) {
      return '${getTranslation('amount_must_be_between') ?? 'مبلغ باید بین'} ${_calculateLowerLimit().toStringAsFixed(0)} ${getTranslation('and') ?? 'و'} ${_calculateUpperLimit().toStringAsFixed(0)} ${getTranslation('be') ?? 'باشد'}';
    }
    return null;
  }

  double _calculateLowerLimit() {
    return (widget.initialFareAmount ?? 0.0) * 0.90;
  }

  double _calculateUpperLimit() {
    return (widget.initialFareAmount ?? 0.0) * 1.20;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 0,
        color: AppColors.cardLightBg, // پس‌زمینه کارت (#EAF6F1)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.primaryBrand.withOpacity(0.15)),
        ),
        child: InkWell(
          onTap: () => _showBidDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, color: AppColors.primaryBrand, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      _enteredBidAmount == null || _validateBidAmount() != null
                          ? (getTranslation('set_bid_offer') ?? "تعیین قیمت پیشنهادی")
                          : '${getTranslation('your_price') ?? 'قیمت شما'}: $_enteredBidAmount ${getTranslation('currency_afghani') ?? 'افغانی'}',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
                Icon(Icons.chevron_left, color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
