import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../database/Tables/event_table.dart';
import 'event_controller.dart';

class MapControllers extends GetxController {
  // Use .obs to make orderLocations observable
  RxList<LatLng> orderLocations = <LatLng>[].obs;
  RxList orders = [].obs;

  // Fetch the order locations
  Future<void> FetchAllOrderLocation() async {
    try {
      List<Event> allEventData = await EventTable.fetchEvents();
      print("Fetching all events...");

      // Clear the list before adding new locations
      orderLocations.clear();

      for (var data in allEventData) {
        print("data is $data");

        orders.add(data);
        var geoParts = data.geo.split(',');
        print("geoparts $geoParts");
        if (geoParts.length == 2) {
          double? latitude = double.tryParse(geoParts[0]);
          double? longitude = double.tryParse(geoParts[1]);

          if (latitude != null && longitude != null) {
            // Add new LatLng to the observable list
            orderLocations.add(LatLng(latitude, longitude));
            print("Added geo location: LatLng($latitude, $longitude)");
          } else {
            print("Invalid latitude or longitude in: ${data.geo}");
          }
        } else {
          print("Invalid geo format: ${data.geo}");
        }
      }

      print("All geo locations: $orderLocations");
    } catch (e) {
      print("Error fetching order locations: $e");
    }
  }
}
