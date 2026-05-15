import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottery_scanner/ui/models/ticket_product.dart';
import 'package:lottery_scanner/ui/screens/order_success_screen.dart';
import 'package:lottery_scanner/ui/state/cart_state.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';
import 'package:lottery_scanner/ui/widgets/primary_button.dart';
import 'package:lottery_scanner/ui/widgets/price_text.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
    required this.onCartChanged,
    required this.onCheckoutDone,
  });

  final ValueChanged<int> onCartChanged;
  final VoidCallback onCheckoutDone;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    cartState.addListener(_onCartUpdate);
  }

  @override
  void dispose() {
    cartState.removeListener(_onCartUpdate);
    super.dispose();
  }

  void _onCartUpdate() {
    widget.onCartChanged(cartState.itemCount);
    setState(() {});
  }

  void _checkout() {
    if (cartState.items.isEmpty) return;

    final orderId = 'DH${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final total = cartState.total;
    cartState.clear();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderSuccessScreen(
          orderId: orderId,
          total: total,
          onDone: widget.onCheckoutDone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = cartState.items;
    final empty = items.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: empty
          ? _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _CartItemTile(
                        item: item,
                        onMinus: () =>
                            cartState.updateQuantity(index, item.quantity - 1),
                        onPlus: () =>
                            cartState.updateQuantity(index, item.quantity + 1),
                        onRemove: () => cartState.removeAt(index),
                      );
                    },
                  ),
                ),
                _CheckoutBar(total: cartState.total, onCheckout: _checkout),
              ],
            ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Giỏ hàng trống',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm vé từ tab Mua vé hoặc Trang chủ',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onMinus,
    required this.onPlus,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    final date = DateFormat('dd/MM').format(p.drawDate);

    return Dismissible(
      key: ValueKey('${p.id}-${p.numbers.join()}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    p.regionLabel,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              p.subtitle,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            Text(
              'Ngày xổ: $date · ${p.numbersDisplay}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _SmallIconBtn(icon: Icons.remove, onTap: onMinus),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _SmallIconBtn(icon: Icons.add, onTap: onPlus),
                const Spacer(),
                PriceText(amount: item.total),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallIconBtn extends StatelessWidget {
  const _SmallIconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total, required this.onCheckout});

  final int total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tổng cộng', style: TextStyle(color: AppColors.textSecondary)),
              PriceText(amount: total, style: const TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(
              label: 'Thanh toán',
              icon: Icons.payment,
              onPressed: onCheckout,
            ),
          ),
        ],
      ),
    );
  }
}
