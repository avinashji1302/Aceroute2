import 'package:xml/xml.dart';

class TokenApiReponse {
  final int requestId;
  final String responderName;
  final String geoLocation;
  final String nspId;
  final int gpsSync;
  final int locationChange;
  final int shiftDateLock;
  final int shiftError;
  final int endValue;
  final int speed;
  final int multiLeg;
  final String uiConfig;
  final String token;

  TokenApiReponse({
    required this.requestId,
    required this.responderName,
    required this.geoLocation,
    required this.nspId,
    required this.gpsSync,
    required this.locationChange,
    required this.shiftDateLock,
    required this.shiftError,
    required this.endValue,
    required this.speed,
    required this.multiLeg,
    required this.uiConfig,
    required this.token,
  });

  // Convert an TokenApiReponse object into a Map.
  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'responderName': responderName,
      'geoLocation': geoLocation,
      'nspId': nspId,
      'gpsSync': gpsSync,
      'locationChange': locationChange,
      'shiftDateLock': shiftDateLock,
      'shiftError': shiftError,
      'endValue': endValue,
      'speed': speed,
      'multiLeg': multiLeg,
      'uiConfig': uiConfig,
      'token': token,
    };
  }

  // Extract an TokenApiReponse object from a Map.
  factory TokenApiReponse.fromMap(Map<String, dynamic> map) {
    return TokenApiReponse(
      requestId: map['requestId'],
      responderName: map['responderName'],
      geoLocation: map['geoLocation'],
      nspId: map['nspId'],
      gpsSync: map['gpsSync'],
      locationChange: map['locationChange'],
      shiftDateLock: map['shiftDateLock'],
      shiftError: map['shiftError'],
      endValue: map['endValue'],
      speed: map['speed'],
      multiLeg: map['multiLeg'],
      uiConfig: map['uiConfig'],
      token: map['token'],
    );
  }

  factory TokenApiReponse.fromXml(XmlElement xml) {
    return TokenApiReponse(
      requestId: int.parse(xml.findElements('rid').first.text),
      responderName: xml.findElements('resnm').first.text,
      geoLocation: xml.findElements('geo').first.text,
      nspId: xml.findElements('nspid').first.text,
      gpsSync: int.parse(xml.findElements('gpssync').first.text),
      locationChange: int.parse(xml.findElements('locchg').first.text),
      shiftDateLock: int.parse(xml.findElements('shfdtlock').first.text),
      shiftError: int.parse(xml.findElements('shfterr').first.text),
      endValue: int.parse(xml.findElements('edn').first.text),
      speed: int.parse(xml.findElements('spd').first.text),
      multiLeg: int.parse(xml.findElements('mltleg').first.text),
      uiConfig: xml.findElements('uiconfig').first.text,
      token: xml.findElements('token').first.text,
    );
  }
}
