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

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);
    final direction = end - start;
    final length = direction.distance;
    if (length == 0) return;
    final unit = Offset(direction.dx / length, direction.dy / length);
    final normal = Offset(-unit.dy, unit.dx);
    final tip = end;
    final left = tip - unit * 10 + normal * 4;
    final right = tip - unit * 10 - normal * 4;
    canvas.drawLine(tip, left, paint);
    canvas.drawLine(tip, right, paint);
  }

  void _drawOpAmp(Canvas canvas, Rect rect) {
    final body = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.right, rect.center.dy)
      ..close();
    final fill = Paint()
      ..color = const Color(0xffeef4ff)
      ..style = PaintingStyle.fill;
    canvas.drawPath(body, fill);
    canvas.drawPath(body, _stroke);
    _drawLabel(
        canvas, '−', Offset(rect.left + 13, rect.top + rect.height * 0.18),
        fontSize: 20, weight: FontWeight.w700);
    _drawLabel(
        canvas, '+', Offset(rect.left + 14, rect.top + rect.height * 0.65),
        fontSize: 20, weight: FontWeight.w700);
    _drawLabel(canvas, 'OP-AMP',
        Offset(rect.left + rect.width * 0.22, rect.center.dy - 8),
        fontSize: 11, weight: FontWeight.w700);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final minus = Offset(width * 0.48, height * 0.48);
    final plus = Offset(width * 0.48, height * 0.64);
    final output = Offset(width * 0.76, height * 0.56);
    final outputNode = Offset(width * 0.86, output.dy);
    final inputStart = Offset(width * 0.04, minus.dy);
    final inputComponentStart = Offset(width * 0.20, minus.dy);
    final inputComponentEnd = Offset(width * 0.34, minus.dy);
    final feedbackY = height * 0.18;
    final feedbackComponentStart = Offset(width * 0.58, feedbackY);
    final feedbackComponentEnd = Offset(width * 0.70, feedbackY);
    final groundPoint = Offset(width * 0.48, plus.dy + 0.10 * height);
    final outputEnd = Offset(width * 0.96, output.dy);
    final opRect = Rect.fromLTRB(
      minus.dx,
      height * 0.36,
      output.dx,
      height * 0.72,
    );

    // Input path to the inverting input. The actual series element is between the
    // Vin source and the - input node; no wire bypasses the component.
    canvas.drawLine(inputStart, inputComponentStart, _stroke);
    if (isDifferentiator) {
      final capacitorMid = Offset(
        (inputComponentStart.dx + inputComponentEnd.dx) / 2,
        minus.dy,
      );
      canvas.drawLine(
        inputComponentStart,
        capacitorMid - const Offset(7, 0),
        _stroke,
      );
      _drawCapacitorPlates(canvas, capacitorMid, _stroke);
      canvas.drawLine(
        capacitorMid + const Offset(7, 0),
        inputComponentEnd,
        _stroke,
      );
      _drawLabel(canvas, 'C', capacitorMid + const Offset(-5, -28));
    } else {
      _drawResistorZigzag(
        canvas,
        inputComponentStart,
        inputComponentEnd,
        _stroke,
      );
      _drawLabel(
        canvas,
        'R',
        Offset((inputComponentStart.dx + inputComponentEnd.dx) / 2 - 5,
            minus.dy - 28),
      );
    }
    canvas.drawLine(inputComponentEnd, minus, _stroke);
    _drawLabel(canvas, 'Vin', inputStart + const Offset(-2, -28));

    // The inverting node is the shared connection point for input and feedback.
    canvas.drawCircle(minus, 3.5, _fill);

    // Feedback path is a single, continuous series path from the - input node to
    // the output pin. We do not allow a bypass wire or floating capacitor terminal.
    canvas.drawLine(minus, Offset(minus.dx, feedbackY), _stroke);
    canvas.drawLine(
      Offset(minus.dx, feedbackY),
      feedbackComponentStart,
      _stroke,
    );
    if (isDifferentiator) {
      _drawResistorZigzag(
        canvas,
        feedbackComponentStart,
        feedbackComponentEnd,
        _stroke,
      );
      _drawLabel(
        canvas,
        'R',
        Offset(
          (feedbackComponentStart.dx + feedbackComponentEnd.dx) / 2 - 5,
          feedbackY - 28,
        ),
      );
    } else {
      final capacitorMid = Offset(
        (feedbackComponentStart.dx + feedbackComponentEnd.dx) / 2,
        feedbackY,
      );
      canvas.drawLine(
        feedbackComponentStart,
        capacitorMid - const Offset(7, 0),
        _stroke,
      );
      _drawCapacitorPlates(canvas, capacitorMid, _stroke);
      canvas.drawLine(
        capacitorMid + const Offset(7, 0),
        feedbackComponentEnd,
        _stroke,
      );
      _drawLabel(canvas, 'C', capacitorMid + const Offset(-5, -34));
    }
    canvas.drawLine(feedbackComponentEnd, Offset(feedbackComponentEnd.dx, output.dy), _stroke);
    canvas.drawLine(Offset(feedbackComponentEnd.dx, output.dy), output, _stroke);

    // Output lead and label.
    canvas.drawLine(output, outputNode, _stroke);
    _drawArrow(canvas, outputNode, outputEnd, _stroke);
    canvas.drawCircle(output, 3.5, _fill);
    _drawLabel(canvas, 'Vout', outputEnd + const Offset(-34, -28));

    _drawOpAmp(canvas, opRect);

    // Non-inverting input is referenced to ground.
    canvas.drawLine(plus, groundPoint, _stroke);
    _drawGroundSymbol(canvas, groundPoint, _stroke);
    _drawLabel(canvas, 'GND', groundPoint + const Offset(-18, 48));
    _drawLabel(
      canvas,
      isDifferentiator ? 'Differentiator' : 'Integrator',
      Offset(width * 0.04, height * 0.88),
      fontSize: 16,
      weight: FontWeight.w700,
    );
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter oldDelegate) =>
      oldDelegate.isDifferentiator != isDifferentiator;
}
