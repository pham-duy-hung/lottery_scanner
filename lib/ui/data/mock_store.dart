import 'package:lottery_scanner/ui/models/ticket_product.dart';

/// Dữ liệu mẫu cho giao diện — thay bằng API sau.
class MockStore {
  MockStore._();

  static List<TicketProduct> featuredProducts(DateTime today) => [
        TicketProduct(
          id: 'mb-${today.millisecondsSinceEpoch}',
          region: TicketRegion.mienBac,
          title: 'XSMB',
          subtitle: 'Xổ số Miền Bắc',
          price: 10000,
          drawDate: today,
        ),
        TicketProduct(
          id: 'mn-hcm',
          region: TicketRegion.mienNam,
          title: 'XSHCM',
          subtitle: 'TP. Hồ Chí Minh',
          price: 10000,
          drawDate: today,
          province: 'TP.HCM',
        ),
        TicketProduct(
          id: 'vl-655',
          region: TicketRegion.vietlott,
          title: 'Mega 6/55',
          subtitle: 'Vietlott',
          price: 10000,
          drawDate: today,
        ),
      ];

  static const hotNumbers = ['08', '16', '23', '38', '47', '56', '68', '79'];

  static List<OrderRecord> sampleOrders() {
    final today = DateTime.now();
    return [
      OrderRecord(
        id: 'DH001248',
        createdAt: today.subtract(const Duration(hours: 2)),
        status: OrderStatus.completed,
        items: [
          CartItem(
            product: TicketProduct(
              id: '1',
              region: TicketRegion.mienBac,
              title: 'XSMB',
              subtitle: 'Miền Bắc',
              price: 10000,
              drawDate: today,
              numbers: ['12', '34', '56'],
            ),
            quantity: 3,
          ),
        ],
      ),
      OrderRecord(
        id: 'DH001247',
        createdAt: today.subtract(const Duration(days: 1)),
        status: OrderStatus.paid,
        items: [
          CartItem(
            product: TicketProduct(
              id: '2',
              region: TicketRegion.mienNam,
              title: 'XSDT',
              subtitle: 'Đồng Tháp',
              price: 10000,
              drawDate: today.subtract(const Duration(days: 1)),
              province: 'Đồng Tháp',
              numbers: ['789'],
            ),
            quantity: 5,
          ),
        ],
      ),
    ];
  }
}
