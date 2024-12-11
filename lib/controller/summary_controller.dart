import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../database/Tables/event_table.dart'; // EventTable for DB operations
import 'event_controller.dart';

class SummaryController extends GetxController {
  // Collecting summary data
  RxString eventId = "".obs;
  RxString nm = "".obs;
  RxString startTime = "".obs;
  RxString category = "".obs;
  RxString duration = "".obs;
  RxString startDate = "".obs;

  final String id; // Add an id parameter

  SummaryController(this.id); // Constructor to accept id

  void onInit() {
    super.onInit();
    fetchSummaryDetails();

    print("id is $id");
  }

  Future<void> fetchSummaryDetails() async {
    //this data is coming from event database
    Event? localEvent = await EventTable.fetchEventById(id);

    if (localEvent != null) {
      eventId.value = localEvent.id ?? '';
      nm.value = localEvent.name ?? '';
      startTime.value = localEvent.startTime ??
          ''; // Assuming startTime exists in Event model
      startDate.value = localEvent.startDate ??
          ''; // Assuming startDate exists in Event model

      // Format startDate using the formatEventDate method
      startDate.value = formatEventDate(startDate.value);

      duration.value =
          localEvent.dur ?? ''; // Assuming duration exists in Event model
    } else {
      print("No event found for the given ID");
    }
  }

  // Function to format the event date and time
  String formatEventDate(String? startDate) {
    if (startDate == null || startDate.isEmpty) {
      return "No Time";
    }

    try {
      // Define the expected input format (e.g., "2024/11/26 8:30 -00:00")
      DateFormat inputFormat = DateFormat("yyyy/MM/dd HH:mm Z");

      // Parse the date string into a DateTime object
      DateTime date = inputFormat.parse(startDate);

      // Format to "MMM" (e.g., Nov)
      String formattedDate = DateFormat("MMM dd yyyy").format(date);

      // Format local time (e.g., "1:30 PM")
      String localTime = DateFormat.jm().format(date.toLocal());
      startTime.value = localTime;
      return "$formattedDate";
    } catch (e) {
      return "Invalid date";
    }
  }
}
