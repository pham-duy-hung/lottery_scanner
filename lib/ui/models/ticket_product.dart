enum TicketRegion { mienBac, mienNam, vietlott }

class TicketProduct {
  const TicketProduct({
    required this.id,
    required this.region,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.drawDate,
    this.province,
    this.numbers = const [],
  });

  final String id;
  final TicketRegion region;
  final String title;
  final String subtitle;
  final int price;
  final DateTime drawDate;
  final String? province;
  final List<String> numbers;

  String get regionLabel {
    switch (region) {
      case TicketRegion.mienBac:
        return 'Miền Bắc';
      case TicketRegion.mienNam:
        return 'Miền Nam';
      case TicketRegion.vietlott:
        return 'Vietlott';
    }
  }

  String get numbersDisplay =>
      numbers.isEmpty ? 'Ngẫu nhiên' : numbers.join(' · ');

  TicketProduct copyWith({
    List<String>? numbers,
    int? quantity,
  }) {
    return TicketProduct(
      id: id,
      region: region,
      title: title,
      subtitle: subtitle,
      price: price,
      drawDate: drawDate,
      province: province,
      numbers: numbers ?? this.numbers,
    );
  }
}

class CartItem {
  const CartItem({
    required this.product,
    this.quantity = 1,
  });

  final TicketProduct product;
  final int quantity;

  int get total => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.status,
  });

  final String id;
  final DateTime createdAt;
  final List<CartItem> items;
  final OrderStatus status;

  int get total => items.fold(0, (sum, i) => sum + i.total);
}

enum OrderStatus { pending, paid, completed, cancelled }

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Chờ thanh toán';
      case OrderStatus.paid:
        return 'Đã thanh toán';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }
}
