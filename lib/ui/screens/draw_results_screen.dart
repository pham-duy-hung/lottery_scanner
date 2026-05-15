import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottery_scanner/ui/data/lottery_results_repository.dart';
import 'package:lottery_scanner/ui/l10n/app_strings.dart';
import 'package:lottery_scanner/ui/models/lottery_draw.dart';
import 'package:lottery_scanner/ui/models/scan_session.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';
import 'package:lottery_scanner/ui/theme/mobile_layout.dart';
import 'package:lottery_scanner/ui/widgets/language_switcher.dart';
import 'package:lottery_scanner/ui/widgets/locale_fade.dart';
import 'package:lottery_scanner/ui/widgets/province_results_list.dart';
import 'package:lottery_scanner/ui/widgets/results_source_banner.dart';

/// Xem toàn bộ kết quả các tỉnh đã quay trong ngày (tải từ minhngoc.net.vn).
class DrawResultsScreen extends StatefulWidget {
  const DrawResultsScreen({
    super.key,
    required this.region,
    required this.date,
    this.province,
  });

  final LotteryRegion region;
  final DateTime date;
  final String? province;

  @override
  State<DrawResultsScreen> createState() => _DrawResultsScreenState();
}

class _DrawResultsScreenState extends State<DrawResultsScreen> {
  ResolvedDayResults? _resolved;
  bool _loading = true;
  String? _fatalError;
  bool _mockOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load({bool mockOnly = false}) async {
    setState(() {
      _loading = true;
      _fatalError = null;
      _mockOnly = mockOnly;
    });

    final s = AppStrings.of(context);
    try {
      final resolved = await LotteryResultsRepository.resolveDayResults(
        region: widget.region,
        date: widget.date,
        strings: s,
        useMockOnly: mockOnly,
      );
      if (!mounted) return;
      setState(() {
        _resolved = resolved;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _fatalError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final dateStr = DateFormat('dd/MM/yyyy').format(widget.date);
    final regionName = s.regionLabel(widget.region);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.dayResults),
        actions: [
          if (!_loading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _load(mockOnly: _mockOnly),
            ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSwitcher(onDarkBackground: true),
          ),
        ],
      ),
      body: LocaleFade(
        child: _buildBody(context, s, regionName, dateStr),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppStrings s,
    String regionName,
    String dateStr,
  ) {
    if (_loading) {
      return Center(
        child: Padding(
          padding: MobileLayout.pagePadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(s.loadingResults, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (_fatalError != null) {
      return Padding(
        padding: MobileLayout.pagePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text(s.fetchError, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_fatalError!, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => _load(), child: Text(s.retry)),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _load(mockOnly: true),
              child: Text(s.useSampleData),
            ),
          ],
        ),
      );
    }

    final resolved = _resolved!;
    final draws = _filterDraws(resolved.results.draws);

    return ListView(
      padding: MobileLayout.pagePadding(context),
      children: [
        _HeaderCard(
          regionName: regionName,
          dateStr: dateStr,
          province: widget.province,
        ),
        const SizedBox(height: 12),
        ResultsSourceBanner(
          source: resolved.source,
          loadError: resolved.loadError,
          onRetry: resolved.source == LotteryResultsSource.mock ? () => _load() : null,
        ),
        const SizedBox(height: 16),
        ProvinceResultsList(
          draws: draws,
          highlightProvince: widget.province,
          initiallyExpanded: widget.province != null,
        ),
      ],
    );
  }

  List<ProvinceDraw> _filterDraws(List<ProvinceDraw> draws) {
    if (widget.province == null) return draws;
    final p = widget.province!;
    final filtered = draws.where((d) {
      final a = d.province.toLowerCase().replaceAll(' ', '');
      final b = p.toLowerCase().replaceAll(' ', '');
      return a.contains(b) || b.contains(a);
    }).toList();
    return filtered.isEmpty ? draws : filtered;
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.regionName,
    required this.dateStr,
    this.province,
  });

  final String regionName;
  final String dateStr;
  final String? province;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            regionName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          ),
          if (province != null) ...[
            const SizedBox(height: 8),
            Text(
              '${s.province}: $province',
              style: TextStyle(
                color: AppColors.accent.withValues(alpha: 0.95),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
