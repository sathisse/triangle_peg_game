import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'peg_game.dart';
import 'utils.dart';

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
    var paddedDiameter = diameter * 3;
    return Stack(children: <Widget>[
      for (var peg in pegs.entries)
        Positioned(
            top: height * pegPositions[peg.key]!.y - 1.5 * diameter,
            left: width * pegPositions[peg.key]!.x - 1.5 * diameter,
            height: paddedDiameter,
            width: paddedDiameter,
            child: Align(
              alignment: Alignment.center,
              child: Draggable<int>(
                  data: peg.key,
                  onDragStarted: () {},
                  onDragEnd: (details) {
                    if (!details.wasAccepted) {
                      showSnackBarGlobal(context, 'The destination must be an empty hole!');
                      Future.delayed(const Duration(seconds: 2)).then((_) => showSnackBarGlobal(
                          context, 'Drag a peg over another and into an empty hole.'));
                    }
                  },
                  feedback: Material(
                      elevation: 10,
                      color: Colors.transparent,
                      child: SvgPicture.asset('assets/peg.svg',
                          width: diameter,
                          height: diameter,
                          colorFilter: ColorFilter.mode(pegs[peg.key]!, BlendMode.srcIn))),
                  childWhenDragging: SvgPicture.asset('assets/peg.svg',
                      width: diameter,
                      height: diameter,
                      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
                  child: SvgPicture.asset('assets/peg.svg',
                      width: diameter,
                      height: diameter,
                      colorFilter: ColorFilter.mode(pegs[peg.key]!, BlendMode.srcIn))),
            ))
    ]);
  }
}
