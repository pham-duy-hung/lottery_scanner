import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottery_scanner/data/services/minhngoc_html_parser.dart';
import 'package:lottery_scanner/ui/models/lottery_draw.dart';
import 'package:lottery_scanner/ui/models/scan_session.dart';

/// Kết quả fetch từ minhngoc.net.vn.
class LotteryFetchResult {
  const LotteryFetchResult({
    required this.data,
    required this.sourceUrl,
    this.fetchedAt,
  });

  final RegionDayResults data;
  final String sourceUrl;
  final DateTime? fetchedAt;
}

class LotteryDataService {
  LotteryDataService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = 'https://www.minhngoc.net.vn';

  static const _headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml',
    'Accept-Language': 'vi-VN,vi;q=0.9,en;q=0.8',
  };

  /// Lấy kết quả cả miền theo ngày: `dd-MM-yyyy` trong URL.
  Future<LotteryFetchResult> fetchRegionDay({
    required LotteryRegion region,
    required DateTime date,
  }) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final url = _regionDayUrl(region, normalized);
    final html = await _getHtml(url);
    final parsed = MinhNgocHtmlParser.parseRegionDay(html, region, normalized);

    if (parsed == null || parsed.draws.isEmpty) {
      throw LotteryDataException(
        'Không parse được dữ liệu từ Minh Ngọc cho ngày ${_formatDate(normalized)}.',
      );
    }

    return LotteryFetchResult(
      data: parsed,
      sourceUrl: url,
      fetchedAt: DateTime.now(),
    );
  }

  /// Lấy kết quả một tỉnh (Miền Nam / Trung).
  Future<LotteryFetchResult> fetchProvinceDay({
    required LotteryRegion region,
    required String province,
    required DateTime date,
  }) async {
    final regionResult = await fetchRegionDay(region: region, date: date);
    final match = regionResult.data.draws.where(
      (d) => _provinceMatch(d.province, province),
    );
    if (match.isEmpty) {
      throw LotteryDataException('Không tìm thấy kết quả tỉnh $province.');
    }
    return LotteryFetchResult(
      data: RegionDayResults(
        region: region,
        date: regionResult.data.date,
        draws: match.toList(),
      ),
      sourceUrl: regionResult.sourceUrl,
      fetchedAt: regionResult.fetchedAt,
    );
  }

  Future<String> _getHtml(String url) async {
    final response = await _client
        .get(Uri.parse(url), headers: _headers)
        .timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      throw LotteryDataException(
        'HTTP ${response.statusCode} khi tải $url',
      );
    }
    return response.body;
  }

  String _regionDayUrl(LotteryRegion region, DateTime date) {
    final d = DateFormat('dd-MM-yyyy').format(date);
    final path = switch (region) {
      LotteryRegion.mienBac => 'mien-bac',
      LotteryRegion.mienNam => 'mien-nam',
      LotteryRegion.mienTrung => 'mien-trung',
    };
    return '$_baseUrl/ket-qua-xo-so/$path/$d.html';
  }

  String _formatDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  bool _provinceMatch(String a, String b) {
    final na = _normProvince(a);
    final nb = _normProvince(b);
    return na.contains(nb) || nb.contains(na);
  }

  String _normProvince(String s) =>
      s.toLowerCase().replaceAll('.', '').replaceAll(' ', '');

  void dispose() => _client.close();
}

class LotteryDataException implements Exception {
  LotteryDataException(this.message);
  final String message;

  @override
  String toString() => message;
}
