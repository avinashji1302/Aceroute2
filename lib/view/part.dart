import 'package:ace_routes/core/Constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/fontSizeController.dart';
import '../controller/getOrderPart_controller.dart';
import 'add_part.dart';

class PartScreen extends StatefulWidget {
  const PartScreen({super.key});

  @override
  State<PartScreen> createState() => _PartScreenState();
}

class _PartScreenState extends State<PartScreen> {
  final fontSizeController = Get.find<FontSizeController>();
  final getOrderPart = Get.put(GetOrderPartController());
  @override
  Widget build(BuildContext context) {
    AllTerms.getTerm();
    return Scaffold(
      appBar: AppBar(
        title: Text(
         AllTerms.partName.value,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 40.0,
            ),
            onPressed: () {
              Get.to(AddPart());
              print('Add Part button pressed');
            },
          ),
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() => Container(
            height: 130,
            width: double.infinity,
                child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              softWrap: true,
                              '${getOrderPart.name}',
                              style: TextStyle(
                                  fontSize: fontSizeController.fontSize,
                                 ),
                            ),
                          ),
                      
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              softWrap: true,
                              '${getOrderPart.detail}',
                              style: TextStyle(
                                  fontSize: fontSizeController.fontSize,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),

                        ],
                      ),
                    ),

                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              softWrap: true,
                              '${getOrderPart.sku}',
                              style: TextStyle(
                                  fontSize: fontSizeController.fontSize,
                                  ),
                            ),
                          ),

                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),)
    );
  }
}
