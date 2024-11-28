import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/vehicle_controller.dart';
import '../controller/fontSizeController.dart';
import '../core/Constants.dart';
import '../core/colors/Constants.dart';
import '../view/appbar.dart';

class VehicleDetails extends StatefulWidget {
  final String id;

  VehicleDetails({super.key, required this.id});

  @override
  State<VehicleDetails> createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails> {
  final fontSizeController = Get.find<FontSizeController>();
  late final VehicleController _vehicleController;

  @override
  void initState() {
    super.initState();
    // Initialize VehicleController with the provided id
    _vehicleController = Get.put(VehicleController(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    AllTerms.getTerm();
    return Scaffold(
      appBar: myAppBar(
        context: context,
        titleText: AllTerms.orderGroupLabel,
        backgroundColor: MyColors.blueColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Make/Model/Color TextFormField
              Obx(() => TextFormField(
                    controller: TextEditingController(
                        text: _vehicleController.vehicleDetail.value),
                    decoration: InputDecoration(
                      labelText: 'Make/Model/Color',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) =>
                        _vehicleController.vehicleDetail.value = value,
                  )),
              SizedBox(height: 16),

              // Registration TextFormField
              Obx(() => TextFormField(
                    controller: TextEditingController(
                        text: _vehicleController.registration.value),
                    decoration: InputDecoration(
                      labelText: 'Registration',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        _vehicleController.registration.value = value,
                  )),
              SizedBox(height: 16),

              // Odometer TextFormField
              Obx(() => TextFormField(
                    controller: TextEditingController(
                        text: _vehicleController.odometer.value),
                    decoration: InputDecoration(
                      labelText: 'Odometer',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        _vehicleController.odometer.value = value,
                  )),
              SizedBox(height: 16),

              // Fault Description TextFormField
              Obx(() => TextFormField(
                    controller: TextEditingController(
                        text: _vehicleController.faultDesc.value),
                    decoration: InputDecoration(
                      labelText: 'Fault Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) =>
                        _vehicleController.faultDesc.value = value,
                  )),
              SizedBox(height: 16),

              // Notes TextFormField
              Obx(() => TextFormField(
                    controller: TextEditingController(
                        text: _vehicleController.notes.value),
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) =>
                        _vehicleController.notes.value = value,
                  )),
              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  print("Vehicle details: ${_vehicleController.vehicleDetail}");
                  print("Registration: ${_vehicleController.registration}");
                  print("Odometer: ${_vehicleController.odometer}");
                  print("Fault Description: ${_vehicleController.faultDesc}");
                },
                child: Text('Submit', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
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
