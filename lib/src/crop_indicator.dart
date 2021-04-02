import 'package:flutter/material.dart';

class CropIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(Theme.of(context).accentColor),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  final Paint _paint;

  _GridPainter(this.color)
      : _paint = Paint()
          ..style = PaintingStyle.stroke
          ..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _paint);

    paintGrid(canvas, size, 3);

    paintAngle(canvas, size);
  }

  void paintGrid(Canvas canvas, Size size, int divisions) {
    final w = size.width / divisions;
    final h = size.height / divisions;

    for (var i = 1; i < divisions; ++i) {
      canvas.drawLine(Offset(0, h * i), Offset(size.width, h * i), _paint);

      canvas.drawLine(Offset(w * i, 0), Offset(w * i, size.height), _paint);
    }
  }

  void paintAngle(Canvas canvas, Size size) {
    final _paint = Paint() //
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;

    final double length = 16;

    canvas.drawPath(
      Path() //
        ..moveTo(0, length)
        ..lineTo(0, 0)
        ..lineTo(length, 0)
        //
        ..moveTo(size.width - length, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, length)
        //
        ..moveTo(size.width, size.height - length)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width - length, size.height)
        //
        ..moveTo(length, size.height)
        ..lineTo(0, size.height)
        ..lineTo(0, size.height - length),
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.color != color;
}
