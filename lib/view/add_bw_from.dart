import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/fontSizeController.dart';

class AddBwForm extends StatefulWidget {
  const AddBwForm({super.key});

  @override
  State<AddBwForm> createState() => _AddBwFormState();
}

class _AddBwFormState extends State<AddBwForm> {
  final TextEditingController _technicianNameController =
      TextEditingController();
  XFile? _image; // To store the selected image

  // To store the selected value for radio buttons
  String? _selectedPaymentOption;
  final fontSizeController = Get.find<FontSizeController>();

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? selectedImage = await picker.pickImage(source: source);

    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add BW Form',
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Technician Name TextFormField
            TextFormField(
              controller: _technicianNameController,
              decoration: InputDecoration(
                labelText: 'Technician Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Customer Payment Taken? Row
            Text(
              'Customer Payment Taken?',
              style: TextStyle(fontSize: fontSizeController.fontSize),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'option1',
                        groupValue: _selectedPaymentOption,
                        onChanged: (val) {
                          setState(() {
                            _selectedPaymentOption = val;
                          });
                        },
                      ),
                      Expanded(
                        child: Text('Yes I have added\nPayment for checking'),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'option2',
                        groupValue: _selectedPaymentOption,
                        onChanged: (val) {
                          setState(() {
                            _selectedPaymentOption = val;
                          });
                        },
                      ),
                      Expanded(
                        child: Text('No Covered by\nNMA and approved'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'option3',
                        groupValue: _selectedPaymentOption,
                        onChanged: (val) {
                          setState(() {
                            _selectedPaymentOption = val;
                          });
                        },
                      ),
                      Expanded(
                        child: Text('No Further NMA\nApproval Reqd'),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'option4',
                        groupValue: _selectedPaymentOption,
                        onChanged: (val) {
                          setState(() {
                            _selectedPaymentOption = val;
                          });
                        },
                      ),
                      Expanded(
                        child: Text('fjskjf babfav\nabvkdfkv vds'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Container with Camera Icon
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return SafeArea(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.photo_camera),
                            title: Text('Take a picture'),
                            onTap: () {
                              Navigator.of(context).pop();
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.photo_library),
                            title: Text('Choose from gallery'),
                            onTap: () {
                              Navigator.of(context).pop();
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _image == null
                    ? Center(
                        child: Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey,
                        ),
                      )
                    : Image.file(
                        File(_image!.path),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                // Add submit logic here
              },
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  minimumSize:
                      Size(double.infinity, 50), // Make button full width
                  backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
