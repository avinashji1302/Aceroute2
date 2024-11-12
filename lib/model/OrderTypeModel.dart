/*
class OrderTypeModel {
  final String id;
  final String name;
  final String abbreviation;
  final int duration;
  final int capacity;
  final int parentId;
  final int customTimeSlot;
  final String elapseTimeSlot;
  final double value;
  final String externalId;
  final String updateTimestamp;
  final String updatedBy;

  OrderTypeModel({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.duration,
    required this.capacity,
    required this.parentId,
    required this.customTimeSlot,
    required this.elapseTimeSlot,
    required this.value,
    required this.externalId,
    required this.updateTimestamp,
    required this.updatedBy,
  });

  // Convert a map to an OrderTypeModel
  factory OrderTypeModel.fromMap(Map<String, dynamic> map) {
    return OrderTypeModel(
      id: map['id'],
      name: map['nm'],
      abbreviation: map['abr'],
      duration: int.parse(map['dur']),
      capacity: int.parse(map['cap']),
      parentId: int.parse(map['pid']),
      customTimeSlot: int.parse(map['ctmslot']),
      elapseTimeSlot: map['eltmslot'],
      value: double.parse(map['val']),
      externalId: map['xid'] ?? '',
      updateTimestamp: map['upd'],
      updatedBy: map['by'],
    );
  }

  // Convert the OrderTypeModel to a map for inserting into the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nm': name,
      'abr': abbreviation,
      'dur': duration,
      'cap': capacity,
      'pid': parentId,
      'ctmslot': customTimeSlot,
      'eltmslot': elapseTimeSlot,
      'val': value,
      'xid': externalId,
      'upd': updateTimestamp,
      'by': updatedBy,
    };
  }
}
*/
class OrderTypeModel {
  final String id;
  final String name;
  final String abbreviation;
  final int duration;
  final int capacity;
  final int parentId;
  final int customTimeSlot;
  final String elapseTimeSlot;
  final double value;
  final String externalId;
  final String updateTimestamp;
  final String updatedBy;

  OrderTypeModel({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.duration,
    required this.capacity,
    required this.parentId,
    required this.customTimeSlot,
    required this.elapseTimeSlot,
    required this.value,
    required this.externalId,
    required this.updateTimestamp,
    required this.updatedBy,
  });

  // Convert a map to an OrderTypeModel instance (used for JSON or database maps)
  factory OrderTypeModel.fromMap(Map<String, dynamic> map) {
    return OrderTypeModel(
      id: map['id'],
      name: map['name'],
      abbreviation: map['abbreviation'],
      duration: map['duration'],
      capacity: map['capacity'],
      parentId: map['parentId'],
      customTimeSlot: map['customTimeSlot'],
      elapseTimeSlot: map['elapseTimeSlot'],
      value: map['value'],
      externalId: map['externalId'] ?? '',
      updateTimestamp: map['updateTimestamp'],
      updatedBy: map['updatedBy'],
    );
  }

  // Convert the OrderTypeModel instance to a map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nm': name,
      'abr': abbreviation,
      'dur': duration,
      'cap': capacity,
      'pid': parentId,
      'ctmslot': customTimeSlot,
      'eltmslot': elapseTimeSlot,
      'val': value,
      'xid': externalId,
      'upd': updateTimestamp,
      'by': updatedBy,
    };
  }
}


