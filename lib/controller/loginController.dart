import 'package:ace_routes/model/login_model.dart';
import 'package:ace_routes/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pubnub/pubnub.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'package:xml/xml.dart';

class LoginController extends GetxController {
  var accountName = 'demo.com'.obs;
  var workerId = ''.obs;
  var password = ''.obs;
  var rememberMe = false.obs;
  var accountNameError = ''.obs;
  var workerIdError = ''.obs;
  var passwordError = ''.obs;
  var isPasswordVisible = false.obs;

  PubNub? pubNub;
  String? sessionToken;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login(BuildContext context) async {
    if (_validateInputs()) {
      try {
        final response = await http.get(Uri.parse(
            'https://portal.aceroute.com/login?&nsp=demo.com&tid=mobi'));

        if (response.statusCode == 200) {
          final loginResponse = LoginResponse.fromXml(response.body);
          // Initialize PubNub with subkey
          print(' logging in key : ${loginResponse.subkey}');
          pubNub = PubNub(
              defaultKeyset: Keyset(
            subscribeKey: 'sub-c-d9f560e0-4e4c-46ed-9cdd-c81a0242552d',
            publishKey: 'pub-c-ec0b05d7-0d9c-4fc0-b48f-1e43e7b34486',
            uuid: UUID(accountName.value),
          ));

          // Now fetch user-specific data
          await _fetchUserData();

          // After successful login, navigate to the next screen
          Get.to(HomeScreen()); //
        } else {
          // Handle error
          print('Error logging in');
        }
      } catch (e) {
        print('Exception during login: $e');
      }
    }
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      print('fetching data>>>>:');

      final response = await http.get(Uri.parse(
          'https://portal.aceroute.com/mobi?&geo=0.0,0.0&os=2&pcode=${password.value}&nspace=demo.com&action=mlogin&rid=${workerId.value}&cts=1728382466217'));

      if (response.statusCode == 200) {
        final xmlResponse = XmlDocument.parse(response.body);

        // Safely check if the elements exist
        final tokenElement = xmlResponse.findAllElements('token');
        final ridElement = xmlResponse.findAllElements('rid');
        final nspaceElement = xmlResponse.findAllElements('nspace');

        print(
            'Token: $tokenElement, RID: $ridElement, Namespace: $nspaceElement');
        if (tokenElement.isNotEmpty && ridElement.isNotEmpty) {
          final token = tokenElement.single.text;
          final rid = ridElement.single.text;
          final nspace = "demo.com";

          sessionToken = token;
          print(' response: ${xmlResponse}');
          print('Token: $token, RID: $rid, Namespace: $nspace');

          prefs.setString("token", token);
          prefs.setInt("rid", int.parse(rid)); // Ensure to parse rid to int
          prefs.setString("nspace", nspace);
        } else {
          print('One or more elements are missing: token, rid, or nspace');
        }
      } else {
        print('Error: Status code ${response.statusCode} during fetching data');
      }
    } catch (e) {
      print('Error in e: $e');
    }
  }

  bool _validateInputs() {
    accountNameError.value = accountName.isEmpty ? 'Account name required' : '';
    workerIdError.value = workerId.isEmpty ? 'Worker ID required' : '';
    passwordError.value = password.isEmpty ? 'Password required' : '';

    return accountNameError.isEmpty &&
        workerIdError.isEmpty &&
        passwordError.isEmpty;
  }
}
