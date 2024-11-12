import 'package:xml/xml.dart' as xml;

class GTypeModel {
  final int id;
  final String name;
  final int typeId;
  final int capacity;
  final String detail;
  final String externalId;
  final String updateTimestamp;
  final String updatedBy;

  GTypeModel({
    required this.id,
    required this.name,
    required this.typeId,
    required this.capacity,
    required this.detail,
    required this.externalId,
    required this.updateTimestamp,
    required this.updatedBy,
  });

  // Method to convert model data to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'typeId': typeId,
      'capacity': capacity,
      'detail': detail,
      'externalId': externalId,
      'updateTimestamp': updateTimestamp,
      'updatedBy': updatedBy,
    };
  }

  // Method to create a GTypeModel from XML data
  factory GTypeModel.fromXml(xml.XmlElement element) {
    return GTypeModel(
      id: int.parse(element.findElements('id').single.text),
      name: element.findElements('nm').single.text,
      typeId: int.parse(element.findElements('tid').single.text),
      capacity: int.tryParse(element.findElements('cap').single.text) ?? 0,
      detail: element.findElements('dtl').single.text,
      externalId: element.findElements('xid').isNotEmpty ? element.findElements('xid').single.text : '',
      updateTimestamp: element.findElements('upd').single.text,
      updatedBy: element.findElements('by').single.text,
    );
  }

  // Method to create a GTypeModel from JSON data
  factory GTypeModel.fromJson(Map<String, dynamic> json) {
    return GTypeModel(
      id: int.tryParse(json['id']) ?? 0,  // Convert to int or default to 0
      name: json['name'] ?? '',  // Ensure it's not null
      typeId: int.tryParse(json['typeId']) ?? 0,  // Convert to int or default to 0
      capacity: int.tryParse(json['capacity']) ?? 0,  // Convert to int or default to 0
      detail: json['detail'] ?? '',  // Ensure it's not null
      externalId: json['externalId'] ?? '',  // Ensure it's not null
      updateTimestamp: json['updateTimestamp'] ?? '',  // Ensure it's not null
      updatedBy: json['updatedBy'] ?? '',  // Ensure it's not null
    );
  }


  // Method to convert model data to JSON (for potential future use)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'typeId': typeId,
      'capacity': capacity,
      'detail': detail,
      'externalId': externalId,
      'updateTimestamp': updateTimestamp,
      'updatedBy': updatedBy,
    };
  }
}



/*class GTypeModel {
  final int id;
  final String name;
  final int typeId;
  final int capacity;
  final String detail;
  final String externalId;
  final String updateTimestamp;
  final String updatedBy;

  GTypeModel({
    required this.id,
    required this.name,
    required this.typeId,
    required this.capacity,
    required this.detail,
    required this.externalId,
    required this.updateTimestamp,
    required this.updatedBy,
  });

  // Method to convert model data to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'typeId': typeId,
      'capacity': capacity,
      'detail': detail,
      'externalId': externalId,
      'updateTimestamp': updateTimestamp,
      'updatedBy': updatedBy,
    };
  }

  // Method to create a GTypeModel from XML data
  factory GTypeModel.fromXml(xml.XmlElement element) {
    return GTypeModel(
      id: int.parse(element.findElements('id').single.text),
      name: element.findElements('nm').single.text,
      typeId: int.parse(element.findElements('tid').single.text),
      capacity: int.tryParse(element.findElements('cap').single.text) ?? 0,
      detail: element.findElements('dtl').single.text,
      externalId: element.findElements('xid').isNotEmpty ? element.findElements('xid').single.text : '',
      updateTimestamp: element.findElements('upd').single.text,
      updatedBy: element.findElements('by').single.text,
    );
  }
}*/
