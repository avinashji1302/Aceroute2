import 'dart:io';
import 'package:ace_routes/core/Constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/file_meta_controller.dart';
import '../controller/fontSizeController.dart';
import '../controller/picUploadController.dart';

class PicUploadScreen extends StatefulWidget {
  final int eventId;
  PicUploadScreen({required this.eventId});

  @override
  State<PicUploadScreen> createState() => _PicUploadScreenState();
}

class _PicUploadScreenState extends State<PicUploadScreen> {
  final PicUploadController controller = Get.put(PicUploadController());
  final FileMetaController fileMetaController = Get.put(FileMetaController());
  final fontSizeController = Get.find<FontSizeController>();

  @override
  void initState() {
    super.initState();

    fileMetaController.fetchFileImageDataFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    AllTerms.getTerm();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AllTerms.pictureLabel.value,
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
            Obx(() {
              if (fileMetaController.fileMetaData.isEmpty) {
                return Center(child: Text('No file meta data available.'));
              }
              return _buildFileMetaDataList();
            }),

            SizedBox(height: 20),
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
  // Build file meta data list
  // Build file meta data list for images
  Widget _buildFileMetaDataList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: fileMetaController.fileMetaData.length,
      itemBuilder: (context, index) {
        final fileMeta = fileMetaController.fileMetaData[index];
        return _buildFileMetaBlock(context, index, fileMeta);
      },
    );
  }

  // Create the file metadata block (with the image name or icon)
  Widget _buildFileMetaBlock(BuildContext context, int index, var fileMeta) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(
            height: 100,
            width: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              fileMeta.fname ?? 'No Name',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // fileMetaController.deleteFileMeta(index);
              },
            ),
          ),
        ],
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