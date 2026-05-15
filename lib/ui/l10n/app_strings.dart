import 'package:flutter/material.dart';
import 'package:lottery_scanner/ui/models/scan_session.dart';

class AppStrings {
  AppStrings(this.locale);

  final Locale locale;
  bool get isVi => locale.languageCode == 'vi';
  String get localeCode => isVi ? 'vi_VN' : 'en_US';

  static AppStrings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStringsScope>();
    assert(scope != null, 'AppStringsScope missing');
    return scope!.strings;
  }

  // App
  String get appTitle => isVi ? 'Quét Vé Số' : 'Ticket Scanner';
  String get appTagline => isVi
      ? 'Kiểm tra vé trúng thưởng ba miền'
      : 'Check winning tickets — all three regions';

  // Regions
  String get regionNorth => isVi ? 'Miền Bắc' : 'North';
  String get regionSouth => isVi ? 'Miền Nam' : 'South';
  String get regionCentral => isVi ? 'Miền Trung' : 'Central';
  String regionLabel(LotteryRegion r) => switch (r) {
        LotteryRegion.mienBac => regionNorth,
        LotteryRegion.mienNam => regionSouth,
        LotteryRegion.mienTrung => regionCentral,
      };
  bool regionNeedsProvince(LotteryRegion r) =>
      r == LotteryRegion.mienNam || r == LotteryRegion.mienTrung;

  // Home
  String get selectRegion => isVi ? 'Chọn miền' : 'Select region';
  String get drawDate => isVi ? 'Ngày xổ số' : 'Draw date';
  String get province => isVi ? 'Tỉnh / Thành phố' : 'Province';
  String get selectProvince => isVi ? 'Chọn tỉnh' : 'Select province';
  String get selectProvinceError =>
      isVi ? 'Vui lòng chọn tỉnh/thành phố' : 'Please select a province';
  String get scanNow => isVi ? 'Quét vé ngay' : 'Scan ticket';
  String get viewResults => isVi ? 'Xem kết quả xổ số' : 'View lottery results';
  String comingSoon(String f) =>
      isVi ? '$f — sắp ra mắt' : '$f — coming soon';

  String get stepScan => isVi ? 'Quét vé' : 'Scan';
  String get stepScanDesc => isVi
      ? 'Chụp hoặc chọn ảnh vé để nhận diện số'
      : 'Take or pick a photo to read numbers';
  String get stepFetch => isVi ? 'Lấy kết quả' : 'Fetch results';
  String get stepFetchDesc => isVi
      ? 'Tự động lấy kết quả từ minhngoc.net.vn'
      : 'Auto-fetch results from minhngoc.net.vn';
  String get stepMatch => isVi ? 'So khớp' : 'Match';
  String get stepMatchDesc => isVi
      ? 'Đối chiếu số vé với các giải thưởng'
      : 'Compare your numbers with prizes';

  // Camera
  String get scanTicket => isVi ? 'Quét vé' : 'Scan ticket';
  String get scanHint => isVi
      ? 'Đặt dãy số 6 chữ số vào khung hình'
      : 'Align the 6-digit number inside the frame';
  String get recognizing => isVi ? 'Đang nhận diện số...' : 'Recognizing numbers...';
  String get gallery => isVi ? 'Thư viện' : 'Gallery';
  String get flip => isVi ? 'Lật' : 'Flip';
  String get gallerySoon =>
      comingSoon(isVi ? 'Chọn ảnh từ thư viện' : 'Pick from gallery');

  // Result
  String get checkResult => isVi ? 'Kết quả kiểm tra' : 'Check result';
  String get congrats => isVi ? 'Chúc mừng! Bạn đã trúng!' : 'Congratulations! You won!';
  String get notWon => isVi ? 'Chưa trúng thưởng' : 'No prize this time';
  String get goodLuck =>
      isVi ? 'Chúc bạn may mắn lần sau' : 'Better luck next time';
  String get yourNumber => isVi ? 'Số trên vé của bạn' : 'Your ticket number';
  String get scanAnother => isVi ? 'Quét vé khác' : 'Scan another';
  String get backHome => isVi ? 'Về trang chủ' : 'Back to home';
  String get prize => isVi ? 'Giải thưởng' : 'Prize';
}

class AppStringsScope extends InheritedWidget {
  const AppStringsScope({
    super.key,
    required this.strings,
    required super.child,
  });

  final AppStrings strings;

  @override
  bool updateShouldNotify(AppStringsScope old) =>
      strings.locale != old.strings.locale;
}
