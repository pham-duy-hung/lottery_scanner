import 'package:flutter/material.dart';
import 'package:lottery_scanner/ui/screens/buy_ticket_screen.dart';
import 'package:lottery_scanner/ui/screens/cart_screen.dart';
import 'package:lottery_scanner/ui/screens/home_screen.dart';
import 'package:lottery_scanner/ui/screens/orders_screen.dart';
import 'package:lottery_scanner/ui/state/cart_state.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    cartState.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    cartState.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final count = cartState.itemCount;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            cartCount: count,
            onBuyTap: () => setState(() => _index = 1),
            onCartTap: () => setState(() => _index = 2),
            onCartCountChanged: (_) => setState(() {}),
          ),
          BuyTicketScreen(
            cartCount: count,
            onAddedToCart: (_) => setState(() => _index = 2),
          ),
          CartScreen(
            onCartChanged: (_) => setState(() {}),
            onCheckoutDone: () => setState(() => _index = 3),
          ),
          const OrdersScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accent.withValues(alpha: 0.5),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Trang chủ',
          ),
          const NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: 'Mua vé',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Giỏ hàng',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
        ],
      ),
    );
  }
}
