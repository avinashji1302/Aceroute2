import 'dart:io';

import 'package:ace_routes/core/colors/Constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/addBwForm_controller.dart';
import '../controller/fontSizeController.dart';
import '../model/GTypeModel.dart';

class AddBwForm extends StatefulWidget {
  final GTypeModel gType;

  const AddBwForm({Key? key, required this.gType}) : super(key: key);

  @override
  State<AddBwForm> createState() => _AddBwFormState();
}

class _AddBwFormState extends State<AddBwForm> {
  final controller = Get.put(AddBwFormController());

  @override
  void initState() {
    super.initState();
    controller.initializeTextControllers(widget.gType.details['frm']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.gType.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: MyColors.blueColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Dynamically generate form fields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.gType.details['frm'].map<Widget>((item) {
                  if (item['nm'] == 'tech') {
                    return buildTextField(item);
                  } else if (item['nm'] == 'payment') {
                    return buildRadioOptions(item);
                  } else if (item['nm'] == 'safety') {
                    return buildImagePicker(item);
                  } else if (item['nm'] == 'dpayment') {
                    return buildMultiSelectOptions(item);
                  } else {
                    return Container();
                  }
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  // Add submit logic here
                  print("Submitted Values:");
                  print(
                      "Text: ${controller.textEditingControllers['tech']?.text}");
                  print("Selected Radio: ${controller.selectedValue.value}");
                  print("Selected Multi: ${controller.selectedValues}");
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TextField for technician name
  Widget buildTextField(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller.textEditingControllers[item['nm']],
        decoration: InputDecoration(
          labelText: item['lbl'],
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // Radio buttons for payment options
  Widget buildRadioOptions(Map<String, dynamic> item) {
    List<String> options = item['ddn'].split(',');
    List<String> values = item['ddnval'].split(',');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item['lbl'],
              style: const TextStyle(fontWeight: FontWeight.bold)),
          ...List.generate(options.length, (index) {
            return Obx(
              () => RadioListTile<String>(
                title: Text(options[index]),
                value: values[index],
                groupValue: controller.selectedValue.value,
                onChanged: (newValue) {
                  controller.selectedValue.value = newValue!;
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // Multi-select for payment options
  Widget buildMultiSelectOptions(Map<String, dynamic> item) {
    List<String> options = item['ddn'].split(',');
    List<String> values = item['ddnval'].split(',');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item['lbl'],
              style: const TextStyle(fontWeight: FontWeight.bold)),
          ...List.generate(options.length, (index) {
            return Obx(
              () => CheckboxListTile(
                title: Text(
                  options[index],
                  style: TextStyle(
                    color: controller.selectedValues.contains(values[index])
                        ? Colors.blue
                        : Colors.black,
                  ),
                ),
                value: controller.selectedValues.contains(values[index]),
                onChanged: (isSelected) {
                  if (isSelected == true) {
                    controller.selectedValues.add(values[index]);
                  } else {
                    controller.selectedValues.remove(values[index]);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // Image picker for safety
  Widget buildImagePicker(Map<String, dynamic> item) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(item['lbl'], style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (_) {
                return SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_camera),
                        title: const Text('Take a picture'),
                        onTap: () {
                          Navigator.of(context).pop();
                          controller.pickImage(ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Choose from gallery'),
                        onTap: () {
                          Navigator.of(context).pop();
                          controller.pickImage(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Obx(
            () => Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: controller.selectedImage.value == null
                  ? const Center(
                      child:
                          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                    )
                  : Image.file(
                      File(controller.selectedImage.value!.path),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
