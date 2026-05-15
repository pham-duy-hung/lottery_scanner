import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottery_scanner/ui/l10n/app_strings.dart';
import 'package:lottery_scanner/ui/models/scan_session.dart';
import 'package:lottery_scanner/ui/screens/camera_screen.dart';
import 'package:lottery_scanner/ui/screens/draw_results_screen.dart';
import 'package:lottery_scanner/ui/widgets/locale_fade.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';
import 'package:lottery_scanner/ui/widgets/language_switcher.dart';
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
        SnackBar(content: Text(s.selectProvinceError)),
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
    final dateStr = DateFormat('EEEE, dd/MM/yyyy', s.localeCode).format(_date);
    final needsProvince = s.regionNeedsProvince(_region);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 168,
            pinned: true,
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: LanguageSwitcher(onDarkBackground: true),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(s.appTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      bottom: 48,
                      child: Icon(Icons.document_scanner, size: 90, color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 50,
                      child: Text(
                        dateStr,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
                      ),
                ),
                const SizedBox(height: 24),
                Text(s.selectRegion, style: _labelStyle),
                const SizedBox(height: 12),
                RegionSelector(
                  selected: _region,
                  onChanged: (r) => setState(() {
                    _region = r;
                    if (!s.regionNeedsProvince(r)) _province = null;
                  }),
                ),
                const SizedBox(height: 24),
                LotteryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.drawDate, style: _labelStyle),
                      const SizedBox(height: 12),
                      _DateTile(
                        label: DateFormat('dd/MM/yyyy').format(_date),
                        onTap: _pickDate,
                      ),
                      if (needsProvince) ...[
                        const SizedBox(height: 20),
                        Text(s.province, style: _labelStyle),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
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
                const SizedBox(height: 28),
                PrimaryButton(label: s.scanNow, icon: Icons.document_scanner, onPressed: _openCamera),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: s.viewResults,
                  icon: Icons.list_alt,
                  outlined: true,
                  onPressed: _openDrawResults,
                ),
                const SizedBox(height: 32),
                _Step(icon: Icons.camera_alt_outlined, title: s.stepScan, subtitle: s.stepScanDesc),
                const SizedBox(height: 12),
                _Step(icon: Icons.cloud_download_outlined, title: s.stepFetch, subtitle: s.stepFetchDesc),
                const SizedBox(height: 12),
                _Step(icon: Icons.emoji_events_outlined, title: s.stepMatch, subtitle: s.stepMatchDesc),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static const _labelStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey.shade600),
          ],
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
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
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
