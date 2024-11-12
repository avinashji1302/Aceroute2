import 'dart:convert';
import 'package:ace_routes/Widgets/error_handling_login.dart';
import 'package:ace_routes/controller/all_terms_controller.dart';
import 'package:ace_routes/core/Constants.dart';
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
import 'package:xml/xml.dart' as xml;

import '../core/xml_to_json_converter.dart';

class LoginController extends GetxController {
  final allTermsController = Get.put(AllTermsController());
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

    print('Login button clicked:');
    if (_validateInputs()) {
      // Construct the login URL
      final String loginUrl = '$BaseURL/login?&nsp=$accountName&tid=mobi';
      print("Step 1 - Login URL: $loginUrl");

      try {
        final response = await http.get(Uri.parse(loginUrl));
        if (response.statusCode == 200) {
          Map<String, dynamic> jsonResponse = xmlToJson(response.body);
          print(' Converted JSON Response: ${jsonEncode(jsonResponse)}');

          await _handleLoginResponse(context, jsonResponse);
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
        isLoading.value = false;
      }
    } else {
      isLoading.value = false;
    }
  }

// Helper function to handle the login response
  Future<void> _handleLoginResponse(
      BuildContext context, Map<String, dynamic> jsonResponse) async {
    final nsp = jsonResponse['nsp'];
    final url = jsonResponse['url'];
    final subkey = jsonResponse['subkey'];

    // Save `nsp` to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('nsp', nsp);

    // Store in database
    LoginResponse loginResponse =
        LoginResponse(nsp: nsp, url: url, subkey: subkey);
    await LoginResponseTable.insertLoginResponse(loginResponse);
    print('Login response saved to database.');

    // Now fetch user-specific data
    await _fetchUserData(context, url);
  }

  Future<void> _fetchUserData(BuildContext context, String url) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final String fetchUrl =
          '$BaseURL/mobi?&geo=0.0,0.0&os=2&pcode=${password.value}&nspace=${accountName}&action=mlogin&rid=${workerId.value}&cts=1728382466217';

      print("Step-2 Login  User Api URL: $fetchUrl");

      final response = await http.get(Uri.parse(fetchUrl));

      if (response.statusCode == 200) {
        final jsonResponse = xmlToJson(response.body);

        // final xmlResponse = xml.XmlDocument.parse(response.body);
        // Map to hold the extracted data
        // Map<String, dynamic> jsonResponse = {};

        // // Extract elements and add to map
        // jsonResponse['rid'] = xmlResponse.findAllElements('rid').single.text;
        // jsonResponse['resnm'] =
        //     xmlResponse.findAllElements('resnm').single.text;
        // jsonResponse['geo'] = xmlResponse.findAllElements('geo').single.text;
        // jsonResponse['nspid'] =
        //     xmlResponse.findAllElements('nspid').single.text;
        // jsonResponse['gpssync'] =
        //     xmlResponse.findAllElements('gpssync').single.text;
        // jsonResponse['locchg'] =
        //     xmlResponse.findAllElements('locchg').single.text;
        // jsonResponse['shfdtlock'] =
        //     xmlResponse.findAllElements('shfdtlock').single.text;
        // jsonResponse['shfterr'] =
        //     xmlResponse.findAllElements('shfterr').single.text;
        // jsonResponse['edn'] = xmlResponse.findAllElements('edn').single.text;
        // jsonResponse['spd'] = xmlResponse.findAllElements('spd').single.text;
        // jsonResponse['mltleg'] =
        //     xmlResponse.findAllElements('mltleg').single.text;
        // jsonResponse['uiconfig'] =
        //     xmlResponse.findAllElements('uiconfig').single.text;
        // jsonResponse['token'] =
        //     xmlResponse.findAllElements('token').single.text;

        // Print JSON representation
        print('Converted JSON Response ${jsonResponse['rid']}: ${jsonEncode(jsonResponse)}   ');

        // Store in SharedPreferences or database as needed
        final token = jsonResponse['token'];
        await prefs.setString("token", token);
        await prefs.setString("rid", jsonResponse['rid']);
        await prefs.setString("responderName", jsonResponse['resnm']);
        await prefs.setString("geoLocation", jsonResponse['geo']);

        // Parse response into ApiResponse model and store in database
        TokenApiReponse apiResponse = TokenApiReponse(
          requestId: jsonResponse['rid'],
          responderName: jsonResponse['resnm'],
          geoLocation: jsonResponse['geo'],
          nspId: jsonResponse['nspid'],
          gpsSync: jsonResponse['gpssync'],
          locationChange: jsonResponse['locchg'],
          shiftDateLock: jsonResponse['shfdtlock'],
          shiftError: jsonResponse['shfterr'],
          endValue: jsonResponse['edn'],
          speed: jsonResponse['spd'],
          multiLeg: jsonResponse['mltleg'],
          uiConfig: jsonResponse['uiconfig'],
          token: jsonResponse['token'],
        );

        await ApiDataTable.insertData(apiResponse);
        print(' User Data successfully stored in the database.');

        await checkTheLatestVersion(url, token, jsonResponse['geo']);
      } else {
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

  Future<void> checkTheLatestVersion(
      String url, String token, String geoLocation) async {
    try {
      // Construct the API URL with dynamic token and geoLocation
      final apiUrl =
          "$BaseURL/mobi?token=$token&nspace=${accountName.value}&geo=$geoLocation&rid=${workerId.value}&action=getmversion";

      // Make the API request
      final response = await http.get(Uri.parse(apiUrl));

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Parse the XML response
        print("Step-3 Feched Login Version data ,  Api URL: $apiUrl");
        final xmlDocument = xml.XmlDocument.parse(response.body);

        // Extract the version (id) from the XML
        String versionId = xmlDocument.findAllElements('id').single.text.trim();
        final success = xmlDocument.findAllElements('success').single.text;

        // Print the extracted XML data
        // print("Extracted Version ID: $versionId");
        // print("Extracted Success Status: $success");

        // String versionId = versionIdElement.text.trim();
        // bool success = successElement.single.text;

        // Convert XML data to JSON format
        Map<String, dynamic> jsonResponse = {
          'success': success,
          'id': versionId,
        };

        // Print the JSON data
        print("Converted version JSON Response: ${jsonEncode(jsonResponse)}");

        // Parse response into ApiResponse model
        VersionModel versionModel =
            VersionModel(success: success, id: versionId);

        // save to database;
        await VersionApiTable.insertVersionData(versionModel);
        print('Version data successfully inserted into database.');

        // Get the installed app version
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;

        // print('Fetched version from API: $versionId');
        // print('Current installed version: $currentVersion');

        // Normalize versions to ensure they have a minor and patch version
        versionId = _normalizeVersion(versionId);
        currentVersion = _normalizeVersion(currentVersion);

        // Parse the versions using the Version class
        final apiVersion = Version.parse(versionId);
        final installedVersion = Version.parse(currentVersion);

        // Compare the API version with the installed version
        if (apiVersion > installedVersion) {
          // If the API version is greater, prompt the user to update the app
          //  print('App is not up to date.');
          // showUpdateDialog();
          // Show the update dialog if an update is available
          // Get.dialog(UpdateDialog(onUpdate: _navigateToPlayStore));
          // await displayDataFromDb();

          Get.to(() => HomeScreen());

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
