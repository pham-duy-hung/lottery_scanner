import 'package:flutter/material.dart';
import 'package:lottery_scanner/ui/l10n/app_strings.dart';
import 'package:lottery_scanner/ui/models/scan_session.dart';
import 'package:lottery_scanner/ui/screens/result_screen.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';
import 'package:lottery_scanner/ui/widgets/language_switcher.dart';
import 'package:lottery_scanner/ui/widgets/scan_frame_overlay.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.session});

  final ScanSession session;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _flashOn = false;
  bool _processing = false;

  Future<void> _simulateScan() async {
    if (_processing) return;
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _processing = false);

    const mockNumber = '123456';
    final winner = mockNumber.endsWith('56');
    final s = AppStrings.of(context);

    final result = widget.session.copyWith(
      scannedNumber: mockNumber,
      isWinner: winner,
      prizeName: winner ? (s.isVi ? 'Giải Nhất' : 'First Prize') : null,
      prizeAmount: winner ? (s.isVi ? '10.000.000 đ' : '10,000,000 VND') : null,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => ResultScreen(session: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final region = s.regionLabel(widget.session.region);
    final title = widget.session.locationLabel(region);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: LanguageSwitcher(onDarkBackground: true),
          ),
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
            onPressed: () => setState(() => _flashOn = !_flashOn),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF263238), Color(0xFF455A64)],
              ),
            ),
            child: Center(
              child: Icon(Icons.videocam_outlined, size: 100, color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          const ScanFrameOverlay(),
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 12,
            left: 24,
            right: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(s.scanHint, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
          ),
          if (_processing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.accent),
                    const SizedBox(height: 16),
                    Text(s.recognizing, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _Controls(
              processing: _processing,
              s: s,
              onGallery: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(s.gallerySoon)),
              ),
              onCapture: _simulateScan,
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.processing,
    required this.s,
    required this.onGallery,
    required this.onCapture,
  });

  final bool processing;
  final AppStrings s;
  final VoidCallback onGallery;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(32, 24, 32, 24 + bottom),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Btn(icon: Icons.photo_library_outlined, label: s.gallery, onTap: processing ? null : onGallery),
          GestureDetector(
            onTap: processing ? null : onCapture,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: processing ? Colors.grey : AppColors.accent,
                  ),
                  child: processing
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : null,
                ),
              ),
            ),
          ),
          _Btn(icon: Icons.flip_camera_ios_outlined, label: s.flip, onTap: null),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
