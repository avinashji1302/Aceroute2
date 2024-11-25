import 'dart:convert'; // For JSON encoding
import 'package:ace_routes/database/Tables/event_table.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';
import 'package:ace_routes/core/Constants.dart';
import '../core/colors/Constants.dart';
import '../database/Tables/getOrderPart_table.dart';
import '../database/databse_helper.dart';
import '../model/orderData_model.dart';
import 'event_controller.dart';

class GetOrderPartController extends GetxController{
  Future<void> fetchOrderData() async {
    // final prefs = await SharedPreferences.getInstance();
    // final String token = prefs.getString("token") ?? '';
    // final String rid = prefs.getString("rid") ?? '';
    // final String nsp = prefs.getString("nsp") ?? '';

    // Fetch the event from the EventTable
    final List<Event> events = await EventTable.fetchEvents();
    if (events.isEmpty) {
      print('No events found.');
      return;
    }

    // Use the first event's ID (or modify logic to select the appropriate event)
    final String eventId = events.first.id;
    print('eventId : $eventId');
    final url =
    //'https://$baseUrl/mobi?token=$token&nspace=$nsp&geo=<lat,lon>&rid=$rid&action=getorderpart&oid=72563';
        'https://$baseUrl/mobi?token=$token&nspace=$nsp&geo=<lat,lon>&rid=$rid&action=getorderpart&oid=$eventId';
    final response = await http.get(Uri.parse(url));
    print('getorderpart APIURL : $url');
    if (response.statusCode == 200) {
      // Parse XML response
      final xmlDoc = XmlDocument.parse(response.body);
      // print(xmlDoc);
      // Extract data into a map
      final List<OrderData> orders = xmlDoc.findAllElements('oprt').map((node) {
        return OrderData(
          id: node.findElements('id').single.text,
          oid: node.findElements('oid').single.text,
          tid: node.findElements('tid').single.text,
          sku: node.findElements('sku').single.text,
          qty: int.parse(node.findElements('qty').single.text),
          upd: node.findElements('upd').single.text,
          by: node.findElements('by').single.text,
        );
      }).toList();

      // Save each order into the database
      for (var order in orders) {
        await GetOrderPartTable.insertData(await DatabaseHelper().database, order);
      }
      // Convert data to JSON and print it
      print(jsonEncode(orders.map((order) => order.toJson()).toList()));
    } else {
      // Handle error
      print('Error: ${response.reasonPhrase}');
    }
  }
}