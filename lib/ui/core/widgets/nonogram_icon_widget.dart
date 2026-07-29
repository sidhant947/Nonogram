import 'package:flutter/material.dart';

class NonogramIconWidget extends StatelessWidget {
  const NonogramIconWidget({
    super.key,
    this.size = 56,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? const Color(0xFF38BDF8);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NonogramIconPainter(color: activeColor),
      ),
    );
  }
}

class _NonogramIconPainter extends CustomPainter {
  _NonogramIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;
    final pad = size.width * 0.06;

    // Draw a 3x3 Nonogram stylized pattern (e.g. cross pattern)
    final pattern = [
      [1, 0, 1],
      [0, 1, 0],
      [1, 0, 1],
    ];

    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (pattern[r][c] == 1) {
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(
              c * cellWidth + pad / 2,
              r * cellHeight + pad / 2,
              cellWidth - pad,
              cellHeight - pad,
            ),
            const Radius.circular(4),
          );
          canvas.drawRRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NonogramIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
