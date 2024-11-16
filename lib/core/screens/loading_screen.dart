import 'package:flutter/material.dart';


class LoadingScreen extends StatelessWidget {
  final String text;
  const LoadingScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.only(bottom: 16), child: Text(text)),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
