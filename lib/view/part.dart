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
    print("initrllaze");
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
              Get.to(AddPart(
                oid: widget.oid,
              ));
              controller.AddPartCategories();
              print('Add Part button pressed');
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.orderPartsList.isEmpty) {
          return Center(
              child: Text("No data found!")); // Show message if no data
        }

        return ListView.builder(
          itemCount: controller.orderPartsList.length,
          itemBuilder: (context, index) {
            final order = controller.orderPartsList[index];
            final partData = controller.partTypeDataList[
                index]; // Handle cases where data is still loading

            return Dismissible(
              key: Key(order.id), // Ensure a unique key
              direction:
                  DismissDirection.horizontal, // Allow both swipe directions
              background: Container(
                color: Colors.green, // Color for start-to-end swipe
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.edit, color: Colors.white), // Edit icon
              ),
              secondaryBackground: Container(
                color: Colors.red, // Color for end-to-start swipe
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white), // Delete icon
              ),
              onDismissed: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  // Swipe Right -> Open AddPart page in Update Mode
                  controller.AddPartCategories();
                  Get.to(() => AddPart(
                      oid: order.oid, // Pass the necessary data
                      part: order,
                      partTypeData: partData))?.then((_) {
                    // This will be called when returning from AddPart screen
                    //  controller.fetchOrderParts(); // Call API to refresh the list
                    print(order.sku);
                    print("sdsd");
                  });
                } else if (direction == DismissDirection.endToStart) {
                  // Swipe Left -> Call Delete Function
                  await controller.DeletePart(order.id);
                  controller.orderPartsList.remove(order); // Remove from UI
                }
              },

              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                partData != null
                                    ? Text(
                                        partData.name,
                                        style: TextStyle(
                                          fontSize: fontSizeController.fontSize,
                                        ),
                                      )
                                    : CircularProgressIndicator(), // Show loader while partData is fetching
                                Text(
                                  order.qty,
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: partData != null
                                      ? Text(
                                          partData.detail,
                                          style: TextStyle(
                                            fontSize:
                                                fontSizeController.fontSize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : CircularProgressIndicator(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    order.sku,
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
            );
          },
        );
      }),
    );
  }
}
