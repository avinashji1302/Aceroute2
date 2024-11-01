import 'package:ace_routes/Widgets/error_handling_login.dart';
import 'package:ace_routes/Widgets/update_version_dailog.dart';
import 'package:ace_routes/database/Tables/api_data_table.dart';
import 'package:ace_routes/database/Tables/login_response_table.dart';
import 'package:ace_routes/database/Tables/version_api_table.dart';
import 'package:ace_routes/database/databse_helper.dart';
import 'package:ace_routes/model/login_model/login_response.dart';
import 'package:ace_routes/model/login_model/version_model.dart';
import 'package:ace_routes/model/login_model/token_api_response.dart';
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

          // storing in database;

          LoginResponse loginResponse =
              LoginResponse(nsp: nsp, url: url, subkey: subkey);

          // await DatabaseHelper().insertLoginResponse(loginResponse);
          await LoginResponseTable.insertLoginResponse(loginResponse);

          // Now fetch user-specific data
          await _fetchUserData(context, url);

          print(' logging in key : ${subkey}  and ${url} $nsp');
        } else {
          // Navigate to ErrorPage for handling error
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ErrorHandlingLogin(
                errorMessage: 'Error logging in. Please try again.',
              ),
            ),
          );
        }
      } catch (e) {
        print('Exception during login: $e');
        // Navigate to ErrorPage with exception message
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ErrorHandlingLogin(
              errorMessage: 'An error occurred: $e',
            ),
          ),
        );
      } finally {
        isLoading.value =
            false; // Stop loading regardless of success or failure
      }
    } else {
      isLoading.value = false; // Stop loading if validation fails
    }
  }

  Future<void> _fetchUserData(BuildContext context, String url) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      print('Fetching data>>>>:');

      // API call
      final response = await http.get(Uri.parse(

        // Question: Geo is okk or we need to fetch the current geo  and what is cts and how can we get it it just 2nd api
          'https://${url}/mobi?&geo=0.0,0.0&os=2&pcode=${password.value}&nspace=${accountName}&action=mlogin&rid=${workerId.value}&cts=1728382466217'));

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
          // final rid = int.parse(ridElement.single.text);
          final rid =ridElement.single.text;
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
          await prefs.setString("rid", rid);
          await prefs.setString("responderName", responderName);
          await prefs.setString("geoLocation", geoLocation);

          // Parse response into ApiResponse model
          TokenApiReponse apiResponse = TokenApiReponse(
            requestId: rid,
            responderName: responderName,
            geoLocation: geoLocation,
            nspId: nspId, // Example value (replace as needed)
            gpsSync: gpsSync, // Example value (replace as needed)
            locationChange: locationChange, // Example value (replace as needed)
            shiftDateLock: shiftDateLock, // Example value (replace as needed)
            shiftError: shiftError, // Example value (replace as needed)
            endValue: endValue, // Example value (replace as needed)
            speed: speed, // Example value (replace as needed)
            multiLeg: multiLeg, // Example value (replace as needed)
            uiConfig: uiConfig, // Example value (replace as needed)
            token: token,
          );

          print("token in login : $token  rid $rid userid $workerId get $geoLocation");

          // Store the data in SQLite database
          await ApiDataTable.insertData(apiResponse);
          print('Data successfully stored in the database');

          // Perform any additional checks or actions
          await checkTheLatestVersion(url, token , geoLocation);
        } else {
          // Handle missing elements error
          print('Error: Missing essential XML elements.');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ErrorHandlingLogin(
                errorMessage:
                    'Failed to retrieve necessary login information. Please try again later.',
              ),
            ),
          );
        }
      } else {
        print('Error: Status code ${response.statusCode} during fetching data');
        // Handle HTTP error
        print('Error: Status code ${response.statusCode} during data fetch.');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ErrorHandlingLogin(
              errorMessage:
                  'Failed to fetch data from server. Please try again.',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      print('Error: $e');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ErrorHandlingLogin(
            errorMessage: 'An unexpected error occurred: $e',
          ),
        ),
      );
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

  Future<void> checkTheLatestVersion(String url, String token, String geoLocation  ) async {
    try {
      // Construct the API URL with dynamic token and geoLocation
      final apiUrl = "https://$url/mobi?token=$token&nspace=${accountName.value}&geo=$geoLocation&rid=${workerId.value}&action=getmversion";

      print("Geo location: $geoLocation");

      // Make the API request
      final response = await http.get(Uri.parse(apiUrl));
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
          // await displayDataFromDb();
          Get.to(()=>HomeScreen());

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

    for (var data in dataList) {
      print('Responder Name:  ${data.responderName}');
      print('GeoLocation: ${data.geoLocation}');
    }
  }
}
