import 'package:flutter/material.dart';

class BtnSubmit extends StatelessWidget {
  final VoidCallback? onPressed; // <-- make nullable
  final String text;
  final double? width;
  final double? height;
  final bool isLoading; // <-- new

  const BtnSubmit({
    super.key,
    required this.onPressed,
    this.text = 'Submit',
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // disable when loading
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }
}
