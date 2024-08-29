import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/fontSizeController.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  // Variables to store the selected job and job change option
  String? _selectedJob;
  String? _selectedJobChange;
  final fontSizeController = Get.find<FontSizeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Status',
          style: TextStyle(color: Colors.white,fontSize: fontSizeController.fontSize),
        ),
        centerTitle: true,
       backgroundColor:  Colors.blue[900],
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
            // Job Selection
            Text(
              'Select Job:',
              style: TextStyle(fontSize: fontSizeController.fontSize, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            RadioListTile<String>(
              title: Text('Job 1',style: TextStyle(fontSize: fontSizeController.fontSize),),
              value: 'Job 1',
              groupValue: _selectedJob,
              onChanged: (value) {
                setState(() {
                  _selectedJob = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Job 2',style: TextStyle(fontSize: fontSizeController.fontSize),),
              value: 'Job 2',
              groupValue: _selectedJob,
              onChanged: (value) {
                setState(() {
                  _selectedJob = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Job 3',style: TextStyle(fontSize: fontSizeController.fontSize),),
              value: 'Job 3',
              groupValue: _selectedJob,
              onChanged: (value) {
                setState(() {
                  _selectedJob = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Job 4',style: TextStyle(fontSize: fontSizeController.fontSize),),
              value: 'Job 4',
              groupValue: _selectedJob,
              onChanged: (value) {
                setState(() {
                  _selectedJob = value;
                });
              },
            ),
            SizedBox(height: 20),

            // Job Change Options
            if (_selectedJob != null) ...[
              Text(
                'Change Job Option:',
                style: TextStyle(fontSize: fontSizeController.fontSize, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              RadioListTile<String>(
                title: Text('Change Option 1',style: TextStyle(fontSize: fontSizeController.fontSize),),
                value: 'Change Option 1',
                groupValue: _selectedJobChange,
                onChanged: (value) {
                  setState(() {
                    _selectedJobChange = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('Change Option 2',style: TextStyle(fontSize: fontSizeController.fontSize),),
                value: 'Change Option 2',
                groupValue: _selectedJobChange,
                onChanged: (value) {
                  setState(() {
                    _selectedJobChange = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('Change Option 3',style: TextStyle(fontSize: fontSizeController.fontSize),),
                value: 'Change Option 3',
                groupValue: _selectedJobChange,
                onChanged: (value) {
                  setState(() {
                    _selectedJobChange = value;
                  });
                },
              ),
              SizedBox(height: 20),
            ],

            // Change Button
            ElevatedButton(
              onPressed: () {
                // Handle change action here
                if (_selectedJob != null && _selectedJobChange != null) {
                  // Do something with the selected job and job change options
                  print('Selected Job: $_selectedJob');
                  print('Selected Change Option: $_selectedJobChange');
                } else {
                  // Show a message if either selection is missing
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select both job and change option.')),
                  );
                }
              },
              child: Text('Change', style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Full width button
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
