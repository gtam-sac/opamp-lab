import 'package:flutter/material.dart';

class DifferentiatorCircuitDiagram extends StatelessWidget {
  const DifferentiatorCircuitDiagram({super.key});

  @override
  Widget build(BuildContext context) =>
      const CircuitDiagram(isDifferentiator: true);
}

class IntegratorCircuitDiagram extends StatelessWidget {
  const IntegratorCircuitDiagram({super.key});

  @override
  Widget build(BuildContext context) =>
      const CircuitDiagram(isDifferentiator: false);
}

class CircuitDiagram extends StatelessWidget {
  final bool isDifferentiator;

  const CircuitDiagram({super.key, required this.isDifferentiator});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 300,
          width: double.infinity,
          child: CustomPaint(
            painter: _CircuitPainter(isDifferentiator: isDifferentiator),
          ),
        ),
      ),
    );
  }
}

class _CircuitPainter extends CustomPainter {
  final bool isDifferentiator;

  _CircuitPainter({required this.isDifferentiator});

  final _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..isAntiAlias = true;

  final _fill = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset offset, {
    double fontSize = 14,
    FontWeight weight = FontWeight.w500,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: fontSize,
          fontWeight: weight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  void _drawResistorZigzag(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint,
  ) {
    final direction = p2 - p1;
    final length = direction.distance;
    if (length == 0) return;

    final unit = Offset(direction.dx / length, direction.dy / length);
    final normal = Offset(-unit.dy, unit.dx);
    const lead = 12.0;
    const amplitude = 7.0;
    const zigzags = 6;
    final points = <Offset>[p1 + unit * lead];
    final step = (length - 2 * lead) / (zigzags * 2);

    for (int i = 1; i <= zigzags * 2; i++) {
      final along = lead + step * i;
      final sign = i.isEven ? -1.0 : 1.0;
      points.add(p1 + unit * along + normal * amplitude * sign);
    }
    points.add(p2 - unit * lead);

    final path = Path()..moveTo(p1.dx, p1.dy);
    path.lineTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    path.lineTo(p2.dx, p2.dy);
    canvas.drawPath(path, paint);
  }

  void _drawCapacitorPlates(
    Canvas canvas,
    Offset midpoint,
    Paint paint, {
    bool vertical = true,
  }) {
    const gap = 7.0;
    const plate = 22.0;

    if (vertical) {
      canvas.drawLine(
        Offset(midpoint.dx - gap, midpoint.dy - plate),
        Offset(midpoint.dx - gap, midpoint.dy + plate),
        paint,
      );
      canvas.drawLine(
        Offset(midpoint.dx + gap, midpoint.dy - plate),
        Offset(midpoint.dx + gap, midpoint.dy + plate),
        paint,
      );
    } else {
      canvas.drawLine(
        Offset(midpoint.dx - plate, midpoint.dy - gap),
        Offset(midpoint.dx + plate, midpoint.dy - gap),
        paint,
      );
      canvas.drawLine(
        Offset(midpoint.dx - plate, midpoint.dy + gap),
        Offset(midpoint.dx + plate, midpoint.dy + gap),
        paint,
      );
    }
  }

  void _drawGroundSymbol(Canvas canvas, Offset point, Paint paint) {
    canvas.drawLine(point, point + const Offset(0, 18), paint);
    canvas.drawLine(
      point + const Offset(-18, 18),
      point + const Offset(18, 18),
      paint,
    );
    canvas.drawLine(
      point + const Offset(-11, 24),
      point + const Offset(11, 24),
      paint,
    );
    canvas.drawLine(
      point + const Offset(-4, 30),
      point + const Offset(4, 30),
      paint,
    );
  }

  void _drawOpAmpTriangle(
    Canvas canvas,
    Rect rect,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.right, rect.center.dy)
      ..close();
    canvas.drawPath(path, paint);

    _drawLabel(canvas, '−', Offset(rect.left + 15, rect.top + 25), fontSize: 18);
    _drawLabel(canvas, '+', Offset(rect.left + 15, rect.bottom - 43), fontSize: 18);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final yIn = size.height * 0.38;
    final yPlus = size.height * 0.70;
    final opRect = Rect.fromLTWH(
      width * 0.42,
      size.height * 0.22,
      width * 0.23,
      size.height * 0.50,
    );
    final minus = Offset(opRect.left, opRect.top + opRect.height * 0.32);
    final plus = Offset(opRect.left, opRect.top + opRect.height * 0.70);
    final output = Offset(opRect.right, opRect.center.dy);
    final inputStart = Offset(width * 0.06, minus.dy);
    final componentStart = Offset(width * 0.18, minus.dy);
    final feedbackY = size.height * 0.10;
    final outputEnd = Offset(width * 0.92, output.dy);

    // Input path and component.
    canvas.drawLine(inputStart, componentStart, _stroke);
    if (isDifferentiator) {
      canvas.drawLine(componentStart, componentStart + const Offset(45, 0), _stroke);
      _drawCapacitorPlates(
        canvas,
        componentStart + const Offset(45, 0),
        _stroke,
        vertical: false,
      );
      canvas.drawLine(
        componentStart + const Offset(45, 0),
        minus,
        _stroke,
      );
      _drawLabel(canvas, 'C', componentStart + const Offset(30, -30));
    } else {
      final resistorEnd = componentStart + const Offset(95, 0);
      _drawResistorZigzag(canvas, componentStart, resistorEnd, _stroke);
      canvas.drawLine(resistorEnd, minus, _stroke);
      _drawLabel(canvas, 'R', componentStart + const Offset(38, -30));
    }
    _drawLabel(canvas, 'Vin', inputStart + const Offset(-2, -28));

    // Non-inverting input to ground.
    canvas.drawLine(plus, Offset(plus.dx - 42, plus.dy), _stroke);
    final groundPoint = Offset(plus.dx - 42, plus.dy);
    _drawGroundSymbol(canvas, groundPoint, _stroke);
    _drawLabel(canvas, 'GND', groundPoint + const Offset(-18, 36));

    // Output.
    canvas.drawLine(output, outputEnd, _stroke);
    _drawLabel(canvas, 'Vout', outputEnd + const Offset(-10, -28));

    // Feedback path.
    canvas.drawLine(
      output,
      Offset(output.dx, feedbackY),
      _stroke,
    );
    canvas.drawLine(
      Offset(output.dx, feedbackY),
      Offset(minus.dx, feedbackY),
      _stroke,
    );

    if (isDifferentiator) {
      final resistorMid = Offset(
        (minus.dx + output.dx) / 2,
        feedbackY,
      );
      _drawResistorZigzag(
        canvas,
        resistorMid + const Offset(-70, 0),
        resistorMid + const Offset(70, 0),
        _stroke,
      );
      _drawLabel(canvas, 'R', resistorMid + const Offset(-8, -30));
    } else {
      final capMid = Offset(
        (minus.dx + output.dx) / 2,
        feedbackY,
      );
      _drawCapacitorPlates(
        canvas,
        capMid,
        _stroke,
        vertical: true,
      );
      _drawLabel(canvas, 'C', capMid + const Offset(-8, -45));
    }

    canvas.drawLine(
      Offset(minus.dx, feedbackY),
      minus,
      _stroke,
    );
    canvas.drawCircle(minus, 3, _fill);
    canvas.drawCircle(output, 3, _fill);
    _drawLabel(
      canvas,
      isDifferentiator ? 'Differentiator' : 'Integrator',
      Offset(width * 0.06, size.height * 0.86),
      fontSize: 16,
      weight: FontWeight.w700,
    );
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter oldDelegate) =>
      oldDelegate.isDifferentiator != isDifferentiator;
}
