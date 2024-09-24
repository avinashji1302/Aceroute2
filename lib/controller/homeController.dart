import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pubnub/pubnub.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

class HomeController extends GetxController {
  // Observables for managing state
  var selectedIndex = 0.obs;
  var counter = 0.obs;
  var selectedDate = Rxn<DateTime>();

  //
  PubNub? pubnub;
  String? nsp;
  String? url;
  String? subkey;

  // Method to handle bottom navigation bar item taps
  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  // Method to increment the counter
  void incrementCounter() {
    counter.value++;
  }

  // Method to request permissions
  Future<void> requestPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasRequestedPermissions =
        prefs.getBool('hasRequestedPermissions') ?? false;

    if (!hasRequestedPermissions) {
      // Request location permission
      PermissionStatus locationStatus = await Permission.location.request();
      if (locationStatus.isGranted) {
        print('Location permission granted');
      } else if (locationStatus.isDenied) {
        print('Location permission denied');
        // Handle denial case
      } else if (locationStatus.isPermanentlyDenied) {
        print('Location permission permanently denied');
        // Handle permanently denied case
        openAppSettings();
      }

      // Request storage permission
      PermissionStatus storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        print('Storage permission granted');
      } else if (storageStatus.isDenied) {
        print('Storage permission denied');
        // Handle denial case
      } else if (storageStatus.isPermanentlyDenied) {
        print('Storage permission permanently denied');
        // Handle permanently denied case
        openAppSettings();
      }

      // Save the flag to indicate that permissions have been requested
      await prefs.setBool('hasRequestedPermissions', true);
    }
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  // Method to get the formatted date
  String getFormattedDate() {
    DateTime date = selectedDate.value ?? DateTime.now();
    return DateFormat('MMMM d, yyyy')
        .format(date); // Example: "August 21, 2024"
  }

  // Method to get the day of the week
  String getFormattedDay() {
    DateTime date = selectedDate.value ?? DateTime.now();
    return DateFormat('EEEE').format(date); // Example: "Monday"
  }

  @override
  void onInit() {
    super.onInit();
    pubNubInitialization();
    requestPermissions(); // Request permissions when the controller is initialized
  }

    

  // intialization of pub nub

  Future<void> pubNubInitialization() async {
    // Mocking the API call for login
    final xmlResponse =
        '''<data><nsp>demo.com</nsp><url>portal.aceroute.com</url><subkey>sub-c-424c2436-49c8-11e5-b018-0619f8945a4f</subkey></data>''';

    try {
      // Parse XML response
      final document = xml.XmlDocument.parse(xmlResponse);
      nsp = document.findAllElements('nsp').first.text;
      url = document.findAllElements('url').first.text;
      subkey = document.findAllElements('subkey').first.text;

      print("sub key $subkey $url nsp $nsp");

      // Initialize PubNub
      if (subkey != null) {
        pubnub = PubNub(
          defaultKeyset: Keyset(
            subscribeKey: subkey!,
            uuid: UUID('user-1234'),
          ),
        );
        print('PubNub initialized with subkey: $subkey');
      } else {
        print('Subkey is missing!');
      }
    } catch (e) {
      print('Error parsing XML or initializing PubNub: $e');
    }
  }
}
