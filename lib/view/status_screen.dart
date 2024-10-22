import 'package:ace_routes/controller/loginController.dart';
import 'package:ace_routes/core/colors/Constants.dart';
import 'package:ace_routes/view/appbar.dart';
import 'package:ace_routes/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/status_controller.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  String? _selectedJob;
  String? _selectedJobException;
  String? _selectedFieldException;
  String? _selectedPlan;
  // String selectedJob = ''.obs as String;

  final statusController = Get.put(StatusController());
  final LoginController loginController =
      Get.find<LoginController>(); // Accessing LoginController

  @override
  void initState() {
    super.initState();
    // Fetch the status list when the screen initializes
    statusController.fetchStatusList();
  }

  void publishTestMessage(message) async {
    print("Published message is $message");
    await loginController.pubNub?.publish(
      'status-channel', // Channel name
      {'status': message}, // Message payload
    );
    print("Test message published to status-channel.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(
        context: context,
        titleText: 'Status',
        backgroundColor: MyColors.blueColor,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Job', _selectedJob, (value) {
                  setState(() {
                    _deselectAll(); // Deselect everything
                    _selectedJob = value;
                    print("Selected Plan: $_selectedPlan  ");
                    publishTestMessage(value);

                    Get.to(HomeScreen());
                  });
                }, statusController.jobStatusOptions),
                _buildSection('Job Exception', _selectedJobException, (value) {
                  setState(() {
                    _deselectAll(); // Deselect everything
                    _selectedJobException = value;
                    print("Selected Plan: $_selectedPlan  ");
                    publishTestMessage(value);

                    Get.to(HomeScreen());
                  });
                }, statusController.jobExceptionOptions),
                _buildSection('Field Exception', _selectedFieldException,
                    (value) {
                  setState(() {
                    _deselectAll(); // Deselect everything
                    _selectedFieldException = value;

                    print("Selected Plan: $_selectedPlan  ");
                    publishTestMessage(value);

                    Get.to(HomeScreen());
                  });
                }, statusController.fieldExceptionOptions),
                _buildSection('Plan', _selectedPlan, (value) {
                  setState(() {
                    _selectedPlan = value;
                    // selectedJob = _selectedPlan! ;
                    print("Selected Plan: $_selectedPlan  ");
                    publishTestMessage(value);

                    Get.to(HomeScreen());
                    _deselectAll(); // Deselect everything
                  });
                }, statusController.planOptions),
                SizedBox(
                  height: 20.0,
                ),
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
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Method to build each section with a header and radio buttons
  Widget _buildSection(String header, String? groupValue,
      ValueChanged<String?> onChanged, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey[300],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              header,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ),
        Divider(thickness: 1),
        for (int i = 0; i < options.length; i++)
          Column(
            children: [
              ListTile(
                title: Text(options[i]),
                trailing: Radio<String>(
                  value: options[i],
                  groupValue: groupValue, // Ensures only one selection
                  onChanged: onChanged, // Update the selected value
                ),
              ),
              if (i < options.length - 1) Divider(thickness: 1),
            ],
          ),
      ],
    );
  }

  // Helper method to deselect all options
  void _deselectAll() {
    _selectedJob = null;
    _selectedJobException = null;
    _selectedFieldException = null;
    _selectedPlan = null;
  }
}
