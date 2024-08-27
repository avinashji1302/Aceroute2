import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;
import 'package:ace_routes/controller/fontSizeController.dart';
import 'package:ace_routes/controller/signature_controller.dart';

class Signature extends StatelessWidget {
  final fontSizeController = Get.find<FontSizeController>();
  final SignatureController signatureController =
      Get.put(SignatureController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Signature here',
          style: TextStyle(
              color: Colors.white, fontSize: fontSizeController.fontSize),
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
      body: Container(
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            height: 10,
          ),
          Text(
            "Sign here",
            style: TextStyle(
                color: Colors.black, fontSize: fontSizeController.fontSize),
          ),
          GestureDetector(
              onTap: () {
                _showSignatureDialog(context);
              },
              child: Icon(Icons.edit)),
          SizedBox(height: 20),
          Obx(() => signatureController.signatures.isNotEmpty
              ? Column(
                  children: signatureController.signatures
                      .asMap()
                      .entries
                      .map((entry) =>
                          _buildSignatureDisplay(entry.key, entry.value))
                      .toList())
              : SizedBox.shrink()),
        ]),
      ),
    );
  }

  void _showSignatureDialog(BuildContext context) {
    final _signaturePadKey = GlobalKey<SfSignaturePadState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Draw your signature'),
          content: Container(
            height: 300,
            width: double.maxFinite,
            child: SfSignaturePad(
              key: _signaturePadKey,
              backgroundColor: Colors.grey[200],
              strokeColor: Colors.black,
              minimumStrokeWidth: 1.0,
              maximumStrokeWidth: 4.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final signature =
                    await _signaturePadKey.currentState?.toImage();
                if (signature != null) {
                  signatureController.addSignature(signature);
                }
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSignatureDisplay(int index, ui.Image signature) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(
            height: 100,
            width: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: RawImage(
              image: signature,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                signatureController.deleteSignature(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
