import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'draw_board.dart';
import 'draw_holes.dart';
import 'draw_pegs.dart';
import 'utils.dart';

typedef JumpRec = ({int from, int to, int over});

const rows = 5;
const pegCount = rows * (rows + 1) / 2;
const double pegWidth = 1 / (rows + 1);
const double holeSizeFactor = 1 / 25;
const List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
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
final Map<int, ({double x, double y})> pegPositions = {};

class PegGame extends StatefulWidget {
  const PegGame({super.key});

  @override
  State<PegGame> createState() => _PegGame();
}

class _PegGame extends State<PegGame> {
  Map<int, Color> pegs = {};

  // The following 2 structures should probably be combined,
  //   perhaps as a list of Pair<int, Color> (dartx package) or (peg, color) record,
  //   or maybe as a LinkedHashMap (which is ordered).
  List jumpsMade = [];
  List jumpedColors = [];
  int bestScore = 0;
  bool noMoreJumps = false;

  @override
  void initState() {
    super.initState();

    // Build a list of row where each row contains the peg numbers in that row:
    final grid = [
      for (var (peg, row) = (0, 1); row <= rows; row++) [for (var col = 1; col <= row; col++) ++peg]
    ];

    // Build a map, keyed by peg number, with the fractional offsets (x,y) for that peg:
    double rowOffset = pegWidth;
    for (int row = rows - 1; row >= 0; row--) {
      double y = (row + 1) * pegWidth;
      for (int col = 0; col < grid[row].length; col++) {
        pegPositions[grid[row][col]] = (x: rowOffset + col * pegWidth, y: y);
      }
      rowOffset += pegWidth / 2;
    }

    resetGame();
  }

  void resetGame() {
    noMoreJumps = false;
    getBestScore();
    pegs.clear();
    for (int peg = 1; peg <= pegCount; peg++) {
      pegs[peg] = Color(colors[Random().nextInt(colors.length)].value);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => () {
          if (pegs.length == pegCount) {
            showSnackBarGlobal(context, 'Drag the first peg off of the board.');
          }
        }());
    return LayoutBuilder(builder: (context, constraints) {
      var width = min(constraints.maxWidth, constraints.maxHeight);
      var height = sqrt(3) / 2 * width; // formula for the height of an equilateral triangle

      return DragTarget<int>(
        builder: (
          BuildContext context,
          List<dynamic> accepted,
          List<dynamic> rejected,
        ) {
          return Stack(children: [
            DrawBoard(width, height, pegs, onJumpRequested: onJumpRequested),
            DrawHoles(width, height, pegs, onJumpRequested: onJumpRequested),
            DrawPegs(width, height, pegs),
            if (noMoreJumps)
              AlertDialog(
                title: const Text('Game Over'),
                content: Text("You left ${pegs.length} peg(s).\n\nThat's ${getGameOverRating()}\n"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => resetGame(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            Column(children: [
              IconButton(
                icon: const Icon(Icons.restart_alt, semanticLabel: 'restart'),
                tooltip: 'Restart game',
                onPressed: () {
                  log.d('Undoing last move');
                  resetGame();
                },
              ),
              const SizedBox(height: 10),
              IconButton(
                icon: const Icon(Icons.undo, semanticLabel: 'undo'),
                tooltip: 'Undo last jump',
                onPressed: () {
                  log.d('Undoing last move');
                  undoJump();
                },
              ),
            ]),
            Align(
                alignment: Alignment.topRight,
                child: Column(children: [
                  const Text(
                    'Best Score',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('$bestScore'),
                ]))
          ]);
        },
        onWillAccept: (data) {
          // log.d('peg_game.onWillAccept() pegs.length = ${pegs.length}');
          return pegs.length == pegCount;
        },
        onAccept: (data) {
          // Always except drop of first peg (since drag-target will always be outside of board):
          onJumpRequested(data, 0);
        },
      );
    });
  }

  onJumpRequested(int from, int to) {
    log.d('Jump from $from to $to requested.');

    JumpRec? jump = getJump(from, to);
    if (pegs.length == pegCount || canJump(jump)) {
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
    jumpsMade.add(jump);
    log.d('jumpsMade is now $jumpsMade');

    // If 'to' is 0, then remove the first peg; otherwise attempt to make a jump.
    if (jump.to == 0) {
      jumpedColors.add(pegs[jump.from]!);
      pegs.remove(jump.from);
    } else {
      pegs[jump.to] = pegs[jump.from]!;
      pegs.remove(jump.from);
      jumpedColors.add(pegs[jump.over]!);
      pegs.remove(jump.over);
    }

    if (pegs.length < pegCount &&
        allValidJumps
            .where((j) =>
                pegs.keys.contains(j.from) &&
                !pegs.keys.contains(j.to) &&
                pegs.keys.contains(j.over))
            .isEmpty) {
      noMoreJumps = true;
      bestScore = pegs.length;
      setBestScore(bestScore);
    }

    // Let the GUI know that the state's changed so that it will update itself:
    setState(() {});
  }

  void undoJump() {
    if (jumpsMade.isEmpty) {
      return;
    }

    var color = jumpedColors.removeLast();
    var jump = jumpsMade.removeLast();

    if (jump.to == 0) {
      log.d('Undoing first jump: $jump');
      pegs[jump.from] = color;
    } else {
      log.d('Undoing std jump: $jump');
      pegs[jump.over] = color;
      pegs[jump.from] = pegs[jump.to]!;
      pegs.remove(jump.to);
    }
    log.d('pegs=$pegs');

    setState(() {});
  }

  String getGameOverRating() {
    switch (pegs.length) {
      case 1:
        return 'genius!';
      case 2:
        return 'above average.';
      case 3:
        return 'so-so.';
      default:
        return 'pretty bad.';
    }
  }

  Future<void> setBestScore(pegsRemaining) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    if (pegsRemaining < bestScore) {
      pref.setInt('scoreData', pegsRemaining);
      setState(() {});
    }
  }

  void getBestScore() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    bestScore = pref.getInt('scoreData')!;
    setState(() {});
  }
}
