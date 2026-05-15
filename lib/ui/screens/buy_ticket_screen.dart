import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottery_scanner/ui/models/ticket_product.dart';
import 'package:lottery_scanner/ui/state/cart_state.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';
import 'package:lottery_scanner/ui/widgets/primary_button.dart';
import 'package:lottery_scanner/ui/widgets/price_text.dart';

class BuyTicketScreen extends StatefulWidget {
  const BuyTicketScreen({
    super.key,
    required this.onAddedToCart,
    required this.cartCount,
  });

  final ValueChanged<int> onAddedToCart;
  final int cartCount;

  @override
  State<BuyTicketScreen> createState() => _BuyTicketScreenState();
}

class _BuyTicketScreenState extends State<BuyTicketScreen> {
  TicketRegion _region = TicketRegion.mienBac;
  DateTime _drawDate = DateTime.now();
  String? _province;
  final _numberController = TextEditingController();
  int _quantity = 1;

  static const _provinces = [
    'TP.HCM', 'Đồng Tháp', 'Cà Mau', 'Bến Tre', 'Vũng Tàu',
    'Bạc Liêu', 'Đồng Nai', 'Cần Thơ', 'Sóc Trăng', 'An Giang',
  ];

  static const _unitPrice = 10000;

  int get _lineTotal => _unitPrice * _quantity;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  String get _regionTitle {
    switch (_region) {
      case TicketRegion.mienBac:
        return 'XSMB — Miền Bắc';
      case TicketRegion.mienNam:
        return 'XSMN — Miền Nam';
      case TicketRegion.vietlott:
        return 'Vietlott Mega 6/55';
    }
  }

  void _randomNumber() {
    final r = DateTime.now().millisecondsSinceEpoch % 1000000;
    _numberController.text = r.toString().padLeft(6, '0');
    setState(() {});
  }

  void _addToCart() {
    final raw = _numberController.text.trim();
    final numbers = raw.isEmpty
        ? <String>[]
        : raw.split(RegExp(r'[\s,;.]+')).where((s) => s.isNotEmpty).toList();

    if (_region == TicketRegion.mienNam && _province == null) {
      _showError('Vui lòng chọn tỉnh');
      return;
    }

    final product = TicketProduct(
      id: '${_region.name}-${DateTime.now().millisecondsSinceEpoch}',
      region: _region,
      title: _region == TicketRegion.vietlott ? 'Mega 6/55' : 'XS',
      subtitle: _regionTitle,
      price: _unitPrice,
      drawDate: _drawDate,
      province: _province,
      numbers: numbers,
    );

    cartState.add(product, quantity: _quantity);
    widget.onAddedToCart(cartState.itemCount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm $_quantity vé vào giỏ'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Xem giỏ',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.primaryDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mua vé'),
        actions: [
          if (widget.cartCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                avatar: const Icon(Icons.shopping_cart, size: 18),
                label: Text('${widget.cartCount}'),
                backgroundColor: AppColors.accent,
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Loại vé',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SegmentedButton<TicketRegion>(
            segments: const [
              ButtonSegment(
                value: TicketRegion.mienBac,
                label: Text('Miền Bắc'),
                icon: Icon(Icons.location_city, size: 18),
              ),
              ButtonSegment(
                value: TicketRegion.mienNam,
                label: Text('Miền Nam'),
                icon: Icon(Icons.map, size: 18),
              ),
              ButtonSegment(
                value: TicketRegion.vietlott,
                label: Text('Vietlott'),
                icon: Icon(Icons.star, size: 18),
              ),
            ],
            selected: {_region},
            onSelectionChanged: (s) => setState(() {
              _region = s.first;
              if (_region != TicketRegion.mienNam) _province = null;
            }),
          ),
          const SizedBox(height: 24),
          _FieldLabel('Ngày xổ'),
          const SizedBox(height: 8),
          _PickerTile(
            icon: Icons.calendar_today,
            value: DateFormat('dd/MM/yyyy').format(_drawDate),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _drawDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 14)),
                locale: const Locale('vi', 'VN'),
              );
              if (d != null) setState(() => _drawDate = d);
            },
          ),
          if (_region == TicketRegion.mienNam) ...[
            const SizedBox(height: 16),
            _FieldLabel('Tỉnh / Thành'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _province,
              hint: const Text('Chọn tỉnh'),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.place, color: AppColors.primary),
              ),
              items: _provinces
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _province = v),
            ),
          ],
          const SizedBox(height: 24),
          _FieldLabel('Dãy số (để trống = ngẫu nhiên)'),
          const SizedBox(height: 8),
          TextField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            maxLength: 20,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'VD: 123456 hoặc 12 34 56',
              counterText: '',
              suffixIcon: IconButton(
                icon: const Icon(Icons.casino_outlined),
                tooltip: 'Số ngẫu nhiên',
                onPressed: _randomNumber,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _FieldLabel('Số lượng vé'),
          const SizedBox(height: 12),
          Row(
            children: [
              _QtyButton(
                icon: Icons.remove,
                onTap: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _QtyButton(
                icon: Icons.add,
                onTap: () => setState(() => _quantity++),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Thành tiền',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  PriceText(amount: _lineTotal, style: const TextStyle(fontSize: 22)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Thêm vào giỏ — ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(_lineTotal)}',
            icon: Icons.add_shopping_cart,
            onPressed: _addToCart,
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(value, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap != null ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: onTap != null ? AppColors.primary : Colors.grey,
          ),
        ),
      ),
    );
  }
}
