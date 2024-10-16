import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pubnub/pubnub.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

class StatusController extends GetxController {
  // Observable list to store the status options
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

  //--------------------------------------------------

  // Fetch status list from the API
  Future<void> fetchStatusList() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token") ?? '';

    print('token $token ..');
    final String url =
        'https://portal.aceroute.com/mobi?action=getstatuslist&tstmp=1728299643388&token=$token&nspace=demo.com&rid=136675&cts=1728299645320';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);

        // Parsing Job Status
        final jobElements = document.findAllElements('stat').where(
            (element) => element.findElements('grpid').single.text == '2000');
        jobStatusOptions.value = jobElements
            .map((element) => element.findElements('nm').single.text)
            .toList();

        // Parsing Job Exception
        final jobExceptionElements = document.findAllElements('stat').where(
            (element) => element.findElements('grpid').single.text == '4000');
        jobExceptionOptions.value = jobExceptionElements
            .map((element) => element.findElements('nm').single.text)
            .toList();

        // Parsing Field Exception
        final fieldExceptionElements = document.findAllElements('stat').where(
            (element) => element.findElements('grpid').single.text == '3000');
        fieldExceptionOptions.value = fieldExceptionElements
            .map((element) => element.findElements('nm').single.text)
            .toList();

        // Parsing Plan
        final planElements = document.findAllElements('stat').where(
            (element) => element.findElements('grpid').single.text == '1000');
        planOptions.value = planElements
            .map((element) => element.findElements('nm').single.text)
            .toList();

        print('Status : ${planOptions.value}  $planElements ${response.body} ');
      } else {
        Get.snackbar('Error', 'Failed to fetch status list');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e');
    }
  }
}
