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

    showBoard();
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
}

void main() {
  TrianglePegGame();
}
