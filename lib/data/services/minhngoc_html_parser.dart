import 'package:html/parser.dart' as html_parser;
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
    final dateToken = _formatDate(date);
    final slice = _extractDateBlock(html, region, dateToken);
    if (slice == null || slice.isEmpty) return null;

    return switch (region) {
      LotteryRegion.mienBac => _parseMienBac(slice, date),
      LotteryRegion.mienNam => _parseMienNamTrung(slice, date, isCentral: false),
      LotteryRegion.mienTrung => _parseMienNamTrung(slice, date, isCentral: true),
    };
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String? _extractDateBlock(String html, LotteryRegion region, String dateToken) {
    final regionKey = switch (region) {
      LotteryRegion.mienBac => 'Miền Bắc',
      LotteryRegion.mienNam => 'Miền Nam',
      LotteryRegion.mienTrung => 'Miền Trung',
    };

    final markers = [
      'KẾT QUẢ XỔ SỐ $regionKey',
      'KET QUA XO SO $regionKey',
    ];

    var searchFrom = 0;
    String? block;
    for (final marker in markers) {
      final idx = html.indexOf(marker, searchFrom);
      if (idx < 0) continue;
      final dateIdx = html.indexOf(dateToken, idx);
      if (dateIdx < 0 || dateIdx - idx > 800) continue;
      final nextRegion = html.indexOf('KẾT QUẢ XỔ SỐ', dateIdx + dateToken.length);
      final end = nextRegion > 0 ? nextRegion : dateIdx + 12000;
      block = html.substring(dateIdx, end.clamp(0, html.length));
      break;
    }
    return block;
  }

  static RegionDayResults _parseMienBac(String block, DateTime date) {
    final doc = html_parser.parse(block);
    final prizes = <LotteryPrize>[];

    final rowLabels = [
      ('giai_db', ['đặc biệt', 'dac biet', 'giải đb', 'giai db']),
      ('giai_1', ['giải nhất', 'giai nhat']),
      ('giai_2', ['giải nhì', 'giai nhi']),
      ('giai_3', ['giải ba']),
      ('giai_4', ['giải tư', 'giai tu']),
      ('giai_5', ['giải năm', 'giai nam']),
      ('giai_6', ['giải sáu', 'giai sau']),
      ('giai_7', ['giải bảy', 'giai bay']),
    ];

    for (final row in doc.querySelectorAll('tr')) {
      final cells = row.querySelectorAll('td, th');
      if (cells.isEmpty) continue;
      final label = _normalize(cells.first.text);
      for (final entry in rowLabels) {
        if (entry.$2.any((k) => label.contains(k))) {
          final nums = <String>[];
          for (var i = 1; i < cells.length; i++) {
            nums.addAll(_extractNumbers(cells[i].text));
          }
          if (nums.isEmpty) {
            nums.addAll(_extractNumbers(row.text));
          }
          if (nums.isNotEmpty) {
            prizes.add(LotteryPrize(key: entry.$1, numbers: nums));
          }
          break;
        }
      }
    }

    if (prizes.isEmpty) {
      prizes.addAll(_parseMienBacFallback(block));
    }

    return RegionDayResults(
      region: LotteryRegion.mienBac,
      date: date,
      draws: [
        ProvinceDraw(province: 'Miền Bắc', prizes: prizes),
      ],
    );
  }

  static List<LotteryPrize> _parseMienBacFallback(String block) {
    final text = html_parser.parse(block).body?.text ?? block;
    final lines = text.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final prizes = <LotteryPrize>[];
    final patterns = [
      ('giai_db', RegExp(r'\b\d{5}\b')),
      ('giai_1', RegExp(r'\b\d{5}\b')),
      ('giai_2', RegExp(r'\b\d{5}\b')),
      ('giai_3', RegExp(r'\b\d{5}\b')),
      ('giai_4', RegExp(r'\b\d{4,5}\b')),
      ('giai_5', RegExp(r'\b\d{4,5}\b')),
      ('giai_6', RegExp(r'\b\d{3,4}\b')),
      ('giai_7', RegExp(r'\b\d{2,3}\b')),
    ];

    var cursor = 0;
    for (final p in patterns) {
      final found = <String>[];
      while (found.length < 8 && cursor < lines.length) {
        final token = lines[cursor];
        cursor++;
        if (p.$2.hasMatch(token) && !_isPrizeLabel(token)) {
          found.add(token);
        }
      }
      if (found.isNotEmpty) {
        prizes.add(LotteryPrize(key: p.$1, numbers: found));
      }
    }
    return prizes;
  }

  static RegionDayResults _parseMienNamTrung(
    String block,
    DateTime date, {
    required bool isCentral,
  }) {
    final doc = html_parser.parse(block);
    final draws = <ProvinceDraw>[];

    final hrefPart = isCentral ? 'xo-so-mien-trung/' : 'xo-so-mien-nam/';
    final prizeOrder = [
      'giai_8',
      'giai_7',
      'giai_6',
      'giai_5',
      'giai_4',
      'giai_3',
      'giai_2',
      'giai_1',
      'giai_db',
    ];

    for (final a in doc.querySelectorAll('a')) {
      final href = a.attributes['href'] ?? '';
      if (!href.contains(hrefPart)) continue;
      if (href.contains('thu-') || href.contains('co-cau')) continue;

      final name = a.text.trim();
      if (name.isEmpty || name.length > 40) continue;
      if (name.toLowerCase().contains('kết quả')) continue;

      final numbers = _extractNumbersAfterElement(a, 120);
      if (numbers.length < 9) continue;

      final prizes = <LotteryPrize>[];
      var idx = 0;
      for (final key in prizeOrder) {
        final count = _expectedCount(key);
        final slice = numbers.skip(idx).take(count).toList();
        if (slice.isEmpty) break;
        prizes.add(LotteryPrize(key: key, numbers: slice));
        idx += slice.length;
      }

      if (prizes.isNotEmpty) {
        draws.add(ProvinceDraw(province: _beautifyProvince(name), prizes: prizes));
      }
    }

    if (draws.isEmpty) {
      draws.addAll(_parseMienNamTrungFallback(block, isCentral: isCentral));
    }

    return RegionDayResults(
      region: isCentral ? LotteryRegion.mienTrung : LotteryRegion.mienNam,
      date: date,
      draws: draws,
    );
  }

  static List<ProvinceDraw> _parseMienNamTrungFallback(String block, {required bool isCentral}) {
    final doc = html_parser.parse(block);
    final text = doc.body?.text ?? '';
    final provincePattern = isCentral
        ? RegExp(
            r'(Gia Lai|Ninh Thuận|Đà Nẵng|Khánh Hòa|Bình Định|Quảng Trị|Quảng Bình|Phú Yên|Huế|Kon Tum|Quảng Nam|Quảng Ngãi|Đắk Lắk|Đắk Nông)',
          )
        : RegExp(
            r'(Vĩnh Long|Bình Dương|Trà Vinh|TP\.?HCM|An Giang|Bến Tre|Cà Mau|Cần Thơ|Đồng Nai|Đồng Tháp|Long An|Sóc Trăng|Tây Ninh|Tiền Giang|Vũng Tàu|Bạc Liêu|Bình Phước|Bình Thuận|Hậu Giang|Kiên Giang|Đà Lạt)',
          );

    final draws = <ProvinceDraw>[];
    final matches = provincePattern.allMatches(text).toList();
    for (var i = 0; i < matches.length; i++) {
      final name = matches[i].group(0)!;
      final start = matches[i].end;
      final end = i + 1 < matches.length ? matches[i + 1].start : start + 400;
      final chunk = text.substring(start, end.clamp(0, text.length));
      final nums = _extractNumbers(chunk);
      if (nums.length < 9) continue;

      final prizes = <LotteryPrize>[
        LotteryPrize(key: 'giai_8', numbers: [nums[0]]),
        LotteryPrize(key: 'giai_7', numbers: [nums[1]]),
        LotteryPrize(key: 'giai_6', numbers: nums.skip(2).take(3).toList()),
        LotteryPrize(key: 'giai_5', numbers: [nums[5]]),
        LotteryPrize(key: 'giai_4', numbers: nums.skip(6).take(7).toList()),
        LotteryPrize(key: 'giai_3', numbers: nums.skip(13).take(2).toList()),
        LotteryPrize(key: 'giai_2', numbers: [nums[15]]),
        LotteryPrize(key: 'giai_1', numbers: [nums[16]]),
        LotteryPrize(key: 'giai_db', numbers: [nums[17]]),
      ];
      draws.add(ProvinceDraw(province: _beautifyProvince(name), prizes: prizes));
    }
    return draws;
  }

  static int _expectedCount(String key) => switch (key) {
        'giai_8' => 1,
        'giai_7' => 1,
        'giai_6' => 3,
        'giai_5' => 1,
        'giai_4' => 7,
        'giai_3' => 2,
        'giai_2' => 1,
        'giai_1' => 1,
        'giai_db' => 1,
        _ => 1,
      };

  static List<String> _extractNumbersAfterElement(dynamic element, int maxChars) {
    final buffer = StringBuffer();
    var node = element;
    for (var depth = 0; depth < 8 && node != null; depth++) {
      var sibling = node.nextElementSibling;
      var steps = 0;
      while (sibling != null && buffer.length < maxChars && steps < 48) {
        buffer.write(' ');
        buffer.write(sibling.text);
        sibling = sibling.nextElementSibling;
        steps++;
      }
      if (buffer.length > 20) break;
      node = node.parent;
    }
    if (buffer.isEmpty) {
      buffer.write(element.parent?.text ?? element.text);
    }
    return _extractNumbers(buffer.toString());
  }

  static List<String> _extractNumbers(String raw) {
    return RegExp(r'\d{2,6}')
        .allMatches(raw)
        .map((m) => m.group(0)!)
        .where((n) => !_isNoiseNumber(n))
        .toList();
  }

  static bool _isNoiseNumber(String n) {
    if (n.length == 4 && int.tryParse(n) != null) {
      final y = int.parse(n);
      if (y >= 2005 && y <= 2035) return true;
    }
    return false;
  }

  static bool _isPrizeLabel(String token) {
    final t = _normalize(token);
    return t.contains('giai') || t.contains('thu') || t.contains('dac biet');
  }

  static String _normalize(String s) =>
      s.toLowerCase().replaceAll('đ', 'd').replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _beautifyProvince(String name) {
    return name
        .replaceAll('Xổ Số', '')
        .replaceAll('Xo So', '')
        .trim();
  }
}
