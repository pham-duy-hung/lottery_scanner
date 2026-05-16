import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lottery_scanner/data/services/minhngoc_html_parser.dart';
import 'package:lottery_scanner/ui/models/scan_session.dart';

void main() {
  test('parse Miền Bắc from saved HTML sample', () {
    final file = File('tool/mb_sample.html');
    if (!file.existsSync()) return;

    final result = MinhNgocHtmlParser.parseRegionDay(
      file.readAsStringSync(),
      LotteryRegion.mienBac,
      DateTime(2026, 5, 15),
    );

    expect(result, isNotNull);
    expect(result!.draws.single.prizes.first.key, 'giai_db');
    expect(result.draws.single.prizes.first.numbers, ['67294']);
  });

  test('parse Miền Nam from saved HTML sample', () {
    final file = File('tool/mn_sample.html');
    if (!file.existsSync()) return;

    final result = MinhNgocHtmlParser.parseRegionDay(
      file.readAsStringSync(),
      LotteryRegion.mienNam,
      DateTime(2026, 5, 15),
    );

    expect(result, isNotNull);
    expect(result!.draws.length, 3);
    final vinhLong = result.draws.firstWhere((d) => d.province.contains('Vĩnh'));
    expect(vinhLong.prizes.last.numbers, ['216215']);
  });
}
