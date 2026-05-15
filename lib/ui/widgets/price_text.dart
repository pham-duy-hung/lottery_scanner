import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';

class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.amount,
    this.style,
    this.color,
  });

  final int amount;
  final TextStyle? style;
  final Color? color;

  static final _formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatter.format(amount),
      style: style ??
          TextStyle(
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.primary,
          ),
    );
  }
}
