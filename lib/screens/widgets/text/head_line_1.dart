import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeadLine1 extends StatelessWidget {
  final String text;

  const HeadLine1({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.getFont(
        'Khmer OS Siemreap', // font name as string
        fontSize: 25,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
