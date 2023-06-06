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

  TrianglePegGame() {
    doGameLoop();
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
    print("\nStarting game with peg $startingPeg missing.");

    while (true) {
      showBoard();

      ({int from, int to, int over})? jump = (from: 0, to: 0, over: 0);
      do {
        jump = getJump();
      } while (jump == null);

      print("Got jump: $jump");
      if (jump == (from: 0, to: 0, over: 0)) {
        break;
      }
    }
  }

  void showBoard() {
    print("\nRemaining pegs: $pegs.\n");
    print("            1                    ${showPeg(1)}");
    print("          2   3                ${showPeg(2)}  ${showPeg(3)}");
    print("        4   5   6            ${showPeg(4)}  ${showPeg(5)}  ${showPeg(6)}");
    print("      7   8   9  10        ${showPeg(7)}  ${showPeg(8)}  ${showPeg(9)}  ${showPeg(10)}");
    print("    11  12  13  14  15    "
        "${showPeg(11)}  ${showPeg(12)}  ${showPeg(13)}  ${showPeg(14)}  ${showPeg(15)}\n");
  }

  String showPeg(int peg) {
    if (pegs.contains(peg)) {
      return "$peg".padLeft(2, " ");
    } else {
      return "..";
    }
  }

  int? getStartingPeg() {
    print("\nWhich missing peg would you like to start with ('q' to quit)?");
    List<String>? input = stdin.readLineSync()?.split(RegExp(r"[ ,]"));
    if (input == null) {
      return null;
    }

    if (input[0] == 'q') {
      return 0;
    }

    if (input.length != 1) {
      print("Enter exactly 1 peg number!");
      return null;
    }

    var startingPeg = int.tryParse(input[0]);
    if (startingPeg == null || startingPeg < 1 || startingPeg > 15) {
      print("Enter an integer from 1 to 15 for starting peg number!");
      return null;
    }

    return startingPeg;
  }

  ({int from, int to, int over})? getJump() {
    print("Which jump would you like to make?\n"
        "Enter from and to peg numbers ('q' to quit):");
    List<String>? input = stdin.readLineSync()?.split(RegExp(r"[ ,]"));

    if (input == null) {
      return null;
    }

    if (input[0] == 'q') {
      return (from: 0, to: 0, over: 0);
    }

    if (input.length != 2) {
      print("Enter exactly 2 peg numbers!");
      return null;
    }

    var pegs = input.map((e) => int.tryParse(e)).toList();
    if ((pegs[0] == null || pegs[0]! < 1 || pegs[0]! > 15) ||
        (pegs[1] == null || pegs[1]! < 1 || pegs[1]! > 15)) {
      print("Enter integers from 1 to 15 for each peg number!");
      return null;
    } else {
      var (from, to) = (pegs[0]!, pegs[1]!);
      var over = allValidJumps.where((j) => j.from == from && j.to == to).firstOrNull?.over ?? 0;
      return (from: from, to: to, over: over);
    }
  }
}

void main() {
  TrianglePegGame();
}
