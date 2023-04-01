import 'dart:io';

import 'package:magentahrd/blocs/checkin_submission.dart';

class CheckinState {
  final String image;
  final String latitude;
  final String longitude;
  final String dateTime;
  final String employeeId;
  final String address;
  final CheckinSubmissionStatus formStatus;

  CheckinState(
      {this.image = '',
      this.latitude = '',
      this.longitude = '',
      this.dateTime = '',
      this.employeeId = '',
      this.address = '',
      this.formStatus = const InitialCheckinStatus()});

  CheckinState copyWith(
      {var image,
      var latitude,
      var longitude,
    var  dateTime,
      var  employeeId,
      var address,
      CheckinSubmissionStatus? formStatus}) {
    return CheckinState(
        image: image ?? this.image,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        dateTime: dateTime ?? this.dateTime,
        employeeId: employeeId ?? this.employeeId,
        address: address ?? this.address,
        formStatus: formStatus ?? this.formStatus);
  }
}
