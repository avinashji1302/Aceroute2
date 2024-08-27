import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/fontSizeController.dart';
import '../controller/picUploadController.dart';

class PicUploadScreen extends StatelessWidget {
  PicUploadScreen({Key? key}) : super(key: key);

  // Initialize the controller using Get.put() to make it available throughout the app
  final PicUploadController controller = Get.put(PicUploadController());
  final fontSizeController = Get.find<FontSizeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Picture Upload',
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
            controller.clearImages();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: controller
                  .pickImage, // Call the pickImage method from the controller
              icon: Icon(Icons.camera_alt),
              label: Text(
                'Take Picture',
                style: TextStyle(fontSize: fontSizeController.fontSize),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Obx(
                () => GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: controller.images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: () {
                        // Toggle selection on long press
                        controller.toggleSelection(index);
                      },
                      onTap: () {
                        controller.clearSelection();
                      },
                      child: Obx(() {
                        // Highlight the selected image
                        bool isSelected =
                            controller.selectedIndices.contains(index);

                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.red
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: Image.file(
                                File(controller.images[index].path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    // Delete the image
                                    controller.deleteImage(index);
                                  },
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor:
                                        Colors.red.withOpacity(0.7),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
