import 'dart:convert'; // For JSON encoding
import 'package:ace_routes/database/Tables/event_table.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';
import 'package:ace_routes/core/Constants.dart';
import '../core/colors/Constants.dart';
import '../database/Tables/genTypeTable.dart';
import '../database/Tables/PartTypeDataTable.dart';
import '../database/Tables/getOrderPartTable.dart';
import '../database/databse_helper.dart';
import '../model/GTypeModel.dart';
import '../model/Ptype.dart';
import '../model/orderPartsModel.dart';
import 'event_controller.dart';

class GetOrderPartController extends GetxController {
  RxString sku = "".obs;
  RxString quantity = "".obs;
  RxString name = "".obs;
  RxString detail = "".obs;
  RxString tidOP = "".obs;

  Future<void> fetchOrderData(String oid) async {
    print("inside fetch");
    try {
      final url =
          'https://$baseUrl/mobi?token=$token&nspace=$nsp&geo=<lat,lon>&rid=$rid&action=getorderpart&oid=$oid';

      final response = await http.get(Uri.parse(url));
      print('getorderpart API URL: $url');

      if (response.statusCode == 200) {
        print('Response Body:\n${response.body}'); // Debug the response body

        final xmlDoc = XmlDocument.parse(response.body);

        // Extract and parse `<oprt>` elements
        final List<OrderParts> orders = xmlDoc
            .findAllElements('oprt')
            .map((node) {
              String getElementText(String tag) {
                final element = node.findElements(tag).isEmpty
                    ? null
                    : node.findElements(tag).single;
                return element?.text ?? ''; // Provide a default value for null
              }

              return OrderParts(
                id: getElementText('id'),
                oid: getElementText('oid'),
                tid: getElementText('tid'),
                sku: getElementText('sku'),
                qty: getElementText('qty'),
                upd: getElementText('upd'),
                by: getElementText('by'),
              );
            })
            .where((order) => order.id.isNotEmpty) // Filter out invalid data
            .toList();

        if (orders.isEmpty) {
          print('No order parts found in the XML response.');
          return;
        }

        print(
            'Parsed Orders:\n${jsonEncode(orders.map((e) => e.toJson()).toList())}');

        // Insert each order into the database
        for (var order in orders) {
          await GetOrderPartTable.insertData(order);
          print('Inserted order into DB: ${order.toJson()}');
        }

        // Verify data in the database
        final List<OrderParts> dbOrders = await GetOrderPartTable.fetchData();
        if (dbOrders.isEmpty) {
          print('No order parts found in the database after insertion.');
        } else {
          print(
              'Orders in DB:\n${jsonEncode(dbOrders.map((e) => e.toJson()).toList())}');
        }
      } else {
        print('Error fetching order data. Status Code: ${response.statusCode}');
        print('Reason: ${response.reasonPhrase}');
      }

      //   await GetOrderPartFromDb();
    } catch (e) {
      print('Error in fetchOrderData: $e');
    }
  }

  //
  Future<void> GetOrderPartFromDb(String oid) async {

    print("isnide");
    try {
      //  getorderpart
      OrderParts? orderParts = await GetOrderPartTable.fetchDataById(oid);
      if (orderParts != null) {
        sku.value = orderParts.sku;
        quantity.value = orderParts.qty;
        tidOP.value = orderParts.tid;
      }
      {
        print('No GType found for tidOP: ${tidOP.value}');
      }

      // Get Part Type
      PartTypeDataModel? fetchedPartType =
          await PartTypeDataTable.fetchPartTypeById(tidOP.value);

      if (fetchedPartType != null) {
        name.value = fetchedPartType.name;
        detail.value = fetchedPartType.detail;
      } else {
        print('No GType found for tidOP: ${tidOP.value}');
      }

      print(
          'Data: ${name.value}, ${quantity.value}, ${tidOP.value}, ${detail.value}');
    } catch (e) {
      print('Error in GetOrderPartFromDb: $e');
    }
  }
}
