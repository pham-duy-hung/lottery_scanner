import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottery_scanner/ui/l10n/app_strings.dart';
import 'package:lottery_scanner/ui/models/scan_session.dart';
import 'package:lottery_scanner/ui/screens/camera_screen.dart';
import 'package:lottery_scanner/ui/screens/draw_results_screen.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';
import 'package:lottery_scanner/ui/theme/mobile_layout.dart';
import 'package:lottery_scanner/ui/widgets/language_switcher.dart';
import 'package:lottery_scanner/ui/widgets/locale_fade.dart';
import 'package:lottery_scanner/ui/widgets/lottery_card.dart';
import 'package:lottery_scanner/ui/widgets/primary_button.dart';
import 'package:lottery_scanner/ui/widgets/region_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LotteryRegion _region = LotteryRegion.mienBac;
  DateTime _date = DateTime.now();
  String? _province;

  static const _southProvinces = [
    'TP.HCM', 'Đồng Tháp', 'Cà Mau', 'Bến Tre', 'Vũng Tàu',
    'Bạc Liêu', 'Đồng Nai', 'Cần Thơ', 'Sóc Trăng', 'An Giang',
  ];

  static const _centralProvinces = [
    'Đà Nẵng', 'Khánh Hòa', 'Bình Định', 'Quảng Nam', 'Quảng Ngãi',
    'Gia Lai', 'Ninh Thuận', 'Đắk Lắk', 'Quảng Bình', 'Huế',
  ];

  List<String> get _provinces => _region == LotteryRegion.mienNam
      ? _southProvinces
      : _centralProvinces;

  Future<void> _pickDate() async {
    final s = AppStrings.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: Locale(s.isVi ? 'vi' : 'en'),
      helpText: s.drawDate,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _openDrawResults() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DrawResultsScreen(
          region: _region,
          date: _date,
          province: _province,
        ),
      ),
    );
  }

  void _openCamera() {
    final s = AppStrings.of(context);
    if (s.regionNeedsProvince(_region) && _province == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.selectProvinceError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CameraScreen(
          session: ScanSession(region: _region, date: _date, province: _province),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final topPad = MediaQuery.paddingOf(context).top;
    final todayStr = DateFormat('EEEE, dd/MM/yyyy', s.localeCode).format(DateTime.now());
    final needsProvince = s.regionNeedsProvince(_region);
    final pagePad = MobileLayout.pagePadding(context);
    final headerH = MobileLayout.headerExpandedHeight(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppBar(
              expandedHeight: topPad + headerH,
              collapsedHeight: topPad + kToolbarHeight,
              pinned: true,
              centerTitle: false,
              automaticallyImplyLeading: false,
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: LanguageSwitcher(onDarkBackground: true),
                ),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final collapsed =
                      constraints.biggest.height <= topPad + kToolbarHeight + 8;
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryDark, AppColors.primary],
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          right: -8,
                          bottom: 4,
                          child: Icon(
                            Icons.document_scanner,
                            size: MobileLayout.narrowScreen(context) ? 64 : 76,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 88,
                          top: collapsed ? null : topPad + 6,
                          bottom: collapsed ? 10 : null,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.appTitle,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: collapsed
                                      ? 17
                                      : (MobileLayout.narrowScreen(context) ? 22 : 24),
                                  color: Colors.white,
                                  height: 1.15,
                                ),
                              ),
                              if (!collapsed) ...[
                                const SizedBox(height: 6),
                                Text(
                                  todayStr,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    fontSize:
                                        MobileLayout.narrowScreen(context) ? 12 : 13,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: pagePad,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  LocaleFade(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          s.appTagline,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: MobileLayout.narrowScreen(context) ? 14 : 16,
                              ),
                        ),
                        const SizedBox(height: 20),
                        Text(s.selectRegion, style: _labelStyle),
                        const SizedBox(height: 10),
                        RegionSelector(
                          selected: _region,
                          onChanged: (r) => setState(() {
                            _region = r;
                            if (!s.regionNeedsProvince(r)) _province = null;
                          }),
                        ),
                        const SizedBox(height: 20),
                        LotteryCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.drawDate, style: _labelStyle),
                              const SizedBox(height: 10),
                              _DateTile(
                                label: DateFormat('dd/MM/yyyy').format(_date),
                                onTap: _pickDate,
                              ),
                              if (needsProvince) ...[
                                const SizedBox(height: 16),
                                Text(s.province, style: _labelStyle),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  initialValue: _province,
                                  hint: Text(s.selectProvince),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.place, color: AppColors.primary),
                                  ),
                                  items: _provinces
                                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _province = v),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: s.scanNow,
                          icon: Icons.document_scanner,
                          onPressed: _openCamera,
                        ),
                        const SizedBox(height: 10),
                        PrimaryButton(
                          label: s.viewResults,
                          icon: Icons.list_alt,
                          outlined: true,
                          onPressed: _openDrawResults,
                        ),
                        const SizedBox(height: 28),
                        _Step(icon: Icons.camera_alt_outlined, title: s.stepScan, subtitle: s.stepScanDesc),
                        const SizedBox(height: 10),
                        _Step(icon: Icons.cloud_download_outlined, title: s.stepFetch, subtitle: s.stepFetchDesc),
                        const SizedBox(height: 10),
                        _Step(icon: Icons.emoji_events_outlined, title: s.stepMatch, subtitle: s.stepMatchDesc),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _labelStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}
