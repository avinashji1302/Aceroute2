import 'dart:convert';

import 'package:ace_routes/controller/getOrderPart_controller.dart';
import 'package:ace_routes/core/Constants.dart';
import 'package:ace_routes/database/Tables/OrderTypeDataTable.dart';
import 'package:ace_routes/database/Tables/api_data_table.dart';
import 'package:ace_routes/database/Tables/event_table.dart';
import 'package:ace_routes/database/Tables/login_response_table.dart';
import 'package:ace_routes/model/Status_model_database.dart';
import 'package:ace_routes/model/event_model.dart';
import 'package:ace_routes/model/login_model/login_response.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart' as xml;
import 'package:intl/intl.dart';

import '../core/colors/Constants.dart';
import '../core/xml_to_json_converter.dart';
import '../database/Tables/status_table.dart';
import '../database/databse_helper.dart';
import '../model/login_model/token_api_response.dart';
import 'all_terms_controller.dart';
import 'orderNoteConroller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:intl/intl.dart';

class EventController extends GetxController {
  final allTermsController = Get.put(AllTermsController());
  final getOrderPart = Get.put(GetOrderPartController());

  var events = <Event>[].obs;
  var isLoading = false.obs;
  String wkf = "";
  String tid = '';
  int daysToAdd = 1;
  RxString currentStatus = "Loading...".obs; // Reactive variable
  RxString categoryName = "".obs;
  final OrderNoteController orderNoteController =
      Get.put(OrderNoteController());

  @override
  void onInit() async {
    super.onInit();
    isLoading(true); // Show loading spinner
    await loadAllTerms();
    await fetchEvents();
    isLoading(false); // Show loading spinner

    //Fetching and saving note in db
    await orderNoteController.fetchDetailsFromDb();
    await orderNoteController.fetchOrderNotesFromApi();
  }

  Future<void> loadAllTerms() async {
    print("Loading all terms...");

    await allTermsController.fetchStatusList();
    await allTermsController.fetchAndStoreOrderTypes();
    await allTermsController.displayLoginResponseData();
    Database db = await DatabaseHelper().database;
    await allTermsController.GetAllPartTypes();

    await allTermsController.fetchAndStoreGTypes(db);
    await allTermsController.GetAllTerms();

    await AllTerms.getTerm();
    await getOrderPart.fetchOrderData();
  }

  Future<void> fetchEvents() async {
    DateTime currentDate = DateTime.now();
    DateTime secondDate = currentDate.add(Duration(days: daysToAdd));
    String formattedCurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    String formattedSecondDate = DateFormat('yyyy-MM-dd').format(secondDate);

    isLoading(true);
    var url =
        'https://$baseUrl/mobi?token=$token&nspace=$nsp&geo=$geo&rid=$rid&action=getorders&tz=Asia/Kolkata&from=$formattedCurrentDate&to=$formattedSecondDate';

    print("Fetching events from URL: $url");

    try {
      var request = http.Request('GET', Uri.parse(url));
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String xmlString = await response.stream.bytesToString();
        print("Raw XML response: $xmlString");

        // Parse and store the events
        parseXmlResponse(xmlString);
      } else {
        print("Error fetching events: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error fetching events: $e");
    } finally {
      isLoading(false);
    }
  }

  void parseXmlResponse(String responseBody) {
    final document = xml.XmlDocument.parse(responseBody);
    final eventElements = document.findAllElements('event');

    List<Event> fetchedEvents = eventElements.map((eventElement) {
      return Event(
        id: _getText(eventElement, 'id'),
        cid: _getText(eventElement, 'cid'),
        startDate: _getText(eventElement, 'start_date'),
        etm: _getText(eventElement, 'etm'),
        endDate: _getText(eventElement, 'end_date'),
        name: _getText(eventElement, 'nm'),
        wkf: _getText(eventElement, 'wkf'),
        alt: _getText(eventElement, 'alt'),
        po: _getText(eventElement, 'po'),
        inv: _getText(eventElement, 'inv'),
        tid: _getText(eventElement, 'tid'),
        pid: _getText(eventElement, 'pid'),
        rid: _getText(eventElement, 'rid'),
        ridcmt: _getText(eventElement, 'ridcmt'),
        detail: _getText(eventElement, 'dtl'),
        lid: _getText(eventElement, 'lid'),
        cntid: _getText(eventElement, 'cntid'),
        flg: _getText(eventElement, 'flg'),
        est: _getText(eventElement, 'est'),
        lst: _getText(eventElement, 'lst'),
        ctid: _getText(eventElement, 'ctid'),
        ctpnm: _getText(eventElement, 'ctpnm'),
        ltpnm: _getText(eventElement, 'ltpnm'),
        cnm: _getText(eventElement, 'cnm'),
        address: _getText(eventElement, 'adr'),
        geo: _getText(eventElement, 'geo'),
        cntnm: _getText(eventElement, 'cntnm'),
        tel: _getText(eventElement, 'tel'),
        ordfld1: _getText(eventElement, 'ordfld1'),
        ttid: _getText(eventElement, 'ttid'),
        cfrm: _getText(eventElement, 'cfrm'),
        cprt: _getText(eventElement, 'cprt'),
        xid: _getText(eventElement, 'xid'),
        cxid: _getText(eventElement, 'cxid'),
        tz: _getText(eventElement, 'tz'),
        zip: _getText(eventElement, 'zip'),
        fmeta: _getText(eventElement, 'fmeta'),
        cimg: _getText(eventElement, 'cimg'),
        caud: _getText(eventElement, 'caud'),
        csig: _getText(eventElement, 'csig'),
        cdoc: _getText(eventElement, 'cdoc'),
        cnot: _getText(eventElement, 'cnot'),
        dur: _getText(eventElement, 'dur'),
        val: _getText(eventElement, 'val'),
        rgn: _getText(eventElement, 'rgn'),
        upd: _getText(eventElement, 'upd'),
        by: _getText(eventElement, 'by'),
        znid: _getText(eventElement, 'znid'),
      );
    }).toList();

    for (Event event in fetchedEvents) {
      EventTable.insertEvent(event);
      print("Event added to database: ${event.toJson()}");
    }

    events.assignAll(fetchedEvents);
    print("Fetched and stored ${fetchedEvents.length} events");
    print(jsonEncode("${fetchedEvents[0]}"));
    print("${events}");
    loadEventsFromDatabase();
  }

  String _getText(xml.XmlElement element, String tagName) {
    return element.findElements(tagName).isNotEmpty
        ? element.findElements(tagName).single.text
        : '';
  }

  Future<void> loadEventsFromDatabase() async {
    isLoading(true);
    try {
      List<Event> localEvents = await EventTable.fetchEvents();
      events.assignAll(localEvents);
      print("Loaded ${localEvents.length} events from database");

      for (var data in localEvents) {
        wkf = data.wkf;
        tid = data.tid;
      }

      String? name = await StatusTable.fetchNameById(wkf);
      String? category =
          await OrderTypeDataTable.gettingCategoryThroughTid(tid);
      currentStatus.value = name!;
      categoryName.value = category!;

      print("category  $category");
    } catch (e) {
      print("Error loading events from database: $e");
    } finally {
      isLoading(false);
    }
  }
}

class Event {
  final String id;
  final String cid;
  final String startDate;
  final String etm;
  final String endDate;
  final String name;
  final String wkf;
  final String alt;
  final String po;
  final String inv;
  final String tid;
  final String pid;
  final String rid;
  final String ridcmt;
  final String detail;
  final String lid;
  final String cntid;
  final String flg;
  final String est;
  final String lst;
  final String ctid;
  final String ctpnm;
  final String ltpnm;
  final String cnm;
  final String address;
  final String geo;
  final String cntnm;
  final String tel;
  final String ordfld1;
  final String ttid;
  final String cfrm;
  final String cprt;
  final String xid;
  final String cxid;
  final String tz;
  final String zip;
  final String fmeta;
  final String cimg;
  final String caud;
  final String csig;
  final String cdoc;
  final String cnot;
  final String dur;
  final String val;
  final String rgn;
  final String upd;
  final String by;
  final String znid;

  Event({
    required this.id,
    required this.cid,
    required this.startDate,
    required this.etm,
    required this.endDate,
    required this.name,
    required this.wkf,
    required this.alt,
    required this.po,
    required this.inv,
    required this.tid,
    required this.pid,
    required this.rid,
    required this.ridcmt,
    required this.detail,
    required this.lid,
    required this.cntid,
    required this.flg,
    required this.est,
    required this.lst,
    required this.ctid,
    required this.ctpnm,
    required this.ltpnm,
    required this.cnm,
    required this.address,
    required this.geo,
    required this.cntnm,
    required this.tel,
    required this.ordfld1,
    required this.ttid,
    required this.cfrm,
    required this.cprt,
    required this.xid,
    required this.cxid,
    required this.tz,
    required this.zip,
    required this.fmeta,
    required this.cimg,
    required this.caud,
    required this.csig,
    required this.cdoc,
    required this.cnot,
    required this.dur,
    required this.val,
    required this.rgn,
    required this.upd,
    required this.by,
    required this.znid,
  });

  /// Implemented the `fromJson` function to create an `Event` from JSON
  factory Event.fromJson(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      cid: map['cid'] ?? '',
      startDate: map['start_date'] ?? '',
      etm: map['etm'] ?? '',
      endDate: map['end_date'] ?? '',
      name: map['name'] ?? '',
      wkf: map['wkf'] ?? '',
      alt: map['alt'] ?? '',
      po: map['po'] ?? '',
      inv: map['inv'] ?? '',
      tid: map['tid'] ?? '',
      pid: map['pid'] ?? '',
      rid: map['rid'] ?? '',
      ridcmt: map['ridcmt'] ?? '',
      detail: map['detail'] ?? '',
      lid: map['lid'] ?? '',
      cntid: map['cntid'] ?? '',
      flg: map['flg'] ?? '',
      est: map['est'] ?? '',
      lst: map['lst'] ?? '',
      ctid: map['ctid'] ?? '',
      ctpnm: map['ctpnm'] ?? '',
      ltpnm: map['ltpnm'] ?? '',
      cnm: map['cnm'] ?? '',
      address: map['address'] ?? '',
      geo: map['geo'] ?? '',
      cntnm: map['cntnm'] ?? '',
      tel: map['tel'] ?? '',
      ordfld1: map['ordfld1'] ?? '',
      ttid: map['ttid'] ?? '',
      cfrm: map['cfrm'] ?? '',
      cprt: map['cprt'] ?? '',
      xid: map['xid'] ?? '',
      cxid: map['cxid'] ?? '',
      tz: map['tz'] ?? '',
      zip: map['zip'] ?? '',
      fmeta: map['fmeta'] ?? '',
      cimg: map['cimg'] ?? '',
      caud: map['caud'] ?? '',
      csig: map['csig'] ?? '',
      cdoc: map['cdoc'] ?? '',
      cnot: map['cnot'] ?? '',
      dur: map['dur'] ?? '',
      val: map['val'] ?? '',
      rgn: map['rgn'] ?? '',
      upd: map['upd'] ?? '',
      by: map['by'] ?? '',
      znid: map['znid'] ?? '',
    );
  }

  get startTime => null;
}

extension EventJson on Event {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cid': cid,
      'start_date': startDate,
      'etm': etm,
      'end_date': endDate,
      'name': name,
      'wkf': wkf,
      'alt': alt,
      'po': po,
      'inv': inv,
      'tid': tid,
      'pid': pid,
      'rid': rid,
      'ridcmt': ridcmt,
      'detail': detail,
      'lid': lid,
      'cntid': cntid,
      'flg': flg,
      'est': est,
      'lst': lst,
      'ctid': ctid,
      'ctpnm': ctpnm,
      'ltpnm': ltpnm,
      'cnm': cnm,
      'address': address,
      'geo': geo,
      'cntnm': cntnm,
      'tel': tel,
      'ordfld1': ordfld1,
      'ttid': ttid,
      'cfrm': cfrm,
      'cprt': cprt,
      'xid': xid,
      'cxid': cxid,
      'tz': tz,
      'zip': zip,
      'fmeta': fmeta,
      'cimg': cimg,
      'caud': caud,
      'csig': csig,
      'cdoc': cdoc,
      'cnot': cnot,
      'dur': dur,
      'val': val,
      'rgn': rgn,
      'upd': upd,
      'by': by,
      'znid': znid,
    };
  }
}
