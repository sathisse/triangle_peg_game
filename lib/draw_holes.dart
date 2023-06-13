import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:triangle_peg_game/utils.dart';
import 'peg_game.dart';

class DrawHoles extends StatelessWidget {
  final double width;
  final double height;
  final Map<int, Color> pegs;
  late final double diameter;

  DrawHoles(this.width, this.height, this.pegs, {super.key}) {
    diameter = width * holeSizeFactor;
  }

  @override
  Widget build(BuildContext context) {
    var paddedDiameter = diameter * 2;
    return Stack(children: <Widget>[
      for (int peg = 1; peg <= 15; peg++)
        Positioned(
            top: height * pegPositions[peg].y,
            left: width * pegPositions[peg].x,
            height: paddedDiameter,
            width: paddedDiameter,
            child: Stack(children: <Widget>[
              Align(alignment: Alignment.bottomRight, child: Text('$peg')),
              Align(
                  alignment: Alignment.center,
                  child: DragTarget<int>(
                    builder: (
                      BuildContext context,
                      List<dynamic> accepted,
                      List<dynamic> rejected,
                    ) {
                      return SvgPicture.asset('assets/hole.svg', width: diameter, height: diameter);
                    },
                    onWillAccept: (data) {
                      return pegs[peg] == null;
                    },
                    onAccept: (data) {
                      log.d('Jump requested: from $data to $peg');
                    },
                  ))
            ]))
    ]);
  }
}
