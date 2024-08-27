import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class BarcodeController extends GetxController {
  String result = '';
  Future<void> scanBarcode() async {
    var res = await Get.to(SimpleBarcodeScannerPage(
      lineColor: "#ff6666",
      cancelButtonText: "Cancel",
      isShowFlashIcon: true,
    ));
    result = res;
  }
}
