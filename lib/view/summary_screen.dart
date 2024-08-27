import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/fontSizeController.dart';

class SummaryDetails extends StatelessWidget {
  const SummaryDetails({super.key});

  @override
  Widget build(BuildContext context) {
    // Define common styles to avoid repetition
    const double spacing = 10.0;
    const EdgeInsets padding = EdgeInsets.all(8.0);
    const TextStyle titleStyle = TextStyle(fontSize: 18);
    const TextStyle whiteTextStyle = TextStyle(color: Colors.white);
    final fontSizeController = Get.find<FontSizeController>();

    Widget buildInfoRow(String label, String value) {
      return Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: titleStyle),
            Container(
              color: Colors.green,
              width: double.infinity,
              padding: padding,
              child: GestureDetector(
                onTap: () {},
                child: Text(value, style: whiteTextStyle),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(

        centerTitle: true,
        title: Text('SummaryDetails', style: TextStyle(fontSize: fontSizeController.fontSize,color: Colors.white)),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 196, 196, 194),
        child: ListView(
          padding: EdgeInsets.all(spacing),
          children: [
            Container(
              color: Colors.white,
              padding: padding,
              width: double.infinity,
              child:  Text(
                '88290 , Should show voltage .....',
                  style: TextStyle(fontSize: fontSizeController.fontSize,)
              ),
            ),
            SizedBox(height: spacing),
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInfoRow('Scheduled Date', 'Aug 07 2024'),
                  buildInfoRow('Start Time', '1:20 pm'),
                ],
              ),
            ),
            SizedBox(height: spacing),
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInfoRow('Duration', '40 minutes'),
                  buildInfoRow('Category', 'Delivery'),
                  buildInfoRow('Priority', 'P5: Normal'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
