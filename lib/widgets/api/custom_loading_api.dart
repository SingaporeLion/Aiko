import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../utils/custom_color.dart';

class CustomLoadingAPI extends StatelessWidget {
  const CustomLoadingAPI({
    Key? key,
    this.color = CustomColor.primaryColor,
  }) : super(key: key);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Lynn's Zauberhut ist auf... Antwort kommt gleich!"),
          SizedBox(height: 20.0),  // Ein bisschen Abstand zwischen der Nachricht und der Animation
          SpinKitThreeBounce(
            color: color.withOpacity(0.5),
            size: 30.0,
          ),
        ],
      ),
    );
  }
}