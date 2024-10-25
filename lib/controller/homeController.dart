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
    fetchData();
    // GetOrder();
    // _determinePosition();
  }

  // Function to update the message
  void updateMessage(String message) {
    print("home messaee $message");

    receivedMessage.value = message;
    print("home messaee here  ${receivedMessage.value}");
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

  String id = "1343842047";

  Future<void> fetchData() async {
    print("Responmse : is ");
    print("Responmse :fdfs is ");
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    String? nspace = prefs.getString("nspace");
    int? rid = prefs.getInt("rid");

    print("token $token napsce $nspace  rid $rid");

    try {
      isLoading(true);

      // Construct the API URL dynamically
      var url = Uri.parse(
        'https://portal.aceroute.com/mobi?action=getcustdataall&id=$id&token=$token&nspace=demo.com&rid=$rid&cts=172829964659',
      );

      // Make the API request
      final response = await http.get(url);

      // If the response is successful, parse the XML data
      if (response.statusCode == 200) {
        final xmlDocument = XmlDocument.parse(response.body);
        dataModel.value = DataModel.fromXml(xmlDocument);

        // Print the parsed data for verification
      } else {
        Get.snackbar('Error', 'Failed to load data');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading(false);
    }
  }

//Get order Data

  var orderData =
      Rxn<GetOrderData>(); // Using Rxn to allow null values initially
  var isLoading = false.obs; // For loading indicato

  Future<void> GetOrder() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve values from SharedPreferences
    // String? token = prefs.getString("token");
    String? token =
        "qHCqPOLuscUrtDwb7lTEz%2B%2Fy6qdcu3yiCuemrtCU4VXXwEw%2BIiy6GNwmccdmG6lND8q7ChXnmbKY4P0pWVlNta4amsxe02eXls6zu9ZpDv81deHFglyrrBXZ%2BmztGzYKdmAPF4DnBODid2YiqB2YV%2B1kargSM9LsSLbPTSNToeM%3D";
    String? nspace = prefs.getString("nspace");
    int? rid = prefs.getInt("rid");

    print("token: $token, nspace: $nspace, rid: $rid");

    try {
      // Construct the URL using the retrieved values
      var url = Uri.parse(
          "https://portal.aceroute.com/mobi?token=$token&nspace=demo.com&geo=<lat,lon>&rid=$rid&action=getorders&tz=<timezone>&from=2024-08-01&to=2024-08-15");

      print('Fetching data from API: $url');

      // API call
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final xmlResponse = XmlDocument.parse(response.body);

        // Use a function to safely get the text value or a default value
        String safeGetText(Iterable<XmlElement> elements, String defaultValue) {
          return elements.isNotEmpty ? elements.single.text : defaultValue;
        }

// Continue extracting elements from the XML
        final id =
            xmlResponse.findAllElements('id').single.text ?? "not availble";
        final cid =
            xmlResponse.findAllElements('cid').single.text ?? "not availble";
        final startDate =
            xmlResponse.findAllElements('start_date').single.text ??
                "not availble";
        final etm =
            xmlResponse.findAllElements('etm').single.text ?? "not availble";
        final endDate = xmlResponse.findAllElements('end_date').single.text ??
            "not availble";
        final nm =
            xmlResponse.findAllElements('nm').single.text ?? "not availble";
        final wkf =
            xmlResponse.findAllElements('wkf').single.text ?? "not availble";
        final pid =
            xmlResponse.findAllElements('pid').single.text ?? "not availble";
        final alt =
            xmlResponse.findAllElements('alt').single.text ?? "not availble";
        final po =
            xmlResponse.findAllElements('po').single.text ?? "not availble";
        ;
        final inv =
            xmlResponse.findAllElements('inv').single.text ?? "not availble";
        final tid =
            xmlResponse.findAllElements('tid').single.text ?? "not availble";
        ;
        final rid =
            xmlResponse.findAllElements('rid').single.text ?? "not availble";
        ;
        final ridcmt =
            xmlResponse.findAllElements('ridcmt').single.text ?? "not availble";
        ;
        final dtl =
            xmlResponse.findAllElements('dtl').single.text ?? "not availble";
        ;
        final lid =
            xmlResponse.findAllElements('lid').single.text ?? "not availble";
        ;
        final cntid =
            xmlResponse.findAllElements('cntid').single.text ?? "not availble";
        ;
        final flg =
            xmlResponse.findAllElements('flg').single.text ?? "not availble";
        ;
        final est =
            xmlResponse.findAllElements('est').single.text ?? "not availble";
        final lst =
            xmlResponse.findAllElements('lst').single.text ?? "not availble";
        final ctid =
            xmlResponse.findAllElements('ctid').single.text ?? "not availble";
        final ctpnm =
            xmlResponse.findAllElements('ctpnm').single.text ?? "not availble";
        final ltpnm =
            xmlResponse.findAllElements('ltpnm').single.text ?? "not availble";
        final cnm =
            xmlResponse.findAllElements('cnm').single.text ?? "not availble";
        final adr =
            xmlResponse.findAllElements('adr').single.text ?? "not availble";
        final adr2 =
            xmlResponse.findAllElements('adr2').single.text ?? "not availble";
        final geo =
            xmlResponse.findAllElements('geo').single.text ?? "not availble";
        final cntnm =
            xmlResponse.findAllElements('cntnm').single.text ?? "not availble";
        final tel =
            xmlResponse.findAllElements('tel').single.text ?? "not availble";
        final ordfld1 = xmlResponse.findAllElements('ordfld1').single.text ??
            "not availble";
        final ttid =
            xmlResponse.findAllElements('ttid').single.text ?? "not availble";
        final cfrm =
            xmlResponse.findAllElements('cfrm').single.text ?? "not availble";
        final cprt =
            xmlResponse.findAllElements('cprt').single.text ?? "not availble";
        final xid =
            xmlResponse.findAllElements('xid').single.text ?? "not availble";
        final cxid =
            xmlResponse.findAllElements('cxid').single.text ?? "not availble";
        final tz =
            xmlResponse.findAllElements('tz').single.text ?? "not availble";
        final zip =
            xmlResponse.findAllElements('zip').single.text ?? "not availble";
        final fmeta =
            xmlResponse.findAllElements('fmeta').single.text ?? "not availble";
        final cimg =
            xmlResponse.findAllElements('cimg').single.text ?? "not availble";
        final caud =
            xmlResponse.findAllElements('caud').single.text ?? "not availble";
        final csig =
            xmlResponse.findAllElements('csig').single.text ?? "not availble";
        final cdoc =
            xmlResponse.findAllElements('cdoc').single.text ?? "not availble";
        final cnot =
            xmlResponse.findAllElements('cnot').single.text ?? "not availble";
        final dur =
            xmlResponse.findAllElements('dur').single.text ?? "not availble";
        final val =
            xmlResponse.findAllElements('val').single.text ?? "not availble";
        final rgn =
            xmlResponse.findAllElements('rgn').single.text ?? "not availble";
        final upd =
            xmlResponse.findAllElements('upd').single.text ?? "not availble";
        final by =
            xmlResponse.findAllElements('by').single.text ?? "not availble";
        final znid =
            xmlResponse.findAllElements('znid').single.text ?? "not availble";

        GetOrderData getorderData = GetOrderData(
          id: id,
          cid: cid,
          startDate: startDate,
          endDate: endDate,
          nm: nm,
          wkf: wkf,
          alt: alt,
          po: po,
          inv: inv,
          tid: tid,
          pid: pid,
          rid: rid,
          ridcmt: ridcmt,
          dtl: dtl,
          lid: lid,
          cntid: cntid,
          flg: flg,
          est: est,
          lst: lst,
          ctid: ctid,
          ctnm: ctpnm,
          adr: adr,
          geo: geo,
          cntnm: cntnm,
          tel: tel,
          ttid: ttid,
          cfrm: cfrm,
          cprt: cprt,
          xid: xid,
          cxid: cxid,
          tz: tz,
          zip: zip,
          fmeta: fmeta,
          cimg: cimg,
          caud: caud,
          csig: csig,
          cdoc: cdoc,
          cnot: cnot,
          dur: dur,
          val: val,
          rgn: rgn,
          upd: upd,
          by: by,
          znid: znid,
          etm: etm,
          ctpnm: ctpnm,
          ltpnm: ltpnm,
          cnm: cnm,
          adr2: adr2,
          ordfld1: ordfld1,
        );

        orderData.value = getorderData;
        print("-------------------------------------------------");
        // Check if orderData.value is not null before accessing its properties
        if (orderData.value != null) {
          print("${orderData.value!.adr} hiiiiii");
        }
      } else {
        print("something Went wrong");
      }

      print(response.body);
    } catch (e) {}
  }

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
