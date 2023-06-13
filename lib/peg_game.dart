import 'dart:math';
import 'package:flutter/material.dart';

import 'draw_board.dart';
import 'draw_holes.dart';
import 'draw_pegs.dart';

const double holeSizeFactor = 1 / 25;
const List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
const Map pegPositions = {
  1: (x: 0.495, y: 0.175),
  2: (x: 0.412, y: 0.341),
  3: (x: 0.578, y: 0.341),
  4: (x: 0.328, y: 0.508),
  5: (x: 0.495, y: 0.508),
  6: (x: 0.662, y: 0.508),
  7: (x: 0.245, y: 0.675),
  8: (x: 0.412, y: 0.675),
  9: (x: 0.578, y: 0.675),
  10: (x: 0.745, y: 0.675),
  11: (x: 0.162, y: 0.841),
  12: (x: 0.328, y: 0.841),
  13: (x: 0.495, y: 0.841),
  14: (x: 0.662, y: 0.841),
  15: (x: 0.828, y: 0.841),
};

class PegGame extends StatefulWidget {
  const PegGame({super.key});

  @override
  State<PegGame> createState() => _PegGame();
}

class _PegGame extends State<PegGame> {
  Map<int, Color> pegs = {};

  @override
  void initState() {
    super.initState();
    for (int peg = 2; peg <= 15; peg++) {
      pegs[peg] = Color(colors[Random().nextInt(colors.length)].value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var width = min(constraints.maxWidth, constraints.maxHeight);
      var height = sqrt(3) / 2 * width; // formula for the height of an equilateral triangle

      return Stack(children: [
        DrawBoard(width, height),
        DrawHoles(width, height, pegs),
        DrawPegs(width, height, pegs),
      ]);
    });
  }
}
