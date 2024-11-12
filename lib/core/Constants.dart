import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../database/Tables/terms_data_table.dart';
import '../model/terms_model.dart';

var BaseURL = 'https://portal.aceroute.com';

// Future<void> displayDataFromDb() async {
//   List<TokenApiReponse> dataList = await ApiDataTable.fetchData();
//
//   for (var data in dataList) {
//     print('Responder Name:  ${data.responderName}');
//     print('GeoLocation: ${data.geoLocation}');
//   }
// }
class AllTerms extends GetxController{

  static Future<void> getTerm() async{
    List<TermsDataModel> dataList = await TermsDataTable.fetchTermsData();

    for(var data in dataList){
      print(data);
    }
  }


}



