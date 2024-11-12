import 'package:ace_routes/controller/barcode_controller.dart';
import 'package:ace_routes/core/colors/Constants.dart';
import 'package:ace_routes/view/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/fontSizeController.dart';

class AddPart extends StatefulWidget {
  const AddPart({super.key});

  @override
  State<AddPart> createState() => _AddPartState();
}

class _AddPartState extends State<AddPart> {
  String? _selectedCategory; // Variable to store selected category
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final fontSizeController = Get.find<FontSizeController>();
  // Dummy list of categories
  final List<String> _categories = ['Category 1', 'Category 2', 'Category 3'];
  final BarcodeController _barcodeController = Get.put(BarcodeController());
  // final BarcodeController _barcodeController = Get.find<BarcodeController>();

  @override
  void initState() {
    super.initState();
    // Listen to changes in scannedData
    ever(_barcodeController.scannedData, (data) {
      _skuController.text = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:myAppBar(context: context, titleText: 'Add Part', backgroundColor:MyColors.blueColor ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Dropdown Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Category',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items: _categories
                      .map((category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            // SKU Barcode Scanner Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // SKU TextFormField
                    Expanded(
                      child: TextFormField(
                        controller: _skuController,
                        decoration: InputDecoration(
                          labelText: 'SKU',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Barcode Icon Button
                    IconButton(
                      icon: Icon(Icons.qr_code_scanner),
                      onPressed: () {
                        print('Button pressed'); // Debugging print
                        print(_skuController.text);
                        _barcodeController.scanBarcode();
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Quantity TextFormField Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                // Navigate to PartDetailScreen and pass the entered data
                /*Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PartDetailScreen(
                      category: _selectedCategory,
                      sku: _skuController.text,
                      quantity: _quantityController.text,
                    ),
                  ),
                );*/
              },
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize:
                    Size(double.infinity, 50), // Make button full width
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PartDetailScreen extends StatelessWidget {
  final String? category;
  final String sku;
  final String quantity;

  const PartDetailScreen({
    Key? key,
    required this.category,
    required this.sku,
    required this.quantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSizeController = Get.find<FontSizeController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Part ',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
       backgroundColor: Color.fromARGB(255, 76, 81, 175),
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
                    Row(
                      children: [
                        Text(
                          'Category :',
                          style: TextStyle(
                              fontSize: fontSizeController.fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '    ${category ?? "Not Selected"}',
                          style: TextStyle(
                            fontSize: fontSizeController.fontSize,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'SKU :',
                          style: TextStyle(
                              fontSize: fontSizeController.fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '             ${sku}',
                          style: TextStyle(
                            fontSize: fontSizeController.fontSize,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Quantity :',
                          style: TextStyle(
                              fontSize: fontSizeController.fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '      ${quantity}',
                          style: TextStyle(
                            fontSize: fontSizeController.fontSize,
                          ),
                        ),
                      ],
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
}
