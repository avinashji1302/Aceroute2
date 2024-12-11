import 'package:flutter/material.dart';

import '../core/colors/Constants.dart';

class VoltageForm extends StatelessWidget {
  const VoltageForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Voltage Form",
          style: TextStyle(color: MyColors.whiteColor),
        ),
        backgroundColor: MyColors.blueColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
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
          padding: const EdgeInsets.all(18.0),
          child: Form(
              child: Column(
            children: [TextFormField(
              decoration: InputDecoration(
                labelText: 'CCA',
                border: OutlineInputBorder(),
              ),
            ),
              SizedBox(height: 20,),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Voltage',
                  border: OutlineInputBorder(),
                ),
              )],
          )),
        ),
      ),
    );
  }
}
