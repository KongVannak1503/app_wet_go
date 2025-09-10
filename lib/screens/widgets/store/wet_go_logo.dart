import 'package:flutter/material.dart';

class WetGoLogoWidget extends StatelessWidget {
  final double width;
  final EdgeInsetsGeometry? margin;

  const WetGoLogoWidget({super.key, this.width = 200, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          margin ??
          const EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 0),
      width: width,
      child: Image.asset('assets/images/wet_go_logo.png'),
    );
  }
}
