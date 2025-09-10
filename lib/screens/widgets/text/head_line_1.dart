import 'package:flutter/material.dart';

class HeadLine1 extends StatelessWidget {
  final String text;

  const HeadLine1({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
      softWrap: true,
      overflow: TextOverflow.visible,
    );
  }
}
