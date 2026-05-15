import 'package:flutter_test/flutter_test.dart';
import 'package:lottery_scanner/data/services/minhngoc_html_parser.dart';
import 'package:lottery_scanner/ui/models/scan_session.dart';

void main() {
  test('parse Miền Nam block with three provinces', () {
    const html = '''
KẾT QUẢ XỔ SỐ Miền Nam
15/05/2026
<a href="https://www.minhngoc.net.vn/xo-so-mien-nam/vinh-long.html">Vĩnh Long</a>
39 371 1995 7830 5033 7433 67708 94928 41243 75585 05343 91528 40795 38479 18924 02531 55107 660519
<a href="https://www.minhngoc.net.vn/xo-so-mien-nam/binh-duong.html">Bình Dương</a>
49 256 0425 9452 2233 7639 20490 77179 06596 97690 73992 39322 12345 67890 11111 22222 333333
''';

    final result = MinhNgocHtmlParser.parseRegionDay(
      html,
      LotteryRegion.mienNam,
      DateTime(2026, 5, 15),
    );

    expect(result, isNotNull);
    expect(result!.draws.length, greaterThanOrEqualTo(2));
    expect(result.draws.first.province, contains('Vĩnh'));
    final db = result.draws.first.prizes.last;
    expect(db.key, 'giai_db');
    expect(db.numbers.first.length, greaterThanOrEqualTo(5));
  });
}
