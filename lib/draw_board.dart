import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DrawBoard extends StatelessWidget {
  final double width;
  final double height;

  const DrawBoard(this.width, this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/board.svg', width: width, height: height, fit: BoxFit.fill);
  }
}
