import 'package:ace_routes/database/Tables/order_note_table.dart';
import 'package:ace_routes/model/order_note_model.dart';
import 'package:get/get.dart';
import '../database/Tables/event_table.dart';
import 'event_controller.dart';

class VehicleController extends GetxController {
  final String id;
  VehicleController(this.id);

  // Collecting summary data
  RxString vehicleDetail = "".obs;
  RxString registration = "".obs;
  RxString odometer = "".obs;
  RxString faultDesc = "".obs;
  RxString notes = "".obs;

  onInit() async {
    super.onInit();
    GetVehicleDetails();
  }

  Future<void> GetVehicleDetails() async {
    try {
      // Fetch data from the database
      Event? localEvent = await EventTable.fetchEventById(id);
      List<OrderNoteModel> dbNote = await OrderNoteTable.fetchOrderNote();

      // Debugging fetched notes
      if (dbNote.isNotEmpty) {
        print("First note: ${dbNote.first.data}");
        // Split the note by '\n' and keep the new line formatting intact
        String formattedNotes = dbNote.first.data.replaceAll('"\n"', '      ');

        print("formated noted $formattedNotes");
        // Assign the formatted notes value
        notes.value = formattedNotes;
      } else {
        print("No notes found in the database.");
        notes.value = "No notes available.";
      }

      // Populate vehicle details
      if (localEvent != null) {
        vehicleDetail.value = localEvent.detail;
        registration.value = localEvent.po;
        odometer.value = localEvent.inv;
        faultDesc.value = localEvent.alt;

        print("Vehicle details: ${vehicleDetail.value}");
      } else {
        print("No event data found for ID 77611.");
      }
    } catch (e) {
      print("Error in GetVehicleDetails: $e");
    }
  }
}
