import 'dart:async';
import 'package:ace_routes/controller/loginController.dart';
import 'package:ace_routes/controller/status_controller.dart';
import 'package:ace_routes/core/colors/Constants.dart';
import 'package:ace_routes/view/audio.dart';
import 'package:ace_routes/view/e_from.dart';
import 'package:ace_routes/view/part.dart';
import 'package:ace_routes/view/pic_upload_screen.dart';
import 'package:ace_routes/view/signature_scree.dart';
import 'package:ace_routes/view/status_screen.dart';
import 'package:ace_routes/view/summary_screen.dart';
import 'package:ace_routes/view/vehicle_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:ace_routes/view/drawer.dart';
import 'package:ace_routes/controller/homeController.dart';
import 'package:intl/intl.dart';
import '../controller/fontSizeController.dart';
import 'add_bw_from.dart';
import 'add_part.dart';
import 'directory_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController homeController = Get.put(HomeController());
  final Completer<GoogleMapController> _mapController = Completer();
  final LoginController loginController =
      Get.find<LoginController>(); // Accessing LoginController

  //LatLng _currentLocation = LatLng(45.521563, -122.677433); // Default location
  LatLng _currentLocation = LatLng(0, 0); // Initialize with an empty location
  StreamSubscription<geo.Position>? _positionStreamSubscription;

  bool _showCard = true;
  final FontSizeController fontSizeController = Get.put(FontSizeController());

  List<bool> _showCardDetails = List.generate(2, (_) => false);
  List<bool> temp = [true, false];
  Set<Marker> _markers = {};
  BitmapDescriptor? _customIcon;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    print("above ");
    subscribe();
    // _loadCustomIcon();
    _determinePosition();
  }

  void subscribe() async {
    try {
      print("Subscribing to status-channel...");

      var subscription = await loginController.pubNub?.subscribe(
        channels: {'status-channel'},
      );

      subscription?.messages.listen((message) {
        print("Received raw message: ${message.content}");
        if (message.content is Map<String, dynamic>) {
          print('Message is a Map');
          var messageData = message.content['status'];
          if (messageData is String) {
            print("Status is a string: $messageData");
            homeController.updateMessage(messageData);
          } else {
            print("Status is not a string: $messageData");
          }
        } else {
          print("Message content is not a Map");
        }
      }, onError: (error) {
        print("Error in subscription: $error");
      });

      print("Subscription established, waiting for messages...");
    } catch (e) {
      print("Failed to subscribe: $e");
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      // print("deternianton $position");

      _currentLocation = LatLng(position.latitude, position.longitude);
      _updateMapLocation(_currentLocation);

      // Start tracking location after initial location is obtained
      _startLocationTracking();

      setState(() {
        _loadingLocation = false; // Stop showing loading indicator
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  void _startLocationTracking() {
    _positionStreamSubscription = geo.Geolocator.getPositionStream(
      locationSettings: geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 10, // Update location if user moves 10 meters
      ),
    ).listen((geo.Position position) {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _updateMapLocation(_currentLocation);
    });
  }

  Future<void> _updateMapLocation(LatLng location) async {
    final GoogleMapController controller = await _mapController.future;

    controller.animateCamera(
      CameraUpdate.newLatLng(location),
    );

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: location,
          icon: _customIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: 'Current Location'),
        ),
      );
    });
  }

  List<Map<String, String>> cardData = [
    {
      'time': '1:20 pm',
      'location': 'Sector 62 noida near city',
      'details': 'Should show Voltage from\nDelivery : p5 : Normal',
      'number': '1'
    },
    {
      'time': '12:30 pm',
      'location': 'Sector 59 noida near city',
      'details': 'there is some text\nDelivery : p5 : Normal',
      'number': '2'
    },

    // Add more entries as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(homeController.getFormattedDate(),
                  style: TextStyle(
                    fontSize: fontSizeController.fontSize,
                  )),
              SizedBox(height: 4),
              Text(
                homeController.getFormattedDay(),
                style: TextStyle(
                    fontSize: fontSizeController.fontSize, color: Colors.black),
              ),
            ],
          );
        }),
        centerTitle: true,
        actions: [
          Obx(() => Container(
                margin: const EdgeInsets.only(right: 16.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Text(
                  '${homeController.counter.value}',
                  style: const TextStyle(color: Colors.white),
                ),
              )),
        ],
        elevation: 5,
        backgroundColor: Colors.white,
      ),
      drawer: const DrawerWidget(),
      body: _showCard
          ? ListView.builder(
              // itemCount: _showCardDetails.length, // Number of cards
              itemCount: homeController.dataModel.value.customer.length,
              itemBuilder: (context, index) {
                print(homeController.dataModel.value.customer.length);
                print("homeController.dataModel.value.customer.length");
                final customer = homeController.dataModel.value.customer[index];
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Remove toggle and gesture detection
                      GestureDetector(
                        onTap: () {
                          Get.to(StatusScreen());
                        },
                        child: Container(
                          color: temp[index]
                              ? MyColors.blueColor
                              : const Color.fromARGB(255, 227, 57, 45),
                          padding: const EdgeInsets.all(12.0),
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                // Replace dynamic text with static "Scheduled" text
                                child: Center(
                                  child: Obx(() {
                                    return Text(
                                      homeController.receivedMessage.isEmpty
                                          ? "NOT Get"
                                          : homeController
                                              .receivedMessage.value,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Keep the rest of the details and icons below
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.access_time_filled,
                                    size: 45,
                                    color: MyColors.blueColor,
                                  ),
                                  onPressed: () {
                                    Get.to(SummaryDetails());
                                  },
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 85,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[500],
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${cardData[index]['time']}",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  fontSizeController.fontSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        "${cardData[index]['details']}",
                                        style: TextStyle(
                                          fontSize: fontSizeController.fontSize,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 20),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 7, right: 10, top: 8, bottom: 8),
                                  child: Container(
                                    width: 60,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.green[500],
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "1",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: fontSizeController.fontSize,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.watch_later_outlined,
                                    size: 45,
                                    color: MyColors.blueColor,
                                  ),
                                  onPressed: () {
                                    Get.to(DirectoryDetails());
                                  },
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 9),
                                          child: Text(
                                            '${customer.customerName}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  fontSizeController.fontSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize:
                                                fontSizeController.fontSize,
                                            color: Colors.black,
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  "${customer.customerAddress}.",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 20),
                                Container(
                                  width: 60,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: MyColors.blueColor,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.share,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.0),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.list,
                                    size: 45,
                                    color: MyColors.blueColor,
                                  ),
                                  onPressed: () {
                                    Get.to(VehicleDetails());
                                  },
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 9.0),
                                          child: Text(
                                            'Danville',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  fontSizeController.fontSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 't1 upstairs\nt2\nt3',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize:
                                                    fontSizeController.fontSize,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            Container(
                              color: Colors.grey[200],
                              // color: Colors.red,
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: Stack(
                                      children: [
                                        Icon(Icons.person_2_sharp, size: 30),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '5',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    onPressed: () {
                                      Get.to(EFormScreen());
                                    },
                                  ),
                                  IconButton(
                                    icon:
                                        Icon(Icons.tips_and_updates, size: 30),
                                    onPressed: () {
                                      Get.to(PartScreen());
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.camera_alt_outlined,
                                        size: 30),
                                    onPressed: () {
                                      Get.to(PicUploadScreen());
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.mic, size: 30),
                                    onPressed: () {
                                      Get.to(AudioRecord());
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, size: 30),
                                    onPressed: () {
                                      Get.to(Signature());
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(28.5724, 77.3644),
                      zoom: 14,
                    ),
                    markers: _markers, // Set markers here
                    onMapCreated: (GoogleMapController controller) {
                      // Optionally use the controller
                    },
                  ),
                )
              ],
            ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.mail_rounded, size: 30),
                label: 'Inbox',
              ),
              /*BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 30),
            label: 'Search',
          ),*/
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on_outlined, size: 30),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.watch_later_outlined, size: 30),
                label: 'Clocked In',
              ),
            ],
            currentIndex: homeController.selectedIndex.value,
            selectedItemColor: Colors.amber[800],
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.blueAccent[300],
            selectedLabelStyle:
                TextStyle(fontSize: fontSizeController.fontSize),
            unselectedLabelStyle:
                TextStyle(fontSize: fontSizeController.fontSize * 0.9),
            onTap: (index) {
              setState(() {
                if (index == 0) {
                  // Inbox tab
                  _showCard = true; // Show card
                  // _showSearchBar = false; // Hide search bar
                } else if (index == 1) {
                  // Search tab
                  _showCard = false; // Hide card
                  //_showSearchBar = !_showSearchBar; // Toggle search bar
                  homeController.getCurrentLocation();
                  // _getCurrentLocation(); // Up
                } else if (index == 2) {
                  // Map tab

                  print('object');
                  _showCard = false; // Hide card

                  homeController.getCurrentLocation();
                  // _getCurrentLocation(); // Up
                } else if (index == 3) {
                  // Clocked In tab
                  _showCard = false; // Hide card

                  homeController.getCurrentLocation();
                  // _getCurrentLocation(); // Up
                }
              });
              homeController.onItemTapped(index);
            },
          )),
    );
  }
}
