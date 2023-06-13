import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

Logger log = Logger(
  // printer: PrettyPrinter(),
  printer: PrettyPrinter(methodCount: 0),
);

void showSnackBarGlobal(BuildContext context, String message) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(days: 1),
      content: Text(
        message,
        textScaleFactor: 2,
      )));
}
