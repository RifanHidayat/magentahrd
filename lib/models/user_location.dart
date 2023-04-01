import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocation {
  var pinPath;
  var avatarPath;
  var location;
  var locationName;
  var labelColor;

  UserLocation(
      {this.pinPath,
      this.avatarPath,
      this.location,
      this.locationName,
      this.labelColor});
}
