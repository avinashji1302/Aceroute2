
import 'package:ace_routes/view/add_bw_from.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../controller/fontSizeController.dart';

class EFormScreen extends StatefulWidget {
  const EFormScreen({super.key});

  @override
  State<EFormScreen> createState() => _EFormScreenState();
}

class _EFormScreenState extends State<EFormScreen> {
  final fontSizeController = Get.find<FontSizeController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EFrom',style: TextStyle(color: Colors.white),),
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
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline,color: Colors.white,size: 40.0,),
            onPressed: () {
              Get.to(AddBwForm());

            },
          ),
        ],
      ),
      body: Container(
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
                        'BW Form ',
                        style: TextStyle(
                            fontSize: fontSizeController.fontSize,
                            fontWeight: FontWeight.bold),
                      ),

                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'tested',
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
                        'Yes I have added payment for c...',
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
    );
  }
}
