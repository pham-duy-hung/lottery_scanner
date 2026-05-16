import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';
import 'package:lottery_scanner/ui/models/lottery_draw.dart';
import 'package:lottery_scanner/ui/models/scan_session.dart';

/// Parse HTML từ minhngoc.net.vn thành [RegionDayResults].
class MinhNgocHtmlParser {
  MinhNgocHtmlParser._();

  static RegionDayResults? parseRegionDay(
    String html,
    LotteryRegion region,
    DateTime date,
  ) {
    final dateSlash = _formatDate(date);
    final dateDash = DateFormat('dd-MM-yyyy').format(date);
    final doc = html_parser.parse(html);
    final box = _findResultBox(doc, region, dateSlash, dateDash);
    if (box == null) return null;

    return switch (region) {
      LotteryRegion.mienBac => _parseMienBacBox(box, date),
      LotteryRegion.mienNam => _parseMienNamTrungBox(box, date, isCentral: false),
      LotteryRegion.mienTrung => _parseMienNamTrungBox(box, date, isCentral: true),
    };
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static Element? _findResultBox(
    Document doc,
    LotteryRegion region,
    String dateSlash,
    String dateDash,
  ) {
    final regionToken = switch (region) {
      LotteryRegion.mienBac => 'Miền Bắc',
      LotteryRegion.mienNam => 'Miền Nam',
      LotteryRegion.mienTrung => 'Miền Trung',
    };

    for (final box in doc.querySelectorAll('.box_kqxs')) {
      final title = box.querySelector('.title');
      if (title == null) continue;
      final text = title.text;
      final inner = title.innerHtml;
      if (!text.contains(regionToken)) continue;
      if (!text.contains(dateSlash) && !inner.contains(dateDash)) continue;
      return box;
    }
    return null;
  }

  static RegionDayResults _parseMienBacBox(Element box, DateTime date) {
    final table = box.querySelector('table.bkqtinhmienbac');
    final prizes = table != null ? _parseMbPrizeTable(table) : <LotteryPrize>[];

    return RegionDayResults(
      region: LotteryRegion.mienBac,
      date: date,
      draws: [
        ProvinceDraw(province: 'Miền Bắc', prizes: prizes),
      ],
    );
  }

  static List<LotteryPrize> _parseMbPrizeTable(Element table) {
    final prizes = <LotteryPrize>[];
    for (final row in table.querySelectorAll('tr')) {
      final tds = row.querySelectorAll('td');
      if (tds.length < 2) continue;
      final key = _mbKeyFromLabelClass(tds.first.attributes['class'] ?? '');
      if (key == null) continue;
      final nums = _numbersFromCell(tds[1]);
      if (nums.isNotEmpty) {
        prizes.add(LotteryPrize(key: key, numbers: nums));
      }
    }
    return prizes;
  }

  static String? _mbKeyFromLabelClass(String cls) {
    if (cls.contains('giaidbl')) return 'giai_db';
    if (cls.contains('giai1l')) return 'giai_1';
    if (cls.contains('giai2l')) return 'giai_2';
    if (cls.contains('giai3l')) return 'giai_3';
    if (cls.contains('giai4l')) return 'giai_4';
    if (cls.contains('giai5l')) return 'giai_5';
    if (cls.contains('giai6l')) return 'giai_6';
    if (cls.contains('giai7l')) return 'giai_7';
    return null;
  }

  static RegionDayResults _parseMienNamTrungBox(
    Element box,
    DateTime date, {
    required bool isCentral,
  }) {
    final draws = <ProvinceDraw>[];
    for (final table in box.querySelectorAll('table.rightcl')) {
      final provinceLink = table.querySelector('td.tinh a');
      if (provinceLink == null) continue;
      final province = _beautifyProvince(provinceLink.text.trim());
      final prizes = _parseMnMtProvinceTable(table);
      if (prizes.isNotEmpty) {
        draws.add(ProvinceDraw(province: province, prizes: prizes));
      }
    }

    return RegionDayResults(
      region: isCentral ? LotteryRegion.mienTrung : LotteryRegion.mienNam,
      date: date,
      draws: draws,
    );
  }

  static const _mnPrizeClasses = [
    ('giai8', 'giai_8'),
    ('giai7', 'giai_7'),
    ('giai6', 'giai_6'),
    ('giai5', 'giai_5'),
    ('giai4', 'giai_4'),
    ('giai3', 'giai_3'),
    ('giai2', 'giai_2'),
    ('giai1', 'giai_1'),
    ('giaidb', 'giai_db'),
  ];

  static List<LotteryPrize> _parseMnMtProvinceTable(Element table) {
    final prizes = <LotteryPrize>[];
    for (final entry in _mnPrizeClasses) {
      final td = table.querySelector('td.${entry.$1}');
      if (td == null) continue;
      final nums = _numbersFromCell(td);
      if (nums.isNotEmpty) {
        prizes.add(LotteryPrize(key: entry.$2, numbers: nums));
      }
    }
    return prizes;
  }

  static List<String> _numbersFromCell(Element cell) {
    final nums = <String>[];
    for (final div in cell.querySelectorAll('div')) {
      final t = div.text.trim();
      if (RegExp(r'^\d{2,6}$').hasMatch(t)) nums.add(t);
    }
    return nums;
  }

  static String _beautifyProvince(String name) =>
      name.replaceAll('Xổ Số', '').replaceAll('Xo So', '').trim();
}
