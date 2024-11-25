import 'package:get/get.dart';
import '../database/Tables/status_table.dart';
import '../model/Status_model_database.dart';

class StatusControllers extends GetxController {

  var organizedData = <String, List<Status>>{}.obs;

  // Organize the data into groups
  Future<void> organizeData() async {
    List<Status> statusData = await StatusTable.fetchStatusData();
    Map<String, Status> groups = {}; // Holds groups by group sequence
    List<Status> items = [];         // Holds non-group items

    // Step 1: Classify data into groups and non-group items
    for (var status in statusData) {
      if (status.isGroup == "1") {
        groups[status.groupId] = status; // Add groups to the map by groupId
      } else {
        items.add(status); // Add non-group items to the list
      }
    }

    // Step 2: Sort groups by their group sequence (grpseq)
    var sortedGroups = groups.values.toList()
      ..sort((a, b) => (int.tryParse(a.groupSequence) ?? 0).compareTo(int.tryParse(b.groupSequence) ?? 0));

    // Step 3: Initialize the organizedData map with the groups
    var organizedDataTemp = <String, List<Status>>{};

    for (var group in sortedGroups) {
      organizedDataTemp[group.name] = [];
    }

    // Step 4: Add non-group items to their respective group
    for (var item in items) {
      var group = groups[item.groupId];  // Get the group based on groupId

      if (group != null) {
        organizedDataTemp[group.name]?.add(item);

      }
    }

    // Step 5: Sort the items inside each group by their seq value
    for (var groupName in organizedDataTemp.keys) {
      organizedDataTemp[groupName]!.sort((a, b) =>
          (int.tryParse(a.sequence) ?? 0).compareTo(int.tryParse(b.sequence) ?? 0));
    }

    // Step 6: Update the RxMap to trigger the UI update
    organizedData.assignAll(organizedDataTemp);
  }

}
