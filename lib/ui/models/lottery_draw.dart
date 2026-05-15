import 'package:lottery_scanner/ui/models/scan_session.dart';

/// Một giải trong kết quả xổ số (có thể nhiều dãy số).
class LotteryPrize {
  const LotteryPrize({
    required this.key,
    required this.numbers,
    this.amount,
  });

  final String key;
  final List<String> numbers;
  final String? amount;
}

/// Kết quả xổ của một tỉnh (hoặc Miền Bắc) trong ngày.
class ProvinceDraw {
  const ProvinceDraw({
    required this.province,
    required this.prizes,
  });

  final String province;
  final List<LotteryPrize> prizes;
}

/// Kết quả cả miền trong một ngày.
class RegionDayResults {
  const RegionDayResults({
    required this.region,
    required this.date,
    required this.draws,
  });

  final LotteryRegion region;
  final DateTime date;
  final List<ProvinceDraw> draws;
}

/// Vé trúng khi so với một giải cụ thể.
class PrizeMatch {
  const PrizeMatch({
    required this.province,
    required this.prizeKey,
    required this.prizeLabel,
    required this.winningNumber,
    this.amount,
  });

  final String province;
  final String prizeKey;
  final String prizeLabel;
  final String winningNumber;
  final String? amount;
}
