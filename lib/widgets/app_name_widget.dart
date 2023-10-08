import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/custom_color.dart';
import '../utils/dimensions.dart';

class AppNameWidget extends StatelessWidget {
  const AppNameWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return languageStateName == 'Arabic'
        ? Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'AI',
          style: TextStyle(
              fontSize: Dimensions.defaultTextSize * 3.2,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).primaryColor),
        ),
        Text(
          'KO',
          style: TextStyle(
              fontSize: Dimensions.defaultTextSize * 3.2,
              fontWeight: FontWeight.w400,
              color: CustomColor.primaryColor),
        )
      ],
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'AI',
          style: TextStyle(
              fontSize: Dimensions.defaultTextSize * 3.2,
              fontWeight: FontWeight.w400,
              color: CustomColor.primaryColor),
        ),
        Text(
          'KO',
          style: TextStyle(
              fontSize: Dimensions.defaultTextSize * 3.2,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).primaryColor),
        )
      ],
    );
  }
}
