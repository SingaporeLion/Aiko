import 'package:flutter/material.dart';

import '../../utils/assets.dart';
import '../../widgets/app_name_widget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Assets.bot,
              scale: 3,
            ),
            const AppNameWidget()
          ],
        ),
      ),
    );
  }
}
