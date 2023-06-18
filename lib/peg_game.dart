import 'dart:math';
import 'package:flutter/material.dart';

import 'draw_board.dart';
import 'draw_holes.dart';
import 'draw_pegs.dart';
import 'utils.dart';

typedef JumpRec = ({int from, int to, int over});

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
const List<JumpRec> allValidJumps = [
  (from: 1, to: 4, over: 2),
  (from: 1, to: 6, over: 3),
  (from: 2, to: 7, over: 4),
  (from: 2, to: 9, over: 5),
  (from: 3, to: 8, over: 5),
  (from: 3, to: 10, over: 6),
  (from: 4, to: 1, over: 2),
  (from: 4, to: 6, over: 5),
  (from: 4, to: 11, over: 7),
  (from: 4, to: 13, over: 8),
  (from: 5, to: 12, over: 8),
  (from: 5, to: 14, over: 9),
  (from: 6, to: 1, over: 3),
  (from: 6, to: 4, over: 5),
  (from: 6, to: 13, over: 9),
  (from: 6, to: 15, over: 10),
  (from: 7, to: 2, over: 4),
  (from: 7, to: 9, over: 8),
  (from: 8, to: 3, over: 5),
  (from: 8, to: 10, over: 9),
  (from: 9, to: 2, over: 5),
  (from: 9, to: 7, over: 8),
  (from: 10, to: 3, over: 6),
  (from: 10, to: 8, over: 9),
  (from: 11, to: 4, over: 7),
  (from: 11, to: 13, over: 12),
  (from: 12, to: 5, over: 8),
  (from: 12, to: 14, over: 13),
  (from: 13, to: 4, over: 8),
  (from: 13, to: 6, over: 9),
  (from: 13, to: 11, over: 12),
  (from: 13, to: 15, over: 14),
  (from: 14, to: 5, over: 9),
  (from: 14, to: 12, over: 13),
  (from: 15, to: 6, over: 10),
  (from: 15, to: 13, over: 14),
];

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
        DrawHoles(width, height, pegs, onJumpRequested: onJumpRequested),
        DrawPegs(width, height, pegs),
      ]);
    });
  }

  onJumpRequested(int from, int to) {
    log.d('Jump from $from to $to requested.');

    JumpRec? jump = getJump(from, to);
    if (pegs.length == 15 || canJump(jump)) {
      makeJump(jump);
      showSnackBarGlobal(context, 'Drag a peg over another and into an empty hole.');
    }
  }

  JumpRec getJump(int from, int to) {
    var jumps = allValidJumps.where((j) => j.from == from && j.to == to);
    var over = 0;
    if (jumps.isNotEmpty) {
      over = jumps.first.over;
    }
    return (from: from, to: to, over: over);
  }

  bool canJump(JumpRec jump) {
    // Due to the interaction between the Draggable peg and the DragTarget hole, it is known that
    //   the 'to' hole has a peg in it and the 'from' hole doesn't, so all that remains is to
    //   check that there is a valid jump with those and that the 'over' hole has a peg in it.
    if (!allValidJumps.contains(jump)) {
      showSnackBarGlobal(context, 'That is an invalid jump!');
      Future.delayed(const Duration(seconds: 2)).then(
          (_) => showSnackBarGlobal(context, 'Drag a peg over another and into an empty hole.'));
      return false;
    } else if (pegs[jump.over] == null) {
      showSnackBarGlobal(context, 'A peg must be jumped over!');
      Future.delayed(const Duration(seconds: 2)).then(
          (_) => showSnackBarGlobal(context, 'Drag a peg over another and into an empty hole.'));
      return false;
    }
    return true;
  }

  void makeJump(JumpRec jump) {
    // If 'to' is 0, then remove the first peg; otherwise attempt to make a jump.
    if (jump.to == 0) {
      pegs.remove(jump.from);
    } else {
      pegs[jump.to] = pegs[jump.from]!;
      pegs.remove(jump.from);
      pegs.remove(jump.over);
    }

    // Let the GUI know that the state's changed so that it will update itself:
    setState(() {});
  }
}
