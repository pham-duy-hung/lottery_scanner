import 'package:lottery_scanner/data/services/lottery_data_service.dart';
import 'package:lottery_scanner/ui/models/scan_session.dart';

Future<void> main() async {
  final service = LotteryDataService();
  final mb = await service.fetchRegionDay(
    region: LotteryRegion.mienBac,
    date: DateTime(2026, 5, 15),
  );
  print('MB: ${mb.data.draws.first.prizes.map((p) => '${p.key}=${p.numbers}').join('; ')}');

  final mn = await service.fetchRegionDay(
    region: LotteryRegion.mienNam,
    date: DateTime(2026, 5, 15),
  );
  print('MN provinces: ${mn.data.draws.map((d) => d.province).join(', ')}');
  for (final d in mn.data.draws) {
    final dbNums = d.prizes
        .where((p) => p.key == 'giai_db')
        .map((p) => p.numbers)
        .expand((n) => n)
        .toList();
    print('  ${d.province} DB=$dbNums');
  }
}
