import 'package:lottery_scanner/ui/l10n/app_strings.dart';
import 'package:lottery_scanner/ui/models/lottery_draw.dart';
import 'package:lottery_scanner/ui/models/scan_session.dart';

/// Dữ liệu lịch quay & kết quả mẫu — thay bằng scraping/API sau.
class LotteryResultsRepository {
  LotteryResultsRepository._();

  static final _southSchedule = <int, List<String>>{
    DateTime.monday: ['TP.HCM', 'Đồng Tháp', 'Cà Mau'],
    DateTime.tuesday: ['Bến Tre', 'Vũng Tàu', 'Bạc Liêu'],
    DateTime.wednesday: ['Đồng Nai', 'Cần Thơ', 'Sóc Trăng'],
    DateTime.thursday: ['An Giang', 'Bình Thuận', 'Tây Ninh'],
    DateTime.friday: ['Vĩnh Long', 'Bình Dương', 'Trà Vinh'],
    DateTime.saturday: ['TP.HCM', 'Long An', 'Bình Phước', 'Hậu Giang'],
    DateTime.sunday: ['Kiên Giang', 'Tiền Giang', 'Đà Lạt'],
  };

  static final _centralSchedule = <int, List<String>>{
    DateTime.monday: ['Huế', 'Phú Yên'],
    DateTime.tuesday: ['Đắk Lắk', 'Quảng Nam'],
    DateTime.wednesday: ['Đà Nẵng', 'Khánh Hòa'],
    DateTime.thursday: ['Bình Định', 'Quảng Trị', 'Quảng Bình'],
    DateTime.friday: ['Gia Lai', 'Ninh Thuận'],
    DateTime.saturday: ['Đà Nẵng', 'Quảng Ngãi', 'Đắk Nông'],
    DateTime.sunday: ['Kon Tum', 'Khánh Hòa', 'Thừa Thiên Huế'],
  };

  static RegionDayResults fetchDayResults({
    required LotteryRegion region,
    required DateTime date,
    required AppStrings strings,
  }) {
    final normalized = DateTime(date.year, date.month, date.day);
    if (region == LotteryRegion.mienBac) {
      return RegionDayResults(
        region: region,
        date: normalized,
        draws: [
          ProvinceDraw(
            province: strings.regionNorth,
            prizes: _generatePrizes(normalized, 'mb', strings),
          ),
        ],
      );
    }

    final schedule = region == LotteryRegion.mienNam
        ? _southSchedule
        : _centralSchedule;
    final provinces = schedule[normalized.weekday] ?? [];

    return RegionDayResults(
      region: region,
      date: normalized,
      draws: provinces
          .map(
            (p) => ProvinceDraw(
              province: p,
              prizes: _generatePrizes(normalized, p, strings),
            ),
          )
          .toList(),
    );
  }

  static List<LotteryPrize> _generatePrizes(
    DateTime date,
    String seed,
    AppStrings s,
  ) {
    final h = Object.hash(date.year, date.month, date.day, seed);
    String n(int offset, int digits) {
      final v = (h + offset).abs() % 1000000;
      return v.toString().padLeft(digits, '0').substring(0, digits);
    }

    // Số demo: 123456 khớp giải 8 (2 chữ số) ở mọi tỉnh
    final g8 = seed == 'mb' ? '56' : '56';
    return [
      LotteryPrize(
        key: 'giai_db',
        numbers: [n(1, 6)],
        amount: s.isVi ? '2.000.000.000 đ' : '2,000,000,000 VND',
      ),
      LotteryPrize(key: 'giai_1', numbers: [n(2, 5)]),
      LotteryPrize(key: 'giai_2', numbers: [n(3, 5)]),
      LotteryPrize(key: 'giai_3', numbers: [n(4, 5), n(5, 5)]),
      LotteryPrize(key: 'giai_4', numbers: [n(6, 5), n(7, 5), n(8, 5)]),
      LotteryPrize(key: 'giai_5', numbers: [n(9, 4)]),
      LotteryPrize(key: 'giai_6', numbers: [n(10, 4), n(11, 4)]),
      LotteryPrize(key: 'giai_7', numbers: [n(12, 3)]),
      LotteryPrize(key: 'giai_8', numbers: [g8]),
    ];
  }

  static List<PrizeMatch> matchTicket({
    required String ticketNumber,
    required RegionDayResults results,
    required AppStrings strings,
  }) {
    final ticket = _normalize(ticketNumber);
    if (ticket.isEmpty) return [];

    final matches = <PrizeMatch>[];
    for (final draw in results.draws) {
      for (final prize in draw.prizes) {
        for (final num in prize.numbers) {
          if (_matches(ticket, num)) {
            matches.add(
              PrizeMatch(
                province: draw.province,
                prizeKey: prize.key,
                prizeLabel: strings.prizeLabel(prize.key),
                winningNumber: num,
                amount: prize.amount,
              ),
            );
          }
        }
      }
    }
    return matches;
  }

  static String _normalize(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 2) return '';
    return digits.length <= 6 ? digits.padLeft(6, '0') : digits.substring(digits.length - 6);
  }

  static bool _matches(String ticket, String drawn) {
    final d = drawn.replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) return false;
    final prize = d.length <= 6 ? d.padLeft(6, '0') : d.substring(d.length - 6);
    return ticket == prize || ticket.endsWith(prize) || prize.endsWith(ticket);
  }
}
