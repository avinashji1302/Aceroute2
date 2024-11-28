import 'dart:async';
import 'package:ace_routes/controller/all_terms_controller.dart';
import 'package:ace_routes/controller/event_controller.dart';
import 'package:ace_routes/controller/loginController.dart';
import 'package:ace_routes/controller/status_controller.dart';
import 'package:ace_routes/core/Constants.dart';
import 'package:ace_routes/core/colors/Constants.dart';
import 'package:ace_routes/database/Tables/api_data_table.dart';
import 'package:ace_routes/database/Tables/event_table.dart';
import 'package:ace_routes/database/Tables/terms_data_table.dart';
import 'package:ace_routes/database/Tables/version_api_table.dart';
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
import 'package:sqflite/sqflite.dart';
import '../controller/fontSizeController.dart';
import '../database/Tables/OrderTypeDataTable.dart';
import '../database/Tables/PartTypeDataTable.dart';
import '../database/Tables/login_response_table.dart';
import '../database/Tables/status_table.dart';
import '../database/databse_helper.dart';
import '../model/login_model/login_response.dart';
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

  // final AllTerms allTerms = Get.put(AllTerms());

  //LatLng _currentLocation = LatLng(45.521563, -122.677433); // Default location
  LatLng _currentLocation = LatLng(0, 0); // Initialize with an empty location
  StreamSubscription<geo.Position>? _positionStreamSubscription;
  final AllTermsController allTermsController = Get.put(AllTermsController());
  bool _showCard = true;
  final FontSizeController fontSizeController = Get.put(FontSizeController());
  final EventController eventController = Get.put(EventController());

  List<bool> _showCardDetails = List.generate(2, (_) => false);
  List<bool> temp = [true, false];
  Set<Marker> _markers = {};
  BitmapDescriptor? _customIcon;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    // _loadCustomIcon();
    _determinePosition();
    // Get.put(EventController());
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

  String formatEventDate(String? startDate) {
    if (startDate == null || startDate.isEmpty) {
      return "No Time";
    }

    try {
      // Define the expected input format
      DateFormat inputFormat = DateFormat("yyyy/MM/dd HH:mm Z");

      // Parse the date string into a DateTime object
      DateTime date = inputFormat.parse(startDate);

      // Format to "MMM" (e.g., Nov)
      String formattedDate = DateFormat("MMM").format(date);

      // Format local time
      String localTime = DateFormat.jm().format(date.toLocal());

      return "$formattedDate, $localTime";
    } catch (e) {
      return "Invalid date";
    }
  }

  @override
  Widget build(BuildContext context) {
    AllTerms.getTerm();
    return Scaffold(
      floatingActionButton: GestureDetector(
          onTap: () {
            ApiDataTable.clearData();
            LoginResponseTable.clearLoginResponse();
            VersionApiTable.clearVersionData();
            EventTable.clearEvents();
            TermsDataTable.clearTermsData();
            PartTypeDataTable.clearPartTypeData();
            OrderTypeDataTable.clearOrderTypeData();
            print("API data deleted");
          },
          child: Obx(() => Text(
                AllTerms.assetName.value,
                style: TextStyle(fontSize: 30),
              ))),
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
                  '${eventController.events.length}',
                  style: const TextStyle(color: Colors.white),
                ),
              )),
        ],
        elevation: 5,
        backgroundColor: Colors.white,
      ),
      drawer: const DrawerWidget(),
      body: _showCard
          ? Obx(() {
              // Check if data is loading
              if (eventController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(), // Display loading spinner
                );
              }

              // Check if eventController.events list is empty
              if (eventController.events.isEmpty) {
                return Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              // Display events in a list
              return ListView.builder(
                itemCount: eventController.events.length,
                itemBuilder: (context, index) {
                  final event = eventController.events[index];

                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(StatusScreen());
                          },
                          child: Container(
                            color: MyColors.blueColor,
                            padding: const EdgeInsets.all(12.0),
                            width: double.infinity,
                            child: Center(
                              child: Obx(() => Text(
                                    eventController
                                            .currentStatus.value.isNotEmpty
                                        ? eventController.currentStatus.value
                                        : "No Name",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                            ),
                          ),
                        ),
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
                                      Get.to(SummaryDetails(id: event.id));
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 115,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[500],
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Center(
                                              child: Text(
                                                formatEventDate(
                                                    event.startDate),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: fontSizeController
                                                      .fontSize,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        Text(
                                          event.name ?? "No name",
                                          style: TextStyle(
                                            fontSize:
                                                fontSizeController.fontSize,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),

                                        Obx(
                                              () => Center(
                                            child: Row(
                                              children: [
                                                Text("${eventController.categoryName.value} :",
                                                style: TextStyle(
                                                  fontSize:
                                                  fontSizeController.fontSize,
                                                 fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),)
                                              ],
                                            ),
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
                                ],
                              ),
                              SizedBox(height: 20.0),
                              // Additional event details row
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
                                      Get.to(()=>DirectoryDetails( id: event.id,));
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.cnm ?? "No Name",
                                          style: TextStyle(
                                            fontSize:
                                                fontSizeController.fontSize,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),

                                        SizedBox(height: 5.0),
                                        Text(
                                          event.address ?? "No Alt",
                                          style: TextStyle(
                                            fontSize:
                                                fontSizeController.fontSize,
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          event.cntnm ?? "No Alt",
                                          style: TextStyle(
                                            fontSize:
                                                fontSizeController.fontSize,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          event.tel ?? "No Alt",
                                          style: TextStyle(
                                            fontSize:
                                                fontSizeController.fontSize,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
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
                                      Get.to(VehicleDetails(id: event.id,));
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          // width: 140,
                                          // height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Obx(() {
                                            if (index <
                                                eventController.events.length) {
                                              return Text(
                                                '${eventController.events[index].detail}',
                                                style: TextStyle(
                                                  fontSize: fontSizeController
                                                      .fontSize,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              );
                                            } else {
                                              return Text(
                                                  'No event available for this index.');
                                            }
                                          }),
                                        ),
                                        Obx(() => RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        '${eventController.events[index].po}\n${eventController.events[index].inv}',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize:
                                                          fontSizeController
                                                              .fontSize,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              // Actions row
                              Container(
                                color: Colors.grey[200],
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.person_2_sharp, size: 30),
                                      onPressed: () {
                                        Get.to(EFormScreen());
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.tips_and_updates,
                                          size: 30),
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
              );
            })
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
                  _showCard = true; // Show card
                }
                /*else if (index == 1) {
                  // Search tab
                  _showCard = false; // Hide card

                  homeController.getCurrentLocation();
                  // _getCurrentLocation(); // Up
                } */
                else if (index == 1) {
                  // Map tab

                  print('object');
                  _showCard = false; // Hide card

                  homeController.getCurrentLocation();
                  // _getCurrentLocation(); // Up
                } else if (index == 2) {
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
