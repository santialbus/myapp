import 'package:flutter/material.dart';
import '../../components/or_divider.dart';
import '../../components/socal_icon.dart';

class SocalSignUp extends StatelessWidget {
  const SocalSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OrDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SocalIcon(iconSrc: "assets/images/fb.png", press: () {}),
            SocalIcon(iconSrc: "assets/images/google.png", press: () {}),
          ],
        ),
      ],
    );
  }
}
