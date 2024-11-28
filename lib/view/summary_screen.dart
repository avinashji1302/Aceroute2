import 'package:ace_routes/controller/summary_controller.dart';
import 'package:ace_routes/core/Constants.dart';
import 'package:ace_routes/core/colors/Constants.dart';
import 'package:ace_routes/view/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/event_controller.dart';
import '../controller/fontSizeController.dart';

class SummaryDetails extends StatelessWidget {
  final String id;
  SummaryDetails({super.key, required this.id});
  // final SummaryController summaryController = Get.put(SummaryController());
  final EventController eventController = Get.put(EventController());

  @override
  Widget build(BuildContext context) {
    // Initialize the SummaryController with the id
    Get.lazyPut(() => SummaryController(id));

    final SummaryController summaryController = Get.find<SummaryController>();

    print("id is $id");
    AllTerms.getTerm();
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
            titleText: AllTerms.summaryLabel,
            backgroundColor: MyColors.blueColor),
        body: Container(
            color: Colors.white,
            child: Obx(() {
              return ListView(
                padding: EdgeInsets.all(spacing),
                children: [
                  Container(
                    color: const Color.fromARGB(255, 242, 255, 243),
                    padding: padding,
                    width: double.infinity,
                    child: Text('$id , ${summaryController.nm.value}',
                        style: TextStyle(
                            fontSize: fontSizeController.fontSize,
                            color: Colors.black)),
                  ),
                  SizedBox(height: spacing),
                  Container(
                    color: const Color.fromARGB(255, 242, 255, 243),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildInfoRow('Scheduled Date',
                            '${summaryController.startDate.value}'),
                        buildInfoRow('Start Time',
                            '${summaryController.startTime.value}'),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing),
                  Container(
                    color: const Color.fromARGB(255, 242, 255, 243),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildInfoRow('Duration',
                            '${summaryController.duration.value} minute'),
                        buildInfoRow('Category',
                            '${eventController.categoryName.value}'),
                        buildInfoRow('Priority', 'P5: Normal'),
                      ],
                    ),
                  ),
                ],
              );
            })));
  }
}
