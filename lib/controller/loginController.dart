import 'dart:convert';
import 'dart:io';

import 'package:ace_routes/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pubnub/pubnub.dart';
import 'package:xml/xml.dart' as xml;

class LoginController extends GetxController {
  var accountName = ''.obs;
  var workerId = ''.obs;
  var password = ''.obs;
  var isPasswordVisible = false.obs;
  var rememberMe = false.obs;

  var accountNameError = ''.obs;
  var workerIdError = ''.obs;
  var passwordError = ''.obs;
  final loginUrl =
      "https://portal.aceroute.com/login?&nsp=demo.com&tid=mobi&token=FoZpRr7ixJ3Ppmmru2ejE%2FBhjBuZp3BTkNbtotGq%2BHXDr%2BdjKRC3zl98mQWfnvDuzlJ9g3Sv1%2B8V17QnoV1xKlnSI4UCgNRgV9JxDh3w094sT9lpHGJb%2BjukeabwtALcInN5hDkjW%2FjxZo7VMjWUoI%2FQrJvTPM9CKgwFpVMY%2BI4%3D&nspace=demo.com&rid=136675&pssCode=fdfs";

//pubnub
  //
  PubNub? pubnub;
  String? nsp;
  String? url;
  String? subkey;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  bool validateFields() {
    bool isValid = true;

    if (accountName.value.isEmpty) {
      accountNameError.value = 'This field is required';
      isValid = false;
    } else {
      accountNameError.value = '';
    }

    if (workerId.value.isEmpty) {
      workerIdError.value = 'This field is required';
      isValid = false;
    } else {
      workerIdError.value = '';
    }

    if (password.value.isEmpty) {
      passwordError.value = 'This field is required';
      isValid = false;
    } else {
      passwordError.value = '';
    }

    return isValid;
  }

  void login(BuildContext context) async {
    if (validateFields()) {
      try {
        final response = await http.get(Uri.parse(loginUrl));

        if (response.statusCode == 200) {
          print('Login successful: ${response.body}');
          final xmlResponse = response.body;

          final document = xml.XmlDocument.parse(xmlResponse);
          // nsp = document.findAllElements('nsp').first.text;
          // url = document.findAllElements('url').first.text;
          subkey = document.findAllElements('subkey').first.text;

          print(subkey);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          print('Failed to login. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print("Error is : $e");
      }
    }
  }

  void clearFields() {
    accountName.value = '';
    workerId.value = '';
    password.value = '';
    isPasswordVisible.value = false;
    rememberMe.value = false;

    accountNameError.value = '';
    workerIdError.value = '';
    passwordError.value = '';
  }
}
