import 'package:flutter/material.dart';


class ErrorScreen extends StatelessWidget {
  final String text;
  const ErrorScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          textAlign: TextAlign.center,
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            backgroundColor: Colors.black,
            height: 2,
          ),
        ),
      ],
    ));
  }
}
