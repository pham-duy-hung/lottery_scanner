import 'package:flutter/foundation.dart';
import 'package:lottery_scanner/ui/models/ticket_product.dart';

class CartState extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (s, i) => s + i.quantity);

  int get total => _items.fold(0, (s, i) => s + i.total);

  void add(TicketProduct product, {int quantity = 1}) {
    final idx = _items.indexWhere((i) => _sameLine(i.product, product));
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(
        quantity: _items[idx].quantity + quantity,
      );
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateQuantity(int index, int quantity) {
    if (index < 0 || index >= _items.length) return;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void removeAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool _sameLine(TicketProduct a, TicketProduct b) {
    return a.id == b.id &&
        a.numbers.join() == b.numbers.join() &&
        a.province == b.province;
  }
}

final cartState = CartState();
