import 'package:ace_routes/controller/homeController.dart';
import 'package:ace_routes/controller/loginController.dart';
import 'package:ace_routes/database/databse_helper.dart';
import 'package:ace_routes/view/change_pass_screen.dart';
import 'package:ace_routes/view/home_screen.dart';
import 'package:ace_routes/view/login_screen.dart';
import 'package:ace_routes/view/sync_popup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ace_routes/controller/drawerController.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart' as loc;
import '../controller/all_terms_controller.dart';
import '../controller/fontSizeController.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  Future<void> _openGoogleMaps() async {
    loc.Location location = loc.Location();
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    loc.PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }
    loc.LocationData _locationData = await location.getLocation();
    final double latitude = _locationData.latitude!;
    final double longitude = _locationData.longitude!;

    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    final Uri googleMapsUri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else {
      throw 'Could not open Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawerController = Get.put(DrawerControllers());
    final fontSizeController = Get.find<FontSizeController>();
    final allTermsController = Get.put(AllTermsController());

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration:  BoxDecoration(
              color:  Colors.blue[900],
            ),
            child: SizedBox(
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'John Doe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSizeController.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'New York, USA',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: fontSizeController.fontSize,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.sync_outlined),
            title: Text(
              'Sync Now',
              style: TextStyle(
                fontSize: fontSizeController.fontSize,
              ),
            ),
            onTap: () async{
              print('sync now');
              Navigator.pop(context);


              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const SyncPopup();
                },
              );
            },
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(
              'About',
              style: TextStyle(
                fontSize: fontSizeController.fontSize,
              ),
            ),
            onTap: ()async {
              // print('about');
              // print('GetAllTerms  =============>>>>>');
              // print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
              // allTermsController.GetAllTerms();
              // print('GetAllPartTypes  =============>>>>>');
              // print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
              // allTermsController.GetAllPartTypes();
              //
              // print('displayLoginResponseData  =============>>>>>');
              // print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
              // allTermsController.displayLoginResponseData();
              // Database db = await DatabaseHelper().database;
              // print('fetchAndStoreOrderTypes  =============>>>>>');
              // print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
              // await allTermsController.fetchAndStoreOrderTypes();
              // print('fetchAndStoreGTypes  =============>>>>>');
              // print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
              // await allTermsController.fetchAndStoreGTypes(db);
              //_showAboutDialog(context);
            },
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(
              'Nav to Start',
              style: TextStyle(
                fontSize: fontSizeController.fontSize,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _openGoogleMaps();
            },
          ),
          Divider(
            thickness: 1,
          ),

          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(
              'Setup Passcode',
              style: TextStyle(
                fontSize: fontSizeController.fontSize,
              ),
            ),
            onTap: () {
              Get.to(ChangePasswordScreen());
            },
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(Icons.font_download),
            title: Text(
              'Setup Font Size',
              style: TextStyle(
                fontSize: fontSizeController.fontSize,
              ),
            ),
            onTap: () {
              // _showFontSizeDialog(context, drawerController);
              _showFontSizeDialog(
                  context, drawerController, fontSizeController);
            },
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: Text(
              'Setup Route Date',
              style: TextStyle(
                fontSize: fontSizeController.fontSize,
              ),
            ),
            onTap: () {
              _showDatePickerDialog(context);
            },
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red,),
            title: Text(
              'Logout',
              style: TextStyle(
                fontSize: fontSizeController.fontSize,
                color: Colors.red
              ),
            ),
            onTap: () {
              Get.to(LoginScreen());
              // _showLogoutDialog(context);
            },
          ),
          Divider(
            thickness: 1,
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final fontSizeController = Get.find<FontSizeController>();
    // final loginController = Get.find<LoginController>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Logout',
            style: TextStyle(fontSize: fontSizeController.fontSize),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: fontSizeController.fontSize),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSizeController.fontSize)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            ElevatedButton(
              child: Text('Logout',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSizeController.fontSize)),
              onPressed: () {
                final loginController = Get.find<LoginController>();
                // loginController.clearFields();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDatePickerDialog(BuildContext context) {
    final fontSizeController = Get.find<FontSizeController>();
    final homeController =
        Get.find<HomeController>(); // Assuming you're using GetX

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onDateChanged: (selectedDate) {
                  // Store the selected date in the controller
                  homeController.setSelectedDate(selectedDate);
                },
              ),
              Divider(
                thickness: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: fontSizeController.fontSize),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(fontSize: fontSizeController.fontSize),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showFontSizeDialog(
      BuildContext context,
      DrawerControllers drawerController,
      FontSizeController fontSizeController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Font Size',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),
                  Column(
                    children: [
                      _buildRadioOption(context, 'Extra Small', 'extra_small',
                          drawerController),
                      _buildRadioOption(
                          context, 'Small', 'small', drawerController),
                      _buildRadioOption(
                          context, 'Medium', 'medium', drawerController),
                      _buildRadioOption(
                          context, 'Large', 'large', drawerController),
                      _buildRadioOption(context, 'Extra Large', 'extra_large',
                          drawerController),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showRestartDialog(context, fontSizeController);
                        },
                        child: const Text(
                          'OK',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRestartDialog(
      BuildContext context, FontSizeController fontSizeController) {
    final fontSizeController = Get.find<FontSizeController>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'ACE Routes',
            style: TextStyle(
              fontSize: fontSizeController.fontSize,
            ),
          ),
          content: Text(
            'This App collects Location data to enable Schedule Optimization, Assign Work by Proximity, and send ETA Notifications even when the app is closed or in background. To disable Location tracking, please click "Clockout" within the App or Logout of the App. No Location data will be captured in above two scenarios.',
            style: TextStyle(
              fontSize: fontSizeController.fontSize,
            ),
          ),
          actions: <Widget>[
            Container(
              width: double.infinity,
              child: ElevatedButton(
                child: Text('OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSizeController.fontSize,
                    )),
                onPressed: () {
                  _restartApp(fontSizeController);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _restartApp(FontSizeController fontSizeController) {
    fontSizeController.applyFontSize();
    Get.offAll(() => HomeScreen()); // Replace with your HomeScreen route
  }

  Widget _buildRadioOption(BuildContext context, String text, String value,
      DrawerControllers drawerController) {
    return Obx(() {
      return RadioListTile<String>(
        title: Text(text),
        value: value,
        groupValue: drawerController.selectedFontSize.value,
        activeColor: Colors.green,
        onChanged: (String? newValue) {
          drawerController.updateFontSize(newValue!);
        },
      );
    });
  }

  void _showAboutDialog(BuildContext context) {
    final fontSizeController = Get.find<FontSizeController>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                alignment: Alignment.center,
                //color: Colors.white,
                child: Text(
                  'About Us',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: fontSizeController.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Field Service Management Right Person. Right Place. Right Time.',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: fontSizeController.fontSize),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Refresh All Data',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSizeController.fontSize),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: fontSizeController.fontSize),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


}
