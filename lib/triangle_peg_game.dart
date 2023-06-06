// ignore_for_file: avoid_print

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
}

void main() {
  TrianglePegGame();
}
