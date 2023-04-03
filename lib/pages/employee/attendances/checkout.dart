import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';
import 'package:js/js.dart';
// import 'package:location/location.dart';
import 'package:magentahrd/pages/employee/attendances/map.dart';
import 'package:magentahrd/pages/employee/location/utalities/helper.dart';
import 'package:magentahrd/services/api_clien.dart';
import 'package:magentahrd/utalities/alert_dialog.dart';
import 'package:magentahrd/utalities/color.dart';
import 'package:magentahrd/utalities/fonts.dart';
import 'package:magentahrd/vaidasi/validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocode/geocode.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  ///variable
  File? _image;
  Map? _employee;
  bool _isLoading = true;
  bool _loading_image = true;
  bool _disposed = false;
  var distance = 20;

  Uint8List webImage = Uint8List(10);
  File _file = File("0");
  final Geolocator geolocator = Geolocator();
  // final Geolocator geolocator = Geolocator();
  Position? _currentPosition;
  String? _currentAddress;
  GeoCode geoCode = GeoCode();
  // Location location = new Location();
  // LocationData? _locationData;
  var Cremark = new TextEditingController();
  var time,
      _latitude = "0.0",
      _longitude = "0.0",
      _employee_id,
      _check_in,
      _category_absent,
      _firts_name,
      _last_name,
      _profile_background,
      _gender,
      _departement_name,
      _lat_mainoffice,
      _long_mainoffice,
      _is_long_shift_available,
      _long_shift_working_pattern_id;
  String? base64;
  Validasi validator = new Validasi();
  double _distance = 0.0;
  bool _is_long_shift = false;
  Timer? _timer;

  ///main context
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black87, //modify arrow color from here..
        ),
        backgroundColor: Colors.white,
        title: new Text(
          "Checkout",
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: _isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height + 50,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: _distance > distance
                            ? _builddistaceCompany()
                            : Text(""),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        child: _image == null
                            ? _buildPhoto(context)
                            : InkWell(
                                onTap: () {
                                  aksesCamera();
                                },
                                child: new Image.file(_image!,
                                    width: 200, height: 200, fit: BoxFit.fill),
                              ),
                        // child: _file.path == "0"
                        //     ? _buildPhoto(context)
                        //     : InkWell(
                        //         onTap: () {
                        //           // print("tees");
                        //           // aksesCamera();
                        //           //_onAddPhotoClicked(context);
                        //         },
                        //         child: Container(
                        //             width: 200,
                        //             height: 200,
                        //             child: Image.memory(webImage))),
                      ),
                      _buildText(),
                      SizedBox(
                        height: 15,
                      ),
                      // _buildCategoryabsence(),
                      // SizedBox(
                      //   height: 15,
                      // ),
                      _buildLocation(),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: _is_long_shift_available == true
                            ? _buildSwitchLongShift()
                            : Container(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _buildremark(),
                      SizedBox(
                        height: 10,
                      ),
                      _buildtime(),
                      // Expanded(
                      //   child: Container(
                      //     margin: EdgeInsets.only(bottom: 10),
                      //     width: double.infinity,
                      //     height: MediaQuery.of(context).size.height,
                      //     child: Column(
                      //       mainAxisAlignment: MainAxisAlignment.end,
                      //       children: <Widget>[
                      //         _buildfingerprint(),
                      //       ],
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: _isLoading == true
          ? Center(
              child: Text(""),
            )
          : SizedBox(
              width: 70,
              height: 70,
              child: FittedBox(
                child: FloatingActionButton(
                  onPressed: () {
                    upload();
                  },
                  backgroundColor: btnColor1,
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.check,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  ///widge widget
  //Widger photo default
  Widget _buildPhoto(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {
          aksesCamera();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 2,
              color: Colors.black26,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          margin: EdgeInsets.only(top: 15),
          child: SvgPicture.asset(
            "assets/downloadImage.svg",
            width: 75,
            height: 75,
            color: Colors.black45,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  // -------end photo default-----
  //Widget text
  Widget _buildText() {
    return Container(
      child: Container(
        margin: EdgeInsets.all(15.0),
        child: Text(
          "Take Your Photo",
          style: TextStyle(fontSize: 30, color: Colors.black38),
        ),
      ),
    );
  }

  //build remark
  Widget _buildremark() {
    return Container(
      margin: EdgeInsets.only(left: 25, right: 20),
      child: TextFormField(
        controller: Cremark,
        // cursorColor: Theme.of(context).cursorColor,
        maxLength: 100,
        decoration: const InputDecoration(
          icon: Icon(
            Icons.lock,
            color: Colors.black12,
          ),
          labelText: 'Catatan',
          labelStyle: TextStyle(
            color: Colors.black38,
          ),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: Colors.black38,
          )),
        ),
      ),
    );
  }

  Widget _buildSwitchLongShift() {
    return Container(
        margin: EdgeInsets.only(left: 25),
        child: Row(
          children: [
            Switch(
              // This bool value toggles the switch.
              value: _is_long_shift,
              activeColor: btnColor1,
              onChanged: (bool value) {
                // This is called when the user toggles the switch.
                setState(() {
                  _is_long_shift = value;
                });
              },
            ),
            Container(
              child: Text("Long Shift"),
            ),
          ],
        ));
  }

  void _startJam() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _getCurrentLocation();
      _getDistance(_lat_mainoffice, _long_mainoffice, _latitude, _longitude);
    });
  }

  void requestPermission() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
  }

  Widget _buildtime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 20,
          margin: EdgeInsets.only(left: 25),
          child: TextFormField(
            enabled: false,
            // cursorColor: Theme.of(context).cursorColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              icon: const Icon(
                Icons.timer,
                color: Colors.black12,
                size: 30,
              ),
              labelText: '$time',
              labelStyle: TextStyle(
                color: Colors.black38,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryabsence() {
    return Container(
      margin: EdgeInsets.only(left: 25, right: 25),
      width: double.maxFinite,
      padding: const EdgeInsets.all(0.0),
      child: Row(
        children: [
          Container(
            child: Icon(
              Icons.merge_type,
              color: Colors.black12,
              size: 30,
            ),
          ),
          Expanded(
            child: Container(
              width: double.maxFinite,
              margin: EdgeInsets.only(left: 10),
              child: DropdownButton<String>(
                isExpanded: true,

                value: _category_absent,
                //elevation: 5,
                style: TextStyle(color: Colors.black),

                items: <String>[
                  'Present',
                  'Sick',
                  'Permission',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                hint: Text(
                  "Present",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                onChanged: (String? value) {
                  // setState(() {
                  //   _category_absent = value;
                  // });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    return Container(
      margin: EdgeInsets.only(left: 25),
      //Row for time n location
      child: Row(
        children: <Widget>[
          //container  icon location
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.black12,
                    size: 30,
                  ),
                ),
                //container for name location
                InkWell(
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => Maps(
                    //               address: _currentAddress,
                    //               longitude: _longitude,
                    //               latitude: _latitude,
                    //               firts_name: _firts_name,
                    //               last_name: _last_name,
                    //               profile_background: _profile_background,
                    //               gender: _gender,
                    //               departement_name: _departement_name,
                    //               distance: _distance,
                    //               latmainoffice: _lat_mainoffice,
                    //               longMainoffice: _long_mainoffice,
                    //             )));
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Lokasi", style: subtitleMainMenu),
                        SizedBox(
                          height: 10,
                        ),
                        // if (_currentPosition != null && _currentAddress != null)
                        Container(
                          width: Get.mediaQuery.size.width / 2 + 50,
                          child: Text(
                            "$_currentAddress",
                            style: TextStyle(color: Colors.black38),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  //Widger photo
  Widget _buildfingerprint() {
    return InkWell(
      onTap: () {
        upload();
      },
      child: Container(
        width: 70,
        height: 70,
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Container(
            margin: EdgeInsets.all(15.0),
            child: Image.asset(
              "assets/fingerprint.png",
            ),
          ),
        ),
      ),
    );
  }

  Future upload() async {
    var date = DateFormat("yyyy:MM:dd").format(DateTime.now());
    if (_category_absent == null) {
      _category_absent = "Present";
    }

    if (_category_absent.toString().toLowerCase() != 'present') {
      if (base64.toString() == "null") {
        Toast.show("Foto wajib digunakan", context,
            duration: 5, gravity: Toast.BOTTOM);
      } else if (Cremark.text.toString().isEmpty) {
        Toast.show("Remarks tidak boleh kosong", context,
            duration: 5, gravity: Toast.BOTTOM);
      } else {
        Toast.show("$_category_absent", context);
        validation_checkout(
            context,
            base64.toString(),
            Cremark.text,
            _latitude.toString().trim(),
            _longitude.toString().trim(),
            _employee_id,
            date,
            time,
            _departement_name,
            _distance,
            _lat_mainoffice,
            _long_mainoffice,
            _long_shift_working_pattern_id,
            _is_long_shift,
            _category_absent.toString().toLowerCase());
      }
    } else {
      if (_distance > distance) {
        if (_image == null || _image == "" || _image == "null") {
          Toast.show("Ambil fotomu terlebih dahulu", context,
              duration: 5, gravity: Toast.BOTTOM);
        } else {
          validation_checkout(
              context,
              base64.toString(),
              Cremark.text,
              _latitude.toString().trim(),
              _longitude.toString().trim(),
              _employee_id,
              date,
              time,
              _departement_name,
              _distance,
              _lat_mainoffice,
              _long_mainoffice,
              _long_shift_working_pattern_id,
              _is_long_shift,
              _category_absent.toString().toLowerCase());
        }
      } else {
        validation_checkout(
            context,
            base64.toString(),
            Cremark.text,
            _latitude.toString().trim(),
            _longitude.toString().trim(),
            _employee_id,
            date,
            time,
            _departement_name,
            _distance,
            _lat_mainoffice,
            _long_mainoffice,
            _long_shift_working_pattern_id,
            _is_long_shift,
            _category_absent.toString().toLowerCase());
      }
    }
  }

  aksesCamera() async {
    final ImagePicker _picker = ImagePicker();
    var image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      var f = await image.readAsBytes();
      setState(() {
        _image = File(image.path);
        base64 = base64Encode(f);
      });
    } else {
      toast_success("No file selected");
    }
  }

  Widget _builddistaceCompany() {
    return Container(
      color: Colors.amber.withOpacity(0.4),
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 10, right: 20, top: 5, bottom: 5),
            child: Icon(
              Icons.info,
              color: Colors.black45,
            ),
          ),
          Container(
              child: Text(
            "Anda  berada di luar area kantor",
            style: subtitleMainMenu,
          ))
        ],
      ),
    );
  }

  //get curret locatin lat dan long
  _getCurrentLocation() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;

        _latitude = _currentPosition!.latitude.toString();
        _longitude = _currentPosition!.longitude.toString();
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  //convert lat dan long to address
  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  _getDataPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _employee_id = sharedPreferences.getString("user_id");

      dataEmployee(_employee_id.toString());
    });
  }

  /**/
  // _getDistance(latMainoffice, longMainoffice, currentlat, currentlong) async {
  //   try {
  //     _distance = 0;
  //     final double d = await Geolocator().distanceBetween(
  //         double.parse(latMainoffice),
  //         double.parse(longMainoffice),
  //         currentlat,
  //         currentlong);
  //     setState(() {
  //       _distance = d;
  //       print("$d");
  //       // print(d);
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  _getDistance(latMainoffice, longMainoffice, currentlat, currentlong) async {
    try {
      _distance = 0;
      final double d = await Geolocator.distanceBetween(
        double.parse(latMainoffice),
        double.parse(longMainoffice),
        double.parse(currentlat),
        double.parse(currentlong),
      );
      setState(() {
        _distance = d;
        print("$d");
        // print(d);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
    // Timer.periodic(new Duration(seconds: 1), (_) {});

    _startJam();
    _getDataPref();
    _getCurrentLocation();
    // _getAddressFromLatLng();
  }

  Future dataEmployee(var id) async {
    try {
      setState(() {
        _isLoading = true;
      });
      http.Response response =
          await http.get(Uri.parse("$base_url/api/employees/$id"));
      _employee = jsonDecode(response.body);

      setState(() {
        _departement_name = "";

        _gender = _employee!['data']['gender'];
        _last_name = "";
        _profile_background = _employee!['data']['photo'];
        _firts_name = _employee!['data']['name'];
        _lat_mainoffice = _employee!['data']['office']['latitude'];
        _long_mainoffice = _employee!['data']['office']['longitude'];
        _is_long_shift_available =
            _employee!['data']['is_long_shift_available'];
        _long_shift_working_pattern_id =
            _employee!['data']['long_shift_working_pattern_id'];
        _getCurrentLocation();
        _getDistance(_lat_mainoffice, _long_mainoffice, _latitude, _longitude);

        _isLoading = false;
      });

      setState(() {
        // _getCurrentLocation();
        // _getAddressFromLatLng();
        // _getDistance(_lat_mainoffice, _long_mainoffice, _latitude, _longitude);
      });
    } catch (e) {}
  }
}
