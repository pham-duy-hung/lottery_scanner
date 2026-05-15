import 'package:flutter/material.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';
import 'package:lottery_scanner/ui/widgets/price_text.dart';
import 'package:lottery_scanner/ui/widgets/primary_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.total,
    required this.onDone,
  });

  final String orderId;
  final int total;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thanh toán thành công!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Mã đơn: $orderId',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              PriceText(
                amount: total,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vé đã được ghi nhận. Bạn có thể in vé cho khách.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'In vé',
                icon: Icons.print,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng in vé — sắp ra mắt')),
                  );
                },
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Về đơn hàng',
                outlined: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  onDone();
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('Tiếp tục bán vé'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
