enum LotteryRegion { mienBac, mienNam, mienTrung }

class ScanSession {
  const ScanSession({
    required this.region,
    required this.date,
    this.province,
    this.scannedNumber,
    this.isWinner = false,
    this.prizeName,
    this.prizeAmount,
  });

  final LotteryRegion region;
  final DateTime date;
  final String? province;
  final String? scannedNumber;
  final bool isWinner;
  final String? prizeName;
  final String? prizeAmount;

  ScanSession copyWith({
    String? scannedNumber,
    bool? isWinner,
    String? prizeName,
    String? prizeAmount,
  }) {
    return ScanSession(
      region: region,
      date: date,
      province: province,
      scannedNumber: scannedNumber ?? this.scannedNumber,
      isWinner: isWinner ?? this.isWinner,
      prizeName: prizeName ?? this.prizeName,
      prizeAmount: prizeAmount ?? this.prizeAmount,
    );
  }

  String locationLabel(String regionLabel) {
    if (province != null) return '$regionLabel · $province';
    return regionLabel;
  }
}
