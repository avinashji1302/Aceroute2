import 'package:ace_routes/controller/get_media_file.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignatureDummy extends StatelessWidget {
  SignatureDummy({super.key});

  final GetMediaFile getMediaFile = Get.put(GetMediaFile());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signature Image")),
      body: Center(
        child: Obx(() {
          if (getMediaFile.imageUrl.isEmpty) {
            return CircularProgressIndicator(); // Show loading until image is fetched
          } else {
            return Image.network(
              getMediaFile.imageUrl.value,
              fit: BoxFit.contain,
            );
          }
        }),
      ),
    );
  }
}
