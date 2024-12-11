import 'package:ace_routes/view/e_from.dart';
import 'package:ace_routes/view/voltage_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/eform_controller.dart';
import '../model/GTypeModel.dart';
import 'add_bw_from.dart';

class EformSelect extends StatelessWidget {
  EformSelect({super.key});

  final EFormController controller =
      Get.put(EFormController()); // Initialize the controller

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          'Select Form',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Obx(() {
          if (controller.gTypeList.isEmpty) {
            return Center(
                child:
                    CircularProgressIndicator()); // Show loading while fetching data
          } else {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: controller.gTypeList.length,
                itemBuilder: (context, index) {
                  GTypeModel gType = controller.gTypeList[index];

                  // Check if gType.details is not empty
                  bool isDetailsNotEmpty = gType.details.isNotEmpty;

                  return Column(
                    children: [
                      // Only show the ListTile if gType.details is not empty
                      if (isDetailsNotEmpty)
                        ListTile(
                          onTap: () {
                            print(
                                'ListTile tapped: ${gType.name}'); // Debugging
                            Navigator.of(context).pop(); // Close the dialog

                            // Navigate to the specific form based on the GType data
                            if (gType.name == 'BW Form') {
                              Get.to(AddBwForm(gType: gType));
                            } else if (gType.name == 'Voltage Form') {
                              Get.to(VoltageForm());
                            }
                          },
                          title: Text(gType.name), // Display GType name
                          // Display additional data if needed
                        ),
                      // Show a divider (optional) after the ListTile
                      if (isDetailsNotEmpty) Divider(),
                    ],
                  );
                });
          }
        })
      ]),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(),
            ),
          ),
        ),
      ],
    );
  }
}
