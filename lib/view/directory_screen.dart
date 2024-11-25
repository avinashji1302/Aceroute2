import 'package:ace_routes/core/Constants.dart';
import 'package:ace_routes/core/colors/Constants.dart';
import 'package:ace_routes/view/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/fontSizeController.dart';

class DirectoryDetails extends StatelessWidget {
  const DirectoryDetails({super.key});

  @override
  Widget build(BuildContext context) {
    AllTerms.getTerm();
    final fontSizeController = Get.find<FontSizeController>();
    return Scaffold(
        appBar: myAppBar(
            context: context,
            //"Directory in app which is not availbe in api data"
            titleText:AllTerms.detailsLabel,
            backgroundColor: MyColors.blueColor),
        body: Padding(
          padding: const EdgeInsets.only(top: 10.0 , left: 10 , right: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8)
            ),
            child: ListView(
              children: [
                Container(
                  color: const Color.fromARGB(255, 242, 255, 243),
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
                            color: MyColors.blueColor,
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
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSizeController.fontSize),
                            ),
                            Text(
                              'Dana Highlands Ct, Danville',
                              softWrap: true,
                              style: TextStyle(
                                  color: Colors.green[500],
                                  fontSize: fontSizeController.fontSize),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  color: const Color.fromARGB(255, 242, 255, 243),
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
                            color: MyColors.blueColor,
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
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSizeController.fontSize),
                            ),
                            Text(
                              'mobile',
                              softWrap: true,
                              style: TextStyle(
                                  color: Colors.green[500],
                                  fontSize: fontSizeController.fontSize),
                            ),
                            Text(
                              '43434324344',
                              softWrap: true,
                              style: TextStyle(
                                  color: Colors.green[500],
                                  fontSize: fontSizeController.fontSize),
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
                  color: const Color.fromARGB(255, 242, 255, 243),
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
                            color: MyColors.blueColor,
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
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSizeController.fontSize),
                            ),
                            Text(
                              ' Danville Oak Place , Danville CA',
                              softWrap: true,
                              style: TextStyle(
                                  color: Colors.green[500],
                                  fontSize: fontSizeController.fontSize),
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
                  color: const Color.fromARGB(255, 242, 255, 243),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.group,
                            color: MyColors.blueColor,
                            size: 35,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              'Department Store',
                              softWrap: true,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSizeController.fontSize),
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
