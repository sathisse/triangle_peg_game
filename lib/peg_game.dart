import 'dart:math';

import 'package:flutter/material.dart';

import 'draw_board.dart';

class PegGame extends StatefulWidget {
  const PegGame({super.key});

  @override
  State<PegGame> createState() => _PegGame();
}

class _PegGame extends State<PegGame> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var width = min(constraints.maxWidth, constraints.maxHeight);
      var height = sqrt(3) / 2 * width; // formula for the height of an equilateral triangle

      return Stack(children: [
        DrawBoard(width, height),
      ]);
    });
  }
}
