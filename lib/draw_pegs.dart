import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'peg_game.dart';

class DrawPegs extends StatelessWidget {
  final double width;
  final double height;
  final Map<int, Color> pegs;
  late final double diameter;

  DrawPegs(this.width, this.height, this.pegs, {super.key}) {
    diameter = width * holeSizeFactor;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      for (var peg in pegs.entries)
        Positioned(
            top: height * pegPositions[peg.key].y,
            left: width * pegPositions[peg.key].x,
            height: diameter,
            width: diameter,
            child: SvgPicture.asset('assets/peg.svg',
                colorFilter: ColorFilter.mode(pegs[peg.key]!, BlendMode.srcIn)))
    ]);
  }
}
