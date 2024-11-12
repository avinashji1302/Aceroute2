import 'dart:convert';
import 'package:ace_routes/core/Constants.dart';
import 'package:ace_routes/core/xml_to_json_converter.dart';
import 'package:ace_routes/database/Tables/OrderTypeDataTable.dart';
import 'package:ace_routes/database/Tables/login_response_table.dart';
import 'package:ace_routes/database/Tables/terms_data_table.dart';
import 'package:ace_routes/model/OrderTypeModel.dart';
import 'package:ace_routes/model/login_model/login_response.dart';
import 'package:ace_routes/model/login_model/token_api_response.dart';
import 'package:ace_routes/model/terms_model.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml.dart';
import '../database/Tables/GTypeTable.dart';
import '../database/Tables/PartTypeDataTable.dart';
import '../database/Tables/api_data_table.dart';
import '../database/Tables/status_table.dart';
import '../model/GTypeModel.dart';
import '../model/Ptype.dart';
import '../model/Status_model_database.dart';

class AllTermsController {
  String token = "";
  String accountName = "";
  String workerRid = "";
  String url = "";
  String rid = "";


  var jobStatusOptions = <String>[].obs;
  var jobExceptionOptions = <String>[].obs;
  var fieldExceptionOptions = <String>[].obs;
  var planOptions = <String>[].obs;

  String getElementText(XmlDocument xml, String tagName) {
    final elements = xml.findAllElements(tagName);
    return elements.isNotEmpty ? elements.single.text : '';
  }

  Future<void> GetAllTerms() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token") ?? '';
    final String rid = prefs.getString("rid") ?? '';

    final requestUrl =
        "$BaseURL/mobi?token=$token&nspace=${accountName}&geo=<lat,lon>&rid=$rid&action=getterm";
    print(" Step 4 call 1 Default label : get term URL: ${requestUrl}");

    final response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      // Map<String, dynamic> jsonResponse = xmlToJson(response.body);
      // print(' Converted JSON Response: ${jsonEncode(jsonResponse)}');

       final xmlResponse = XmlDocument.parse(response.body);


      // Extracting XML data safely
      final termsDataMap = {
        "namespace": getElementText(xmlResponse, 'nsp'),
        "locationCode": getElementText(xmlResponse, 'lofc'),
        "formName": getElementText(xmlResponse, 'lfrm'),
        "partName": getElementText(xmlResponse, 'lprt'),
        "assetName": getElementText(xmlResponse, 'lass'),
        "pictureLabel": getElementText(xmlResponse, 'lpic'),
        "audioLabel": getElementText(xmlResponse, 'laud'),
        "signatureLabel": getElementText(xmlResponse, 'lsig'),
        "fileLabel": getElementText(xmlResponse, 'lfil'),
        "workLabel": getElementText(xmlResponse, 'lwrk'),
        "customerLabel": getElementText(xmlResponse, 'lcst'),
        "orderLabel": getElementText(xmlResponse, 'lord'),
        "customerReferenceLabel": getElementText(xmlResponse, 'lordnm'),
        "registrationLabel": getElementText(xmlResponse, 'lpo'),
        "odometerLabel": getElementText(xmlResponse, 'linv'),
        "detailsLabel": getElementText(xmlResponse, 'ldtl'),
        "faultDescriptionLabel": getElementText(xmlResponse, 'lalt'),
        "notesLabel": getElementText(xmlResponse, 'lnot'),
        "summaryLabel": getElementText(xmlResponse, 'lsum'),
        "orderGroupLabel": getElementText(xmlResponse, 'lordgrp'),
        "fieldOrderRules": getElementText(xmlResponse, 'fldordrls'),
        "invoiceEmailLabel": getElementText(xmlResponse, 'lordfld1'),
      };

      // Convert map to JSON string and print it
      final jsonString = jsonEncode(termsDataMap);

      print("GetTerms Data JSON: $jsonString");

      // Insert terms data into the database
      TermsDataModel termsDataModel = TermsDataModel(
        namespace: termsDataMap["namespace"]!,
        locationCode: termsDataMap["locationCode"]!,
        formName: termsDataMap["formName"]!,
        partName: termsDataMap["partName"]!,
        assetName: termsDataMap["assetName"]!,
        pictureLabel: termsDataMap["pictureLabel"]!,
        audioLabel: termsDataMap["audioLabel"]!,
        signatureLabel: termsDataMap["signatureLabel"]!,
        fileLabel: termsDataMap["fileLabel"]!,
        workLabel: termsDataMap["workLabel"]!,
        customerLabel: termsDataMap["customerLabel"]!,
        orderLabel: termsDataMap["orderLabel"]!,
        customerReferenceLabel: termsDataMap["customerReferenceLabel"]!,
        registrationLabel: termsDataMap["registrationLabel"]!,
        odometerLabel: termsDataMap["odometerLabel"]!,
        detailsLabel: termsDataMap["detailsLabel"]!,
        faultDescriptionLabel: termsDataMap["faultDescriptionLabel"]!,
        notesLabel: termsDataMap["notesLabel"]!,
        summaryLabel: termsDataMap["summaryLabel"]!,
        orderGroupLabel: termsDataMap["orderGroupLabel"]!,
        fieldOrderRules: termsDataMap["fieldOrderRules"]!,
        invoiceEmailLabel: termsDataMap["invoiceEmailLabel"]!,
      );

      await TermsDataTable.insertTermsData(termsDataModel);
      print('  Terms data Successfully added to the database');
    } else {
      Get.snackbar('Error', 'Failed to fetch terms data');
    }
  }

  /// getparttype API to save the data ----------------------------

  Future<void> GetAllPartTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token") ?? '';
    final String rid = prefs.getString("rid") ?? '';
    final String nsp = prefs.getString("nsp") ?? '';

    final requestUrl =
        "$BaseURL/mobi?token=$token&nspace=$nsp&geo=<lat,lon>&rid=$rid&action=getparttype";
    final response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      print(" Step 4 call 2 Default Part Type : get term URL: $requestUrl");
      final xmlResponse = XmlDocument.parse(response.body);

      // Parse each <ptype> element and create PartTypeDataModel instances
      final partTypesList = xmlResponse.findAllElements('ptype').map((element) {
        return PartTypeDataModel(
          id: element.findElements('id').single.text,
          name: element.findElements('nm').single.text,
          detail: element.findElements('dtl').single.text,
          unitPrice: element.findElements('upr').single.text,
          unit: element.findElements('unt').single.text,
          updatedBy: element.findElements('by').single.text,
          updatedDate: element.findElements('upd').single.text,
        );
      }).toList();

      // Convert the list of PartTypeDataModel instances to a JSON string
      final jsonString =
          jsonEncode(partTypesList.map((pt) => pt.toJson()).toList());

      // Print JSON string to console
      print("Converted JSON:\n$jsonString");

      // Saving each PartTypeDataModel instance in the database
      for (var partType in partTypesList) {
        await PartTypeDataTable.insertPartTypeData(partType);
      }

      print('Successfully added part type data to the database');
    } else {
      print("Failed to load parttype data: ${response.reasonPhrase}");
    }
  }

  /// getStoreOrderTypes API to save the data ----------------------------

  Future<void> fetchAndStoreOrderTypes(Database db) async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token") ?? '';
    final String rid = prefs.getString("rid") ?? '';
    final String nsp = prefs.getString("nsp") ?? '';

    final requestUrl = '$BaseURL/mobi?token=$token&nspace=$nsp&geo=<lat,lon>&rid=$rid&action=getordertype';
    var request = http.Request(
      'GET',
      Uri.parse(
          requestUrl
      ),
    );

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      print(" Step 4 call 4 Default Get Order Type :  URL: $requestUrl");
      // Parse the XML response
      var document = xml.XmlDocument.parse(responseBody);
      var otypes = document.findAllElements('otype');

      // List to hold JSON representations of each order type
      List<Map<String, dynamic>> orderTypesList = [];

      for (var otype in otypes) {
        // Create a map for each otype and add to the list
        var orderTypeMap = {
          "id": otype.findElements('id').single.text,
          "name": otype.findElements('nm').single.text,
          "abbreviation": otype.findElements('abr').single.text,
          "duration": int.parse(otype.findElements('dur').single.text),
          "capacity": int.parse(otype.findElements('cap').single.text),
          "parentId": int.parse(otype.findElements('pid').single.text),
          "customTimeSlot":
              int.parse(otype.findElements('ctmslot').single.text),
          "elapseTimeSlot": otype.findElements('eltmslot').single.text,
          "value": double.parse(otype.findElements('val').single.text),
          "externalId": otype.findElements('xid').isNotEmpty
              ? otype.findElements('xid').single.text
              : '',
          "updateTimestamp": otype.findElements('upd').single.text,
          "updatedBy": otype.findElements('by').single.text,
        };

        orderTypesList.add(orderTypeMap);

        // Insert into database
        var orderType = OrderTypeModel.fromMap(orderTypeMap);
        await OrderTypeDataTable.insertOrderTypeData(db, orderType);
      }

      // Convert list of order types to JSON and print
      final jsonString = jsonEncode(orderTypesList);
      print("Converted JSON:\n$jsonString");

      print('Data inserted successfully');
    } else {
      print('Request failed with status: ${response.reasonPhrase}');
    }
  }


  //--------------status type--------------
  Future<void> fetchStatusList() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token") ?? '';
    final String rid = prefs.getString("rid") ?? '';
    final String nsp = prefs.getString("nsp") ?? '';

    final String url =
        '$BaseURL/mobi?token=$token&nspace=$nsp&geo=<lat,lon>&rid=$rid&action=getstatuslist';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print(" Step 4 call 5 Default Get Order Type :  URL: $url");
        // Convert XML response to JSON list
        final statusJsonList = parseStatusListToJson(response.body);

        // Save JSON data to database
        await StatusTable.insertStatusList(statusJsonList);

        print("Data saved to database successfully");
      } else {
        Get.snackbar('Error', 'Failed to fetch status list');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e');
    }
  }


  /// getStoreGTypes API to save the data ----------------------------

  Future<void> fetchAndStoreGTypes(Database db) async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token") ?? '';
    final String rid = prefs.getString("rid") ?? '';
    final String nsp = prefs.getString("nsp") ?? '';


    final requestUrl ='$BaseURL/mobi?token=$token&nspace=${nsp}&geo=<lat,lon>&rid=$rid&action=getgentype';
    var request = http.Request(
      'GET',
      Uri.parse(
          requestUrl
      ),
    );

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(" Step 4 call 6 Default Get Gen Type :  URL: $requestUrl");
      String responseBody = await response.stream.bytesToString();

      // Parse the XML response
      var document = xml.XmlDocument.parse(responseBody);
      var gtypes = document.findAllElements('gtype');

      // Convert XML to JSON
      List<Map<String, dynamic>> gtypesList = [];

      for (var gtype in gtypes) {
        var gTypeMap = {
          'id': gtype.findElements('id').single.text,
          'name': gtype.findElements('nm').single.text,
          'typeId': gtype.findElements('tid').single.text,
          'capacity': gtype.findElements('cap').single.text,
          'details': gtype.findElements('dtl').single.text,
          'externalId': gtype.findElements('xid').single.text,
          'updateTimestamp': gtype.findElements('upd').single.text,
          'updatedBy': gtype.findElements('by').single.text,
        };

        // Add the map to the list
        gtypesList.add(gTypeMap);
      }

      // Convert the list of maps (gtypesList) to JSON
      String jsonString = jsonEncode(gtypesList);

      // Print the JSON string
      print("Converted JSON:\n$jsonString");

      // Clear existing data
      await GTypeTable.clearTable(db);

      // Save each gtype entry to the table
      for (var gTypeMap in gtypesList) {
        var gTypeModel = GTypeModel.fromJson(gTypeMap);
        await GTypeTable.insertGType(db, gTypeModel);
      }

      print('GType data inserted successfully');
    } else {
      print('Request failed with status: ${response.reasonPhrase}');
    }
  }

  Future<void> displayLoginResponseData() async {
    // Fetch the list of login responses from the database
    List<LoginResponse> dataList =
        await LoginResponseTable.fetchLoginResponses();

    // Optionally print each field separately
    for (var data in dataList) {
      accountName = data.nsp;
      url = data.url;
    }

    //-------------------------
    List<TokenApiReponse> tokenData = await ApiDataTable.fetchData();

    for (var data in tokenData) {
      token = data.token;
      // print('Token: ${data.token}');
      // print('Responder Name: ${data.responderName}');
      // print('GeoLocation: ${data.geoLocation}');
    }
  }
}
List<Map<String, dynamic>> parseStatusListToJson(String xmlString) {
  final document = XmlDocument.parse(xmlString);
  final statusElements = document.findAllElements('stat');
  return statusElements.map((element) => Status.fromXmlElement(element).toJson()).toList();
}
