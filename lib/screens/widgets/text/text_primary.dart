import 'package:flutter/material.dart';

class PrimaryText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const PrimaryText({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: Theme.of(context).colorScheme.primary, // dynamic color
      ),
    );
  }
}
