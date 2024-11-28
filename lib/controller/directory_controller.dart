import 'package:get/get.dart';

import '../database/Tables/event_table.dart';
import 'event_controller.dart';

class DirectoryController extends GetxController {
  final String id;

  DirectoryController(this.id);

  RxString address = "".obs;
  RxString address2 = "".obs;
  RxString customerName = "".obs;
  RxString customerMobile = "".obs;
  RxString ctpnm = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchDirectoryDetailsFromDb();
    print("I am here in directory");
  }

  Future<void> fetchDirectoryDetailsFromDb() async {
    Event? localEvent = await EventTable.fetchEventById(id);

    if (localEvent != null) {
      address.value = localEvent.address;
      address2.value = localEvent.address;
      customerMobile.value = localEvent.tel;
      ctpnm.value = localEvent.ctpnm;
      customerName.value=localEvent.cnm;

      print("Local events ${address.value}");
    }
  }
}
