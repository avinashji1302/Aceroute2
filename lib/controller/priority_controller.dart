import 'package:ace_routes/core/colors/Constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PriorityController extends GetxController {
  Future<void> getPriorityData() async {
    String url =
        "https://$baseUrl/mobi?token=$token&nspace=$nsp&geo=<lat,lon>&rid=$rid&action=getprioritylist";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
      } else {
        throw ("something went wrong with priory data");
      }
    } catch (e) {
      throw ("something went wrong with priory data $e");
    }
  }
}
