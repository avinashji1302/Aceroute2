import 'package:ace_routes/database/Tables/api_data_table.dart';
import 'package:ace_routes/database/Tables/event_table.dart';
import 'package:ace_routes/database/Tables/login_response_table.dart';
import 'package:ace_routes/model/event_model.dart';
import 'package:ace_routes/model/login_model/login_response.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

import '../model/login_model/token_api_response.dart';

class EventController extends GetxController {
  var events = <Event>[].obs;
  var isLoading = false.obs;

  String token1 = "";
  String rid = "";
  String nspace = "";
  String geo = "";
  String time = "";
  String webUrl = "";
  String timeZone = "";

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
    // loadEventsFromDatabase();
  }

  // Fetch events from the local database and populate the events list
  Future<void> loadEventsFromDatabase() async {

    print('I am here in loadeventDatabase');
    isLoading(true);
    try {
      List<Event> localEvents = await EventTable.fetchEvents();
      events.assignAll(localEvents); // Populate the events list

      print(" databse data is here ::::${events.length}");
    } catch (e) {
      print("Error loading events from database: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchEvents() async {

    List<TokenApiReponse> dataList = await ApiDataTable.fetchData();
    List<LoginResponse> loginDataList =
        await LoginResponseTable.fetchLoginResponses();
    for (var data in dataList) {
      token1 = data.token;
      // rid=data.requestId;
      geo = data.geoLocation;

      print("$geo $rid $token1");
    }

    for (var data in loginDataList) {
      webUrl = data.url;
      nspace = data.nsp;
    }

    token1 = token1.trim();
    print("token1  geo location $rid $geo  $token1 $webUrl $nspace");
    print(token1);

    // String? nspace = prefs.getString("nspace");
    // int? rid = prefs.getInt("rid");

    print("---------------------------------------------------------");

    print(nspace);
    print(rid);
    print("---------------------------------------------------------");
    isLoading(true);
    var url =
        'https://${webUrl}/mobi?token=$token1&nspace=${nspace}&geo=$geo&rid=$rid&action=getorders&tz=Asia/Kolkata&from=2024-10-29&to=2024-10-30';
    print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');

    print('xxxxxxxxxxxxxxxxxxxxxxxxxxxx');
    try {
      var request = http.Request('GET', Uri.parse(url));
      http.StreamedResponse response = await request.send();
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      if (response.statusCode == 200) {
        String xmlString = await response.stream.bytesToString();
        print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
        print('${xmlString}');
        print('xxxxxxxxxxxxxxxxxxxxxxxxxxxx');

        parseXmlResponse(xmlString);

        print('xxxxxxxxxxxxx======xxxxxxxxxxxxxxxxxxxxxxxxx');
        print('${parseXmlResponse}');
        print('xxxxxxxxxxxxx============xxxxxxxxxxxxxxx');
      } else {
        print("Error: ${response.reasonPhrase}");
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
        id: eventElement.findElements('id').single.text ?? '',
        cid: eventElement.findElements('cid').single.text ?? '',
        startDate: eventElement.findElements('start_date').single.text ?? '',
        etm: eventElement.findElements('etm').single.text ?? '',
        endDate: eventElement.findElements('end_date').single.text ?? '',
        name: eventElement.findElements('nm').single.text ?? '',
        wkf: eventElement.findElements('wkf').single.text ?? '',
        alt: eventElement.findElements('alt').single.text ?? '',
        po: eventElement.findElements('po').single.text ?? '',
        inv: eventElement.findElements('inv').single.text ?? '',
        tid: eventElement.findElements('tid').single.text ?? '',
        pid: eventElement.findElements('pid').single.text ?? '',
        rid: eventElement.findElements('rid').single.text ?? '',
        ridcmt: eventElement.findElements('ridcmt').single.text ?? '',
        detail: eventElement.findElements('dtl').single.text ?? '',
        lid: eventElement.findElements('lid').single.text ?? '',
        cntid: eventElement.findElements('cntid').single.text ?? '',
        flg: eventElement.findElements('flg').single.text ?? '',
        est: eventElement.findElements('est').single.text ?? '',
        lst: eventElement.findElements('lst').single.text ?? '',
        ctid: eventElement.findElements('ctid').single.text ?? '',
        ctpnm: eventElement.findElements('ctpnm').single.text ?? '',
        ltpnm: eventElement.findElements('ltpnm').single.text ?? '',
        cnm: eventElement.findElements('cnm').single.text ?? '',
        address: eventElement.findElements('adr').single.text ?? '',
        geo: eventElement.findElements('geo').single.text ?? '',
        cntnm: eventElement.findElements('cntnm').single.text ?? '',
        tel: eventElement.findElements('tel').single.text ?? '',
        ordfld1: eventElement.findElements('ordfld1').single.text ?? '',
        ttid: eventElement.findElements('ttid').single.text ?? '',
        cfrm: eventElement.findElements('cfrm').single.text ?? '',
        cprt: eventElement.findElements('cprt').single.text ?? '',
        xid: eventElement.findElements('xid').single.text ?? '',
        cxid: eventElement.findElements('cxid').single.text ?? '',
        tz: eventElement.findElements('tz').single.text ?? '',
        zip: eventElement.findElements('zip').single.text ?? '',
        fmeta: eventElement.findElements('fmeta').single.text ?? '',
        cimg: eventElement.findElements('cimg').single.text ?? '',
        caud: eventElement.findElements('caud').single.text ?? '',
        csig: eventElement.findElements('csig').single.text ?? '',
        cdoc: eventElement.findElements('cdoc').single.text ?? '',
        cnot: eventElement.findElements('cnot').single.text ?? '',
        dur: eventElement.findElements('dur').single.text ?? '',
        val: eventElement.findElements('val').single.text ?? '',
        rgn: eventElement.findElements('rgn').single.text ?? '',
        upd: eventElement.findElements('upd').single.text ?? '',
        by: eventElement.findElements('by').single.text ?? '',
        znid: eventElement.findElements('znid').single.text ?? '',
      );

      // Insert each event into the database
    }).toList();

    // Insert each event into the database
    for (Event event in fetchedEvents) {
      EventTable.insertEvent(event);

      print("Evernt added in databse ${event}");
    }

    events.assignAll(fetchedEvents);
    print("here is data from somethign");
    loadEventsFromDatabase();
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
  final String
      address; // Updated field name to avoid conflict with reserved keyword
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
