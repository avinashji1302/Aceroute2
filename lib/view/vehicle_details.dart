import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/fontSizeController.dart';

class VehicleDetails extends StatefulWidget {
  const VehicleDetails({super.key});

  @override
  State<VehicleDetails> createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails> {
  final TextEditingController _makeModelColorController = TextEditingController();
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _faultDescController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final fontSizeController = Get.find<FontSizeController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vehicle Details',
          style: TextStyle(color: Colors.white,fontSize: fontSizeController.fontSize),
        ),
        centerTitle: true,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Make/Model/Color TextFormField
              TextFormField(
                controller: _makeModelColorController,
                decoration: InputDecoration(
                  labelText: 'Make/Model/Color',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3, // Allows 3 lines of text
              ),
              SizedBox(height: 16),
        
              // Registration TextFormField
              TextFormField(
                controller: _registrationController,
                decoration: InputDecoration(
                  labelText: 'Registration',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
        
              // Odometer TextFormField
              TextFormField(
                controller: _odometerController,
                decoration: InputDecoration(
                  labelText: 'Odometer',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
        
              // Fault Description TextFormField
              TextFormField(
                controller: _faultDescController,
                decoration: InputDecoration(
                  labelText: 'Fault Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3, // Allows 3 lines of text
              ),
              SizedBox(height: 16),
        
              // Notes TextFormField
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3, // Allows 3 lines of text
              ),
              SizedBox(height: 20),
        
              // Submit Button
              ElevatedButton(
                onPressed: () {
                  // Handle submit action here
                  // You can access the input values using the controllers
                  String makeModelColor = _makeModelColorController.text;
                  String registration = _registrationController.text;
                  String odometer = _odometerController.text;
                  String faultDesc = _faultDescController.text;
                  String notes = _notesController.text;
        
                  // Perform your submission logic here
                  // For example, print the values or send them to a server
                  print('Make/Model/Color: $makeModelColor');
                  print('Registration: $registration');
                  print('Odometer: $odometer');
                  print('Fault Description: $faultDesc');
                  print('Notes: $notes');
                },
                child: Text('Submit', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Make button full width
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
