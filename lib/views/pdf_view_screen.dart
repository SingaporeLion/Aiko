import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../controller/diet_chart_controller.dart';
import '../utils/assets.dart';
import '../utils/custom_color.dart';
import '../utils/strings.dart';

class PdfViewScreen extends StatelessWidget {
  final controller = Get.put(DietChartController());

  final List<int> pdfBytes;

  PdfViewScreen({Key? key, required this.pdfBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          tooltip: Strings.download.tr,
          onPressed: () {
            try {
              controller.downloadFile();
            } on PlatformException catch (error) {
              debugPrint(error.toString());
            }
          },
          child: const Icon(Icons.download)),
      appBar: AppBar(
        title:  Text(Strings.dietPlan.tr),
        backgroundColor: CustomColor.primaryColor.withOpacity(.30),
        actions: [
          Image.asset(
            Assets.bot,
            scale: 3,
          ),
        ],
      ),
      body: _bodyWidget(),
    );
  }

  Widget _bodyWidget() {
    final Uint8List bytes = Uint8List.fromList(pdfBytes);
    return SizedBox.expand(
      child: SfPdfViewer.memory(
        bytes,
      ),
    );
  }
}