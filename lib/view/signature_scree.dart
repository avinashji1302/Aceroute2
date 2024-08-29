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
  final RxInt currentBlock = 0.obs; // Track the current signature block

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Signature',
          style: TextStyle(
              color: Colors.white, fontSize: fontSizeController.fontSize),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 76, 81, 175),
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
        child: Obx(() {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate((currentBlock.value ~/ 2) + 1, (rowIndex) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(2, (index) {
                      int blockIndex = rowIndex * 2 + index;
                      return blockIndex <= currentBlock.value
                          ? _buildSignatureBlock(context, blockIndex)
                          : SizedBox.shrink();
                    }),
                  );
                }),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSignatureBlock(BuildContext context, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _showSignatureDialog(context, index);
          },
          child: Obx(() {
            return Icon(
              Icons.edit,
              size: 30,
              color: (index == currentBlock.value &&
                  signatureController.signatures.length <= index)
                  ? Colors.black
                  : Colors.transparent,
            );
          }),
        ),
        SizedBox(height: 5.0),
        Obx(() => signatureController.signatures.length > index
            ? _buildSignatureDisplay(index, signatureController.signatures[index])
            : SizedBox.shrink()),
        SizedBox(height: 5.0),
      ],
    );
  }

  void _showSignatureDialog(BuildContext context, int index) {
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
                  currentBlock.value++; // Move to the next block
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
            width: 150,
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
                currentBlock.value = index; // Re-enable the block for signing
              },
            ),
          ),
        ],
      ),
    );
  }
}
