// ignore_for_file: avoid_print

import 'dart:io';

class TrianglePegGame {
  /* The board:
               1
             2   3
           4   5   6
         7   8   9  10
      11  12  13  14  15
  */

  Set<int> pegs = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
  List jumpsMade = [];
  bool playGame = true;

  static final List allValidJumps = [
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

  TrianglePegGame({int startingPeg = 0, this.playGame = false}) {
    if (playGame) {
      doGameLoop();
    } else {
      print('Solving puzzle with peg $startingPeg missing...');
      pegs.remove(startingPeg);
      if (solvePuzzle()) {
        outputJumpsMade('Solved using');
      } else {
        print(' No solution found.');
      }
    }
  }

  void doGameLoop() {
    int? startingPeg;
    do {
      startingPeg = getStartingPeg();
    } while (startingPeg == null);
    if (startingPeg == 0) {
      return;
    }
    pegs.remove(startingPeg);
    print('\nStarting game with peg $startingPeg missing.');

    while (true) {
      showBoard();
      ({int from, int to, int over})? jump = (from: 0, to: 0, over: 0);
      do {
        jump = getJump();
      } while (jump == null);

      if (jump == (from: 0, to: 0, over: 0)) {
        break;
      }

      if (canJump(jump)) {
        makeJump(jump);
      } else {
        print('Jumping peg from ${jump.from} to ${jump.to} is not a valid jump!');
      }

      if (pegs.length == 1 || noMoreJumps()) {
        break;
      }
    }
    showBoard();

    print('\nThe game ended with ${pegs.length} pegs left. That\'s ${getGameSuffix()}\n');
    outputJumpsMade('You made');
  }

  void showBoard() {
    print('\nRemaining pegs: $pegs.\n');
    print('            1                    ${showPeg(1)}');
    print('          2   3                ${showPeg(2)}  ${showPeg(3)}');
    print('        4   5   6            ${showPeg(4)}  ${showPeg(5)}  ${showPeg(6)}');
    print('      7   8   9  10        ${showPeg(7)}  ${showPeg(8)}  ${showPeg(9)}  ${showPeg(10)}');
    print('    11  12  13  14  15    '
        '${showPeg(11)}  ${showPeg(12)}  ${showPeg(13)}  ${showPeg(14)}  ${showPeg(15)}\n');
  }

  String showPeg(int peg) {
    if (pegs.contains(peg)) {
      return '$peg'.padLeft(2, ' ');
    } else {
      return '..';
    }
  }

  int? getStartingPeg() {
    print('\nWhich missing peg would you like to start with (\'q\' to quit)?');
    List<String>? input = stdin.readLineSync()?.split(' ');

    if (input == null) {
      return null;
    }

    if (input[0] == 'q') {
      return 0;
    }

    if (input.length != 1) {
      print('Enter exactly 1 peg number!');
      return null;
    }

    var startingPeg = int.tryParse(input[0]);
    if (startingPeg == null || startingPeg < 1 || startingPeg > 15) {
      print('Enter an integer from 1 to 15 for starting peg number!');
      return null;
    }

    return startingPeg;
  }

  ({int from, int to, int over})? getJump() {
    print('Which jump would you like to make?\nEnter from and to peg numbers (\'q\' to quit):');
    List<String>? input = stdin.readLineSync()?.split(RegExp(r'[ ,]'));

    if (input == null) {
      return null;
    }

    if (input[0] == 'q') {
      return (from: 0, to: 0, over: 0);
    }

    if (input.length != 2) {
      print('Enter exactly 2 peg numbers!');
      return null;
    }

    var pegs = input.map((e) => int.tryParse(e)).toList();
    if ((pegs[0] == null || pegs[0]! < 1 || pegs[0]! > 15) ||
        (pegs[1] == null || pegs[1]! < 1 || pegs[1]! > 15)) {
      print('Enter integers from 1 to 15 for each peg number!');
      return null;
    } else {
      var (from, to) = (pegs[0]!, pegs[1]!);
      var over = allValidJumps.where((j) => j.from == from && j.to == to).firstOrNull?.over ?? 0;
      return (from: from, to: to, over: over);
    }
  }

  bool canJump(({int from, int to, int over}) jump) {
    // The from and over must have pegs while the to doesn't:
    return allValidJumps.contains(jump) &&
        (pegs.contains(jump.from) && !pegs.contains(jump.to) && pegs.contains(jump.over));
  }

  void makeJump(({int from, int to, int over}) jump) {
    pegs.remove(jump.from);
    pegs.add(jump.to);
    pegs.remove(jump.over);
    jumpsMade.add(jump);
  }

  bool noMoreJumps() {
    return allValidJumps
        .where((j) => pegs.contains(j.from) && pegs.contains(j.over) && !pegs.contains(j.to))
        .isEmpty;
  }

  String getGameSuffix() {
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

  void outputJumpsMade(String prefix) {
    print(' $prefix ${jumpsMade.length} jumps (from, to, over):\n');
    print('  ${jumpsMade.map((e) => (e.from, e.to, e.over)).join(', ')}');
  }

  bool solvePuzzle() {
    var jumpList = allValidJumps.where((e) => canJump(e)).toList();
    for (var jump in jumpList) {
      makeJump(jump);
      if (pegs.length == 1) {
        return true;
      }

      if (solvePuzzle()) {
        return true;
      }
      undoJump();
    }
    return false;
  }

  void undoJump() {
    var jump = jumpsMade.removeLast();
    pegs.add(jump.over);
    pegs.remove(jump.to);
    pegs.add(jump.from);
  }
}

void main() {
  TrianglePegGame(playGame: true);

  for (int peg in [1, 2, 4, 5]) {
    TrianglePegGame(startingPeg: peg);
  }
}
