import 'package:ace_routes/controller/getOrderPart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/fontSizeController.dart';
import '../core/Constants.dart';
import 'add_part.dart';

class PartScreen extends StatefulWidget {
  final String oid;

  const PartScreen({Key? key, required this.oid}) : super(key: key);

  @override
  _PartScreenState createState() => _PartScreenState();
}

class _PartScreenState extends State<PartScreen> {
  final controller = Get.put(GetOrderPartController());
  final fontSizeController = Get.find<FontSizeController>();

  @override
  void initState() {
    super.initState();
    _initializeData(); // Call initialization logic
  }

  Future<void> _initializeData() async {
    await controller.fetchOrderData(widget.oid);
    await controller.GetOrderPartFromDb(widget.oid);
  }

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
      body: FutureBuilder(
        future: _initializeData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
           return Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Obx(
                      () => Container(
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
                                      '${controller.name.value}',
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
                                      '${controller.detail.value}',
                                      style: TextStyle(
                                        fontSize: fontSizeController.fontSize,
                                        fontWeight: FontWeight.bold,
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
                                      '${controller.sku.value}',
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
              ),
            );
          }
        },

      ),
    );
  }
}
