import 'package:ace_routes/Widgets/update_version_dailog.dart';
import 'package:ace_routes/database/Tables/api_data_table.dart';
import 'package:ace_routes/database/Tables/login_response_table.dart';
import 'package:ace_routes/database/Tables/version_api_table.dart';
import 'package:ace_routes/database/databse_helper.dart';
import 'package:ace_routes/model/login_model/login_response.dart';
import 'package:ace_routes/model/login_model/version_model.dart';
import 'package:ace_routes/model/login_model/token_get_model.dart';
import 'package:ace_routes/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubnub/pubnub.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:async';
import 'package:xml/xml.dart';
// import 'package:xml/xml.dart';
import 'package:xml/xml.dart' as xml;

class LoginController extends GetxController {
  var accountName = ''.obs;
  var workerId = ''.obs;
  var password = ''.obs;
  var rememberMe = false.obs;
  var accountNameError = ''.obs;
  var workerIdError = ''.obs;
  var passwordError = ''.obs;
  var isPasswordVisible = false.obs;

  var isLoading = false.obs; // Change this to an observable

  PubNub? pubNub;
  String? sessionToken;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login(BuildContext context) async {
    isLoading.value = true; // Start loading

    print('login clicked');
    if (_validateInputs()) {
      print("accountName ${accountName}");
      print("work ${workerId} ${password}");

      try {
        final response = await http.get(Uri.parse(
            'https://portal.aceroute.com/login?&nsp=${accountName}&tid=mobi'));

        if (response.statusCode == 200) {
          final xmlResponse = XmlDocument.parse(response.body);

          final nsp = xmlResponse.findAllElements('nsp').single.text;
          final url = xmlResponse.findAllElements("url").single.text;
          final subkey = xmlResponse.findAllElements('subkey').single.text;

          // Now fetch user-specific data
          await _fetchUserData(url);

          print(' logging in key : ${subkey}  and ${url}');

          // storing in database;

          LoginResponse loginResponse =
              LoginResponse(nsp: nsp, url: url, subkey: subkey);

          // await DatabaseHelper().insertLoginResponse(loginResponse);
          await LoginResponseTable.insertLoginResponse(loginResponse);

          print(' logging in key : ${subkey}  and ${url} stored successylly');

          // Initialize PubNub with subkey
          pubNub = PubNub(
              defaultKeyset: Keyset(
            subscribeKey: 'sub-c-d9f560e0-4e4c-46ed-9cdd-c81a0242552d',
            publishKey: 'pub-c-ec0b05d7-0d9c-4fc0-b48f-1e43e7b34486',
            uuid: UUID(accountName.value),
          ));

          // After successful login, navigate to the next screen
          // Get.to(HomeScreen()); //
        } else {
          // Handle error
          print('Error logging in');
        }
      } catch (e) {
        print('Exception during login: $e');
      } finally {
        isLoading.value =
            false; // Stop loading regardless of success or failure
      }
    } else {
      isLoading.value = false; // Stop loading if validation fails
    }
  }

  Future<void> _fetchUserData(String url) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      print('Fetching data>>>>:');

      // API call
      final response = await http.get(Uri.parse(
          'https://portal.aceroute.com/mobi?&geo=0.0,0.0&os=2&pcode=${password.value}&nspace=${accountName}&action=mlogin&rid=${workerId.value}&cts=1728382466217'));

      if (response.statusCode == 200) {
        final xmlResponse = XmlDocument.parse(response.body);

        // Safely check if the elements exist
        final tokenElement = xmlResponse.findAllElements('token');
        final ridElement = xmlResponse.findAllElements('rid');
        final resnmElement = xmlResponse.findAllElements('resnm');
        final geoElement = xmlResponse.findAllElements('geo');
        final nspidElement = xmlResponse.findAllElements('nspid');
        final gpssyncElement = xmlResponse.findAllElements('gpssync');
        final locchgElement = xmlResponse.findAllElements('locchg');
        final shfdtlockElement = xmlResponse.findAllElements('shfdtlock');
        final shfterrElement = xmlResponse.findAllElements('shfterr');
        final ednElement = xmlResponse.findAllElements('edn');
        final spdElement = xmlResponse.findAllElements('spd');
        final mltlegElement = xmlResponse.findAllElements('mltleg');
        final uiconfigElement = xmlResponse.findAllElements('uiconfig');

        print('Token: $tokenElement, RID: $ridElement $resnmElement');

        if (tokenElement.isNotEmpty && ridElement.isNotEmpty) {
          final token = tokenElement.single.text; // New token from the API
          final rid = int.parse(ridElement.single.text);
          final responderName = resnmElement.single.text;
          final geoLocation = geoElement.single.text;
          final nspId = nspidElement.single.text;
          final gpsSync = gpssyncElement.single.text;
          final locationChange = locchgElement.single.text;
          final shiftDateLock = shfdtlockElement.single.text;
          final shiftError = shfterrElement.single.text;
          final endValue = ednElement.single.text;
          final speed = spdElement.single.text;
          final multiLeg = mltlegElement.single.text;
          final uiConfig = uiconfigElement.single.text;

          // Save to SharedPreferences and update the token
          await prefs.setString("token", token); // This replaces the old token
          await prefs.setInt("rid", rid);
          await prefs.setString("responderName", responderName);
          await prefs.setString("geoLocation", geoLocation);

          // Parse response into ApiResponse model
          TokenApiReponse apiResponse = TokenApiReponse(
            requestId: rid,
            responderName: responderName,
            geoLocation: geoLocation,
            nspId: nspId, // Example value (replace as needed)
            gpsSync: 10, // Example value (replace as needed)
            locationChange: 500, // Example value (replace as needed)
            shiftDateLock: 0, // Example value (replace as needed)
            shiftError: 0, // Example value (replace as needed)
            endValue: 500, // Example value (replace as needed)
            speed: 45, // Example value (replace as needed)
            multiLeg: 0, // Example value (replace as needed)
            uiConfig: uiConfig, // Example value (replace as needed)
            token: token,
          );

          print("token in login : $token  rid $rid userid $workerId");

          // Store the data in SQLite database
          await ApiDataTable.insertData(apiResponse);
          print('Data successfully stored in the database');

          // Perform any additional checks or actions
          await checkTheLatestVersion(url, token);
        } else {
          print('One or more elements are missing: token, rid, resnm, or geo');
        }
      } else {
        print('Error: Status code ${response.statusCode} during fetching data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

// Validating the login inputs
  bool _validateInputs() {
    accountNameError.value = accountName.isEmpty ? 'Account name required' : '';
    workerIdError.value = workerId.isEmpty ? 'Worker ID required' : '';
    passwordError.value = password.isEmpty ? 'Password required' : '';

    return accountNameError.isEmpty &&
        workerIdError.isEmpty &&
        passwordError.isEmpty;
  }

  Future<void> checkTheLatestVersion(String url, String token) async {
    try {
      // Construct the API URL with token
      // final apiUrl = '$url?token=$token';

      // Make the API request
      final response = await http.get(Uri.parse(
          "https://${url}/mobi?token=${token}&nspace=demo.com&geo=<lat,lon>&rid=136675&action=getmversion"));

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Parse the XML response
        final xmlDocument = xml.XmlDocument.parse(response.body);

        // Extract the version (id) from the XML
        String versionId = xmlDocument.findAllElements('id').single.text.trim();
        final success = xmlDocument.findAllElements('success').single.text;

        print(versionId);
        print(success);

        // String versionId = versionIdElement.text.trim();
        // bool success = successElement.single.text;

        // Parse response into ApiResponse model
        VersionModel versionModel =
            VersionModel(success: success, id: versionId);

        // save to database;
        await VersionApiTable.insertVersionData(versionModel);
        print('Data successfully insert versiuo');

        // Get the installed app version
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;

        print('Fetched version from API: $versionId');
        print('Current installed version: $currentVersion');

        // Normalize versions to ensure they have a minor and patch version
        versionId = _normalizeVersion(versionId);
        currentVersion = _normalizeVersion(currentVersion);

        // Parse the versions using the Version class
        final apiVersion = Version.parse(versionId);
        final installedVersion = Version.parse(currentVersion);

        // Compare the API version with the installed version
        if (apiVersion > installedVersion) {
          // If the API version is greater, prompt the user to update the app
          print('App is not up to date.');
          // showUpdateDialog();
          // Show the update dialog if an update is available
          // Get.dialog(UpdateDialog(onUpdate: _navigateToPlayStore));
          await displayDataFromDb();
          Get.to(HomeScreen());

          // Database is here storeing the data
        } else {
          print('App is up to date.');
        }
      } else {
        // Handle API error response
        print('Failed to fetch data from API: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Error occurred: $e');
    }
  }

// Helper function to normalize version strings
  String _normalizeVersion(String version) {
    // Ensure the version string has a minor and patch version
    List<String> parts = version.split('.');
    while (parts.length < 3) {
      parts.add('0'); // Append .0 for missing parts
    }
    return parts.join('.');
  }

  // Method to open the Play Store link
  void _navigateToPlayStore() async {
    //  const url = 'https://play.google.com/store/apps/details?id=com.example.app'; // Replace with your app's Play Store link
    const url = "https://play.google.com/store/search?q=aceroute&c=apps";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  Future<void> displayDataFromDb() async {
    List<TokenApiReponse> dataList = await ApiDataTable.fetchData();

    // Convert the list of data to a string representation
    StringBuffer buffer = StringBuffer();
    buffer.writeln('--- Start of Table ---');

    for (var data in dataList) {
      buffer.writeln(
          'ID: ${data.requestId}, Responder Name: ${data.responderName}, GeoLocation: ${data.geoLocation}, Speed: ${data.speed}, Other Field 2: ${data.multiLeg}');
    }

    buffer.writeln('--- End of Table ---');

    // Print the whole table at once
    print(buffer.toString());

    for (var data in dataList) {
      print('Responder Name:  ${data.responderName}');
      print('GeoLocation: ${data.geoLocation}');
    }
  }
}
