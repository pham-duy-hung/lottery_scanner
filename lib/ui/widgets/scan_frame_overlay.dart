import 'package:flutter/material.dart';

class ScanFrameOverlay extends StatelessWidget {
  const ScanFrameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ScanFramePainter(), child: const SizedBox.expand());
  }
}

class _ScanFramePainter extends CustomPainter {
  static const _w = 280.0;
  static const _h = 160.0;
  static const _corner = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 40);
    final rect = Rect.fromCenter(center: center, width: _w, height: _h);

    final dim = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final full = Path()..addRect(Offset.zero & size);
    final hole = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)));
    canvas.drawPath(Path.combine(PathOperation.difference, full, hole), dim);

    final corner = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _cornerAt(canvas, rect.topLeft, corner, 1, 1);
    _cornerAt(canvas, rect.topRight, corner, -1, 1);
    _cornerAt(canvas, rect.bottomLeft, corner, 1, -1);
    _cornerAt(canvas, rect.bottomRight, corner, -1, -1);
  }

  void _cornerAt(Canvas c, Offset p, Paint paint, double dx, double dy) {
    c.drawLine(p, p + Offset(_corner * dx, 0), paint);
    c.drawLine(p, p + Offset(0, _corner * dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
