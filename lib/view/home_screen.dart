import 'dart:async';
import 'package:ace_routes/view/pic_upload_screen.dart';
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
  LatLng _currentLocation = LatLng(45.521563, -122.677433); // Default location
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;
  bool _showCard = false;
  final FontSizeController fontSizeController = Get.put(FontSizeController());

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      geo.LocationPermission permission;

      serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
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
      List<Location> locations = await locationFromAddress(_searchController.text);
      if (locations.isNotEmpty) {
        LatLng targetLocation = LatLng(locations.first.latitude, locations.first.longitude);
        final GoogleMapController controller = await _mapController.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(targetLocation, 14.0));
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
      'location': 'Danville',
      'details': 'Should show Voltage from\nDelivery : p5 : Normal',
      'number': '1'
    },
    {
      'time': '2:30 pm',
      'location': 'Townsville',
      'details': 'Some other details\nAdditional info here',
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
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
            children: [
              Text(
                homeController.getFormattedDate(),
                style: TextStyle(  fontSize: fontSizeController.fontSize,) // Adjust the font size as needed
              ),
              SizedBox(height: 4), // Add some spacing between date and day
              Text(
                homeController.getFormattedDay(),
                style: TextStyle(  fontSize: fontSizeController.fontSize, color: Colors.black), // Adjust the style for the day
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
              itemCount: 5, // Ensure this is not null and is a valid number
              itemBuilder: (context, index) {
                // Ensure you don't access null values
                String timeText = index % 2 == 0 ? '1:20 pm' : 'Danville'; // Example data
                String detailsText = index % 2 == 0
                    ? 'Should show Voltage from\nDelivery : p5 : Normal'
                    : 't1 upstaire\nt2\nt3';

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Get.to(StatusScreen());
                        },
                        child: Container(
                          color: Colors.blue,
                          padding: const EdgeInsets.all(16.0),
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              'Scheduled',
                              style: TextStyle(color: Colors.white,   fontSize: fontSizeController.fontSize,),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: (){
                                Get.to(SummaryDetails());
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.access_time_filled,
                                    size: 50,
                                    color: Colors.green[200],
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[500],
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          child: Center(
                                            child: Text(
                                              timeText,
                                              style: TextStyle(color: Colors.white,   fontSize: fontSizeController.fontSize,),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        Text(
                                          detailsText,
                                          style: TextStyle(fontSize: 18, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Container(
                                    width: 60,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.brown[400],
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '1',
                                        style: TextStyle(color: Colors.white,   fontSize: fontSizeController.fontSize,),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.0,),
                            GestureDetector(
                              onTap: (){
                                Get.to(DirectoryDetails());
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start, // Align children at the start
                                children: [
                                  // Clock icon
                                  Icon(
                                    Icons.watch_later_outlined,
                                    size: 50,
                                    color: Colors.green[200],
                                  ),
                                  SizedBox(width: 10), // Space between the icon and the time container

                                  // Container for time and multiline text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12.0), // Rounded corners
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Danville',
                                              style: TextStyle(color: Colors.black,   fontSize: fontSizeController.fontSize,),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5.0), // Space between the time container and the text
                                        // Multiline text aligned with the time container
                                        Container(
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(  fontSize: fontSizeController.fontSize, color: Colors.black),
                                              children: [
                                                TextSpan(
                                                  text: 'Should show Voltage from\nDelivery : p5 : Normal',
                                                  style: TextStyle(color: Colors.black), // Style for the text
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(width: 20), // Space between the text and number container

                                  // Container for the number
                                  Container(
                                    width: 60,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.brown[400], // Background color
                                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                                    ),
                                    child: Center(
                                        child: Icon(Icons.share)
                                    ),
                                  ),
                                  SizedBox(width: 10.0,)
                                ],
                              ),
                            ),
                            SizedBox(height: 20.0,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start, // Align children at the start
                              children: [
                                // Clock icon
                                Icon(
                                  Icons.add_home_outlined,
                                  size: 50,
                                  color: Colors.green[200],
                                ),
                                SizedBox(width: 10), // Space between the icon and the time container

                                // Container for time and multiline text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12.0), // Rounded corners
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Danville',
                                            style: TextStyle(color: Colors.black,   fontSize: fontSizeController.fontSize,),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5.0), // Space between the time container and the text
                                      // Multiline text aligned with the time container
                                      Container(
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(fontSize: 18, color: Colors.black),
                                            children: [
                                              TextSpan(
                                                text: 't1 upstaire\nt2\nt3',
                                                style: TextStyle(color: Colors.black,  fontSize: fontSizeController.fontSize,), // Style for the text
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.grey[200],
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                Get.to(AddPart());
                              },
                            ),

                            IconButton(
                              icon: Icon(Icons.tips_and_updates, size: 30),
                              onPressed: () {
                                Get.to(VehicleDetails());
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.camera_alt_outlined, size: 30),
                              onPressed: () {
                                Get.to(PicUploadScreen());
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.mic, size: 30),
                              onPressed: () {
                                Get.to(StatusScreen());
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, size: 30),
                              onPressed: () {
                                Get.to(AddBwForm());
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ) : Column(
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
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 11.0,
              ),
              myLocationEnabled: true,
            ),
          ),
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
        selectedLabelStyle: TextStyle(fontSize: fontSizeController.fontSize),
        unselectedLabelStyle: TextStyle(fontSize: fontSizeController.fontSize * 0.9),
        onTap: (index) {
          setState(() {
            if (index == 0) { // Inbox tab
              _showCard = true; // Show card
             // _showSearchBar = false; // Hide search bar
            } else if (index == 1) { // Search tab
              _showCard = false; // Hide card
              //_showSearchBar = !_showSearchBar; // Toggle search bar
            } else if (index == 2) { // Map tab
              _showCard = false; // Hide card
              _showSearchBar = false; // Hide search bar
              _getCurrentLocation(); // Update map location
            } else if (index == 3) { // Clocked In tab
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
