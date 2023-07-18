import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'peg_game.dart';
import 'utils.dart';

late Path trianglePath;

class DrawBoard extends StatelessWidget {
  final double width;
  final double height;
  final Map<int, Color> pegs;
  final Function onJumpRequested;

  const DrawBoard(this.width, this.height, this.pegs, {required this.onJumpRequested, super.key});

  @override
  Widget build(BuildContext context) {
    bool isOutsideBoard = true;
    trianglePath = Path()
      ..moveTo(width / 2, 0)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..lineTo(width / 2, 0)
      ..close();
    return DragTarget<int>(
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        return Stack(children: <Widget>[
          SvgPicture.asset('assets/board.svg', width: width, height: height, fit: BoxFit.fill),
          CustomPaint(size: Size(width, height), painter: Triangle()),
        ]);
      },
      hitTestBehavior: HitTestBehavior.translucent,
      onMove: (details) {
        // Account for height of AppBar, which defaults to 56:
        final adjustedOffset = Offset(details.offset.dx, details.offset.dy - 56);
        // Set a flag whether the mouse is outside the triangle of the board:
        if (trianglePath.contains(adjustedOffset)) {
          log.d('Position is over board');
          isOutsideBoard = false;
        } else {
          log.d('Position is not over board');
          isOutsideBoard = true;
        }
      },
      onWillAccept: (data) {
        // log.d('board.onWillAccept with peg $data');
        return pegs.length == pegCount;
      },
      onAccept: (data) {
        log.d('Board: onAccept with isOutsideBoard = $isOutsideBoard and peg $data}');
        if (isOutsideBoard) {
          onJumpRequested(data, 0);
        }
      },
    );
  }
}

class Triangle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(trianglePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
