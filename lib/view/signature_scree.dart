import 'package:ace_routes/core/Constants.dart';
import 'package:ace_routes/core/colors/Constants.dart';
import 'package:ace_routes/view/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;
import 'package:ace_routes/controller/signature_controller.dart'; // Ensure correct import

class Signature extends StatelessWidget {
  final SignatureController signatureController =
      Get.put(SignatureController()); // Correct controller initialization
  final RxInt currentBlock = 0.obs; // Track the current signature block

  @override
  Widget build(BuildContext context) {
    AllTerms.getTerm();
    return Scaffold(
      appBar: myAppBar(
          context: context,
          titleText: AllTerms.signatureLabel,
          backgroundColor: MyColors.blueColor),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wrapping only the widget that will update
              Obx(() => _buildSignatureGrid(context)),
              SizedBox(height: 20),
              _buildAddSignatureButton(context), // No need to wrap this in Obx
            ],
          ),
        ),
      ),
    );
  }

  // Build the signature grid using Wrap widget
  Widget _buildSignatureGrid(BuildContext context) {
    // Wrap only the part that depends on the observable
    if (signatureController.signatures.isEmpty) {
      return Center(
        child: Text('No signatures added yet.'),
      );
    }

    // Use Wrap widget to show signatures in a row
    return Wrap(
      spacing: 16.0, // Horizontal space between items
      runSpacing: 16.0, // Vertical space between rows
      children: List.generate(signatureController.signatures.length, (index) {
        return _buildSignatureBlock(context, index);
      }),
    );
  }

  Widget _buildSignatureBlock(BuildContext context, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            _showSignatureDialog(context, index); // Open signature dialog
          },
          child: Obx(() {
            // Wrap only the Icon in Obx since it uses an observable
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
        Obx(() {
          // Wrap only the part that depends on observable
          return signatureController.signatures.length > index
              ? _buildSignatureDisplay(
                  index, signatureController.signatures[index])
              : SizedBox.shrink();
        }),
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
            width: 150, // Ensure a fixed width for signature blocks
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

  Widget _buildAddSignatureButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (signatureController.signatures.length <
              signatureController.maxSignatures) {
            _showSignatureDialog(
                context, currentBlock.value); // Open dialog to add signature
          } else {
            Get.snackbar(
              'Limit Reached',
              'You have reached the maximum number of signatures',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        child: Text('Add Signature'),
      ),
    );
  }
}
