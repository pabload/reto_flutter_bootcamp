import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void snackMessage(
    {required final String message,
    required final BuildContext context,
    final bool isError = false}) {
  final SnackBar snackBar = SnackBar(
    duration: Duration(seconds: isError ? 4 : 1),
    backgroundColor: isError ? Colors.red[700] : Colors.green[500],
    content: Text(
      '$message',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
