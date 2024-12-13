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
        //this data is from Note DataTable
        String formattedNotes =
            dbNote.first.data.replaceAll("\\n", "\n").replaceAll('"', '');
        print("formated noted $formattedNotes");
        notes.value = formattedNotes;
      } else {
        print("No notes found in the database.");
        notes.value = "No notes available.";
      }

      // Populate vehicle details
      if (localEvent != null) {
        //this data is coming from event database
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
