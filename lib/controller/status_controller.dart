import 'dart:convert';
import 'package:ace_routes/core/Constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pubnub/pubnub.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

class StatusController extends GetxController {

  var jobStatusOptions = <String>[].obs;
  var jobExceptionOptions = <String>[].obs;
  var fieldExceptionOptions = <String>[].obs;
  var planOptions = <String>[].obs;
  // var selectedJob = ''.obs;

  //--------------------------------------- adding pubnub-------------------

  PubNub? pubNub;
  late Subscription subscription;

  var selectedStatus = ''.obs;

  void initializePubNub() {
    pubNub = PubNub(
      defaultKeyset: Keyset(
        subscribeKey: 'your-subscribe-key',
        publishKey: 'your-publish-key',
        uuid: UUID('status-screen'),
      ),
    );

    // Subscribe to the channel
    subscription = pubNub!.subscribe(channels: {'status-channel'});
    subscription.messages.listen((message) {
      print('Received message: ${message.content}');

      // Update the status when a message is received
      selectedStatus.value = message.content['status'];
    });
  }

  void sendStatusUpdate(String newStatus) {
    pubNub!.publish('status-channel', {'status': newStatus});
  }

  // Fetch status list from the API

  Future<void> fetchStatusList() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token") ?? '';
    final String rid = prefs.getString("rid") ?? '';
    final String nsp = prefs.getString("nsp") ?? '';

    print('token $token ..');
    final String url =
        '$BaseURL/mobi?action=getstatuslist&tstmp=1728299643388&token=$token&nspace=$nsp&rid=$rid&cts=1728299645320';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        // Helper function to convert XML elements to Map without empty keys
        Map<String, dynamic> elementToMap(XmlElement element) {
          final map = <String, dynamic>{};
          // Convert attributes to map entries
          for (var attr in element.attributes) {
            map[attr.name.toString()] = attr.value;
          }
          // Convert child elements and text nodes to map entries
          for (var node in element.children) {
            if (node is XmlElement) {
              final childMap = elementToMap(node);
              final nodeName = node.name.toString();
              // Manage duplicates by storing multiple values in a list
              if (map.containsKey(nodeName)) {
                if (map[nodeName] is List) {
                  (map[nodeName] as List).add(childMap);
                } else {
                  map[nodeName] = [map[nodeName], childMap];
                }
              } else {
                map[nodeName] = childMap;
              }
            } else if (node is XmlText && node.text.trim().isNotEmpty) {
              // Add text content directly to the map
              map[element.name.toString()] = node.text.trim();
            }
          }
          return map;
        }

        // Collect status list data
        final List<Map<String, dynamic>> statusListData = document
            .findAllElements('stat')
            .map((element) => elementToMap(element))
            .toList();
        // Convert status data to JSON and print it
        final jsonString = jsonEncode(statusListData);
        print("Status List JSON:");
        print(jsonString);
        // Your existing code for parsing and setting options
        final jobElements = document.findAllElements('stat').where(
                (element) => element.findElements('grpid').single.text == '2000');
        jobStatusOptions.value = jobElements
            .map((element) => element.findElements('nm').single.text)
            .toList();
        final jobExceptionElements = document.findAllElements('stat').where(
                (element) => element.findElements('grpid').single.text == '4000');
        jobExceptionOptions.value = jobExceptionElements
            .map((element) => element.findElements('nm').single.text)
            .toList();
        final fieldExceptionElements = document.findAllElements('stat').where(
                (element) => element.findElements('grpid').single.text == '3000');
        fieldExceptionOptions.value = fieldExceptionElements
            .map((element) => element.findElements('nm').single.text)
            .toList();

        final planElements = document.findAllElements('stat').where(
                (element) => element.findElements('grpid').single.text == '1000');
        planOptions.value = planElements
            .map((element) => element.findElements('nm').single.text)
            .toList();

        print('Status : ${planOptions.value}');
      } else {
        Get.snackbar('Error', 'Failed to fetch status list');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e');
    }
  }
}
