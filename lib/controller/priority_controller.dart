import 'dart:convert';

import 'package:ace_routes/core/colors/Constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../database/Tables/prority_table.dart';
import '../model/priority_model.dart';

class PriorityController extends GetxController {
  Future<void> getPriorityData() async {
    String url =
        "https://$baseUrl/mobi?token=$token&nspace=$nsp&geo=<lat,lon>&rid=$rid&action=getprioritylist";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        List<Priority> fetchedPriorities =
            jsonData.map((data) => Priority.fromJson(data)).toList();

        // Store in local database
        for (var priority in fetchedPriorities) {
          await PriorityTable.insertPriority(priority);

          print("priority data inserted successfully");
        }
      } else {
        throw ("something went wrong with priory data");
      }
    } catch (e) {
      throw ("something went wrong with priory data $e");
    }
  }
}
