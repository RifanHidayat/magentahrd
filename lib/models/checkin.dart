import 'dart:convert';

class CheckinModel {
  var id;
  var employeeId;
  var dateTime;
  var latitude;
  var longitude;
  var address;
  var image;

  CheckinModel(
      {this.id,
      this.employeeId,
      this.dateTime,
      this.latitude,
      this.longitude,
      this.image,
      this.address});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'datetime': dateTime,
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
      "image": image
    };
  }

  factory CheckinModel.fromJson(Map<String, dynamic> map) {
    return CheckinModel(
        id: map["id"] ?? 0,
        employeeId: map["emmployee_id"] ?? 0,
        latitude: map['latitude'],
        longitude: map['longitude'],
        address: map['address'],
        image: map['image'],
        dateTime: map['datetime'] ?? "");
  }

  static List<CheckinModel> fromJsonToList(List data) {
    return List<CheckinModel>.from(data.map(
      (item) => CheckinModel.fromJson(item),
    ));
  }

  static String toJson(CheckinModel data) {
    final mapData = data.toMap();
    return json.encode(mapData);
  }
}
