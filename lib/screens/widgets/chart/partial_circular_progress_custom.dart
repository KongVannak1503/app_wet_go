import 'package:flutter/material.dart';

class PartialCircularProgressCustom extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double size;
  final String text;
  final Color progressColor;
  final Color backgroundColor;

  const PartialCircularProgressCustom({
    super.key,
    required this.progress,
    required this.text,
    this.size = 100,
    this.progressColor = const Color(0xFF0B1B4D),
    this.backgroundColor = const Color(0xFFE5E5E5),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _PartialCirclePainter(
              progress: progress,
              progressColor: progressColor,
              backgroundColor: backgroundColor,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: size * 0.2 / 1.7,
              fontWeight: FontWeight.bold,
              color: progressColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartialCirclePainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  _PartialCirclePainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 16;
    double startAngle = 34.5 / 4; // start from top-left (gap at bottom)
    double sweepAngle = 3 * 3.14 / 2; // 270 degrees
    final rect = Offset.zero & size;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background arc (full 270°)
    canvas.drawArc(
      rect.deflate(strokeWidth / 1),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Draw progress arc
    canvas.drawArc(
      rect.deflate(strokeWidth / 1),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
