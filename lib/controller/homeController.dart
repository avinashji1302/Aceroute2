import 'dart:async';

import 'package:ace_routes/model/order_data_model.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:location/location.dart' as locationLib;
import 'package:permission_handler/permission_handler.dart'
    as permissionHandlerLib;
import 'package:http/http.dart' as http;

import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

import '../model/home/home_model.dart';

class HomeController extends GetxController {
  final Completer<GoogleMapController> mapController = Completer();
  LatLng currentLocation = LatLng(0, 0);
  final RxBool loadingLocation = true.obs;
  final Set<Marker> markers = <Marker>{}.obs;
  BitmapDescriptor? customIcon;
  StreamSubscription<geo.Position>? positionStreamSubscription;

  var receivedMessage = "".obs;

  // here is sort

  @override
  void onInit() {
    super.onInit();


    // _determinePosition();
  }

  Future<void> getCurrentLocation() async {
    print('up');
    try {
      bool serviceEnabled;
      geo.LocationPermission permission;
      print('try');

      // Check if the location service is enabled
      serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('error');
        return Future.error('Location services are disabled.');
      }

      // Check for location permissions
      permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          return Future.error('Location permissions are denied.');
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // Get the current position
      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high);

      // Update the observable variable directly
      currentLocation = LatLng(position.latitude, position.longitude);
      print('Current Location: $currentLocation');

      // Animate the camera to the new location
      final GoogleMapController controller = await mapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(currentLocation));
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  //----------------------------------------------------------------------------------

  // Observables for managing state
  var selectedIndex = 0.obs;
  var counter = 0.obs;
  var selectedDate = Rxn<DateTime>();

  var dataModel = DataModel(customer: [], locations: [], contacts: []).obs;
  // var isLoading = true.obs;


//Get order Data

  var orderData =
      Rxn<GetOrderData>(); // Using Rxn to allow null values initially
  var isLoading = false.obs; // For loading indicato

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
      permissionHandlerLib.PermissionStatus locationStatus =
          await permissionHandlerLib.Permission.location.request();
      if (locationStatus.isGranted) {
        print('Location permission granted');
      } else if (locationStatus.isDenied) {
        print('Location permission denied');
      } else if (locationStatus.isPermanentlyDenied) {
        print('Location permission permanently denied');
        permissionHandlerLib.openAppSettings();
      }

      // Request storage permission
      permissionHandlerLib.PermissionStatus storageStatus =
          await permissionHandlerLib.Permission.storage.request();
      if (storageStatus.isGranted) {
        print('Storage permission granted');
      } else if (storageStatus.isDenied) {
        print('Storage permission denied');
      } else if (storageStatus.isPermanentlyDenied) {
        print('Storage permission permanently denied');
        permissionHandlerLib.openAppSettings();
      }

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
}
