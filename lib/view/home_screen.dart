import 'dart:async';
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
  //LatLng _currentLocation = LatLng(45.521563, -122.677433); // Default location
  LatLng _currentLocation = LatLng(0, 0); // Initialize with an empty location
  StreamSubscription<geo.Position>? _positionStreamSubscription;

  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;
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

    _loadCustomIcon();
    _determinePosition();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _loadCustomIcon() async {
    try {
      final BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(38, 38)), // Adjust size as needed
        'assets/maplogo-removebg.png',
      );
      setState(() {
        _customIcon = icon;
        _addMarkers(); // Add markers after icon is loaded
      });
    } catch (e) {
      print("Error loading custom icon: $e");
    }
  }

  Future<void> _determinePosition() async {
    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

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

  void _addMarkers() {
    final List<LatLng> locations = [
      LatLng(28.5850, 77.3724), // Example location 1
      LatLng(28.5860, 77.3730), // Example location 2
      LatLng(28.5870, 77.3740), // Example location 3
      LatLng(28.5880, 77.3742), // Example location 4
      LatLng(28.5890, 77.3741), // Example location 5
      LatLng(28.5900, 77.3743), // Example location 6
    ];

    final List<Marker> markers = locations.asMap().entries.map((entry) {
      int index = entry.key;
      LatLng location = entry.value;

      // Format the LatLng value as a string for the InfoWindow title
      String latLngString =
          'Lat: ${location.latitude}, Lng: ${location.longitude}';

      return Marker(
        markerId: MarkerId('marker_$index'),
        position: location,
        icon: _customIcon ??
            BitmapDescriptor.defaultMarker, // Use custom icon if available
        infoWindow: InfoWindow(
          title: latLngString, // Display the LatLng value in the InfoWindow
        ),
        onTap: () {
          print('Marker $index tapped! LatLng: $latLngString');
        },
      );
    }).toList();

    setState(() {
      _markers.addAll(markers); // Add all new markers
    });
  }

  Future<void> _getCurrentLocation() async {
    print('up');
    try {
      bool serviceEnabled;
      geo.LocationPermission permission;
      print('try');

      serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('eror');

        return Future.error('Location services are disabled.');
      }

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

      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high);

      setState(() {
        print('set');

        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(_currentLocation));
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;

    try {
      List<Location> locations =
          await locationFromAddress(_searchController.text);
      if (locations.isNotEmpty) {
        LatLng targetLocation =
            LatLng(locations.first.latitude, locations.first.longitude);
        final GoogleMapController controller = await _mapController.future;
        controller
            .animateCamera(CameraUpdate.newLatLngZoom(targetLocation, 14.0));
      } else {
        print('Location not found');
      }
    } catch (e) {
      print('Error searching location: $e');
    }
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
              itemCount: _showCardDetails.length, // Number of cards
              itemBuilder: (context, index) {
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
                                  child: Text(
                                    temp[index] ? 'SCHEDULED' : "CANCELLED",
                                    style: TextStyle(
                                      color: temp[index]
                                          ? Colors.white
                                          : Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                                            fontSize:
                                                fontSizeController.fontSize,
                                            color: Colors.black,
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  "${cardData[index]['location']}.",
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
                if (_showSearchBar) // Conditionally show the search bar
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Location',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: _searchLocation,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
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
                  _getCurrentLocation(); // Up
                } else if (index == 2) {
                  // Map tab

                  print('object');
                  _showCard = false; // Hide card
                  _showSearchBar = false; // Hide search bar
                  _getCurrentLocation(); // Update map location
                } else if (index == 3) {
                  // Clocked In tab
                  _showCard = false; // Hide card
                  _showSearchBar = false; // Hide search bar
                  _getCurrentLocation(); // Update map location
                }
              });
              homeController.onItemTapped(index);
            },
          )),
    );
  }
}
