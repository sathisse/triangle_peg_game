import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'peg_game.dart';

class DrawHoles extends StatelessWidget {
  final double width;
  final double height;

  late final double diameter;

  DrawHoles(this.width, this.height, {super.key}) {
    diameter = width * holeSizeFactor;
  }

  @override
  Widget build(BuildContext context) {
    var labelDiameter = diameter * 1.5;
    return Stack(children: <Widget>[
      for (int peg = 1; peg <= 15; peg++)
        Positioned(
            top: height * pegPositions[peg].y,
            left: width * pegPositions[peg].x,
            height: labelDiameter,
            width: labelDiameter,
            child: Stack(children: <Widget>[
              Align(alignment: AlignmentDirectional.bottomEnd, child: Text('$peg')),
              SvgPicture.asset('assets/hole.svg', width: diameter, height: diameter)
            ]))
    ]);
  }
}
