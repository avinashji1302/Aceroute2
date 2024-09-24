import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/fontSizeController.dart';
import '../controller/picUploadController.dart';

class PicUploadScreen extends StatelessWidget {
  PicUploadScreen({Key? key}) : super(key: key);

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
        backgroundColor: Colors.blue[900],
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
            Expanded(
              child: Obx(() {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: controller.images.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.images.length) {
                      return GestureDetector(
                        onTap: controller.pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey[800],
                            size: 50,
                          ),
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          // Open the full-screen view of the image
                          Get.to(() => FullScreenImageView(
                              image: File(controller.images[index].path)));
                        },
                        onLongPress: () {
                          controller.toggleSelection(index);
                        },
                        child: Obx(() {
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(controller.images[index].path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () {
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
                    }
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final File image;

  FullScreenImageView({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Center(
          child: Image.file(
            image,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
