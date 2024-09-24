import 'package:flutter/material.dart';

AppBar myAppBar({
  required BuildContext context,
  required String titleText,
  required Color backgroundColor,
}) {
  return AppBar(
    title: Text(
      titleText,
      style: const TextStyle(color: Colors.white),
    ),
    centerTitle: true,
    backgroundColor: backgroundColor,
    leading: IconButton(
      icon: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
  );
}
