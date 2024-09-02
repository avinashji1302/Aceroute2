import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/fontSizeController.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  // Variables to store the selected options for each section
  String? _selectedJob;
  String? _selectedJobException;
  String? _selectedFieldException;
  String? _selectedPlan;

  final fontSizeController = Get.find<FontSizeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Status',
          style: TextStyle(color: Colors.white, fontSize: fontSizeController.fontSize),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Job', _selectedJob, (value) {
                setState(() {
                  _selectedJob = value;
                });
              }, ['Enroute', 'Start' , 'Comleted' , 'Pending Comletion']),
              _buildSection('Job Exception', _selectedJobException, (value) {
                setState(() {
                  _selectedJobException = value;
                });
              }, ['Cancel', 'Cancel with charge' , 'Follow up']),
              _buildSection('Field Exception', _selectedFieldException, (value) {
                setState(() {
                  _selectedFieldException = value;
                });
              }, ['Left Message ', 'No Access', 'Wrong Address']), // Update as needed
              _buildSection('Plan', _selectedPlan, (value) {
                setState(() {
                  _selectedPlan = value;
                });
              }, ['Scheduled', 'Confirmed', 'Rescheduled']), // Update as needed

              SizedBox(height: 20.0,),
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
              SizedBox(height: 20.0,),
            ],
          ),
        ),
      ),

    );
  }

  // Method to build each section with a header and radio buttons
  Widget _buildSection(String header, String? groupValue, ValueChanged<String?> onChanged, List<String> options) {
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0 ,),
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
                  groupValue: groupValue,
                  onChanged: onChanged,
                ),
                onTap: () {
                  onChanged(options[i]);
                },
              ),
              // Add a divider after each option except the last one
              if (i < options.length - 1) Divider(thickness: 1),
            ],
          ),
      ],
    );
  }
}
