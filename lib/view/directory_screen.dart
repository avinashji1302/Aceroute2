
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/fontSizeController.dart';

class DirectoryDetails extends StatelessWidget {
  const DirectoryDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final fontSizeController = Get.find<FontSizeController>();
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title:  Text('DirectoryDetails', style: TextStyle(color: Colors.white,fontSize: fontSizeController.fontSize)),
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
        body: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Container(
            child: ListView(
              children: [
                Container(
                  color: Color.fromARGB(255, 216, 212, 199),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.location_on_sharp,
                            color: const Color.fromARGB(255, 7, 103, 147),
                            size: 35,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dana Highlands Ct, Danville',
                              softWrap: true,
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: fontSizeController.fontSize),
                            ),
                            Text(
                              'Dana Highlands Ct, Danville',
                              softWrap: true,
                              style: TextStyle(fontSize: fontSizeController.fontSize),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  color: Color.fromARGB(255, 216, 212, 199),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.person,
                            color: const Color.fromARGB(255, 7, 103, 147),
                            size: 35,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dan',
                              softWrap: true,
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: fontSizeController.fontSize),
                            ),
                            Text(
                              'mobile',
                              softWrap: true,
                              style: TextStyle(fontSize: fontSizeController.fontSize),
                            ),
                            Text(
                              '43434324344',
                              softWrap: true,
                              style: TextStyle(fontSize: fontSizeController.fontSize),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  color: Color.fromARGB(255, 216, 212, 199),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: const Color.fromARGB(255, 7, 103, 147),
                            size: 35,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ' Danville Oak Place , Danville CA',
                              softWrap: true,
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: fontSizeController.fontSize),
                            ),
                            Text(
                              ' Danville Oak Place , Danville CA',
                              softWrap: true,
                              style: TextStyle(fontSize: fontSizeController.fontSize),

                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  color: Color.fromARGB(255, 216, 212, 199),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.group,
                            color: const Color.fromARGB(255, 7, 103, 147),
                            size: 35,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              'Department Store',
                              softWrap: true,
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: fontSizeController.fontSize),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
