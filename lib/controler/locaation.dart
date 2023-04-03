import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocode/geocode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

class LocaationController extends GetxController {
  var addres = "".obs;
  var latitude = "".obs;
  var longitude = "".obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future getDatapref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    empoyeeId.value = sharedPreferences.getString("employee_id")!;
  }

  final Geolocator geolocator = Geolocator();
  Position? _currentPosition;
  var _currentAddress = "".obs;
  var empoyeeId = "".obs;
  getCurrentLocation() {
    getDatapref();
     Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      _currentPosition = position;
      latitude.value = _currentPosition!.latitude.toString();
      longitude.value = _currentPosition!.longitude.toString();
      getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  //convert lat dan long to address
  getAddressFromLatLng() async {
   

    try {
      List<Placemark> p = await placemarkFromCoordinates(
          double.parse(_currentPosition!.latitude.toString()), double.parse(_currentPosition!.longitude.toString()));
      Placemark place = p[0];
   
       addres.value =
            "${place.street} ${place.name}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}";
       
       
    } catch (e) {
      print(e);
    }
  }
}
