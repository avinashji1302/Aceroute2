import 'package:ace_routes/core/colors/Constants.dart';
import 'package:ace_routes/view/appbar.dart';
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
        Text(
          label.toUpperCase(),
          style: TextStyle(color: Colors.black),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.green[500], // Set the background color
            borderRadius: BorderRadius.circular(8), // Add border radius
          ),
          width: double.infinity,
          padding: padding,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
              onTap: () {},
              child: Text(
                value ?? 'N/A',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

    return Scaffold(
      appBar: myAppBar(
          context: context,
          titleText: 'Summmary Details.',
          backgroundColor: MyColors.blueColor),
      body: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.all(spacing),
          children: [
            Container(
          color: const Color.fromARGB(255, 242, 255, 243),
              padding: padding,
              width: double.infinity,
              child: Text('88290 , Should show voltage .....',
                  style: TextStyle(
                    fontSize: fontSizeController.fontSize,
                    color: Colors.black
                  )),
            ),
            SizedBox(height: spacing),
            Container(
             
              color: const Color.fromARGB(255, 242, 255, 243),
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
               color: const Color.fromARGB(255, 242, 255, 243),
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
