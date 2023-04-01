import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:format_indonesia/format_indonesia.dart';
import 'package:intl/intl.dart';

import 'package:geocoding/geocoding.dart' as loc;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:location/location.dart';
import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:magentahrd/assets/colors.dart';
import 'package:magentahrd/models/user_location.dart';

import 'package:workmanager/workmanager.dart';
import 'package:magentahrd/pages/employee/track/detail.dart';
import 'package:magentahrd/pages/employee/track/checkin_history.dart';
import 'package:magentahrd/pages/employee/track/photo.dart';
import 'package:magentahrd/controler/checkin.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(42.747932, -71.167889);
const LatLng DEST_LOCATION = LatLng(37.335685, -122.0605916);

class TrackPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TrackPageState();
}

class TrackPageState extends State<TrackPage> with WidgetsBindingObserver {
  Completer<GoogleMapController> _controller = Completer();
  final controller = Get.put(CheckinController());
  Set<Marker> _markers = Set<Marker>();
  File image = File("");
  var imagePath = "";
  bool isTrack = false;
  bool isDetail = false;
  bool isLoading = false;
  var employeeId, name, address, photo;
  var latitude, longitude;
  List<int> text = [1];
  Timer? timer;

// for my drawn routes on the map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints? polylinePoints;
  var currentAddress;
  String googleAPIKey = 'AIzaSyCqSj9Uz6HDCskIWD0-vLYPB7g1lFQds40';

// for my custom marker pins
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;

// the user's initial location and current location
// as it moves
  LocationData? currentLocation;

// a reference to the destination location
  LocationData? destinationLocation;

// wrapper around the location API
  Location? location;
  double pinPillPosition = -100;
  UserLocation currentlySelectedPin = UserLocation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);
  UserLocation? sourcePinInfo;
  UserLocation? destinationPinInfo;
  StreamSubscription<LocationData>? locationSubscription;
  StreamSubscription<FGBGType>? subscription;

  // Location location = new Location();
  // LocationData? _locationData;
  //AppLifecycleState appLifecycleState = AppLifecycleState.detached;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");

        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
  }

  @override
  void initState() {
    getDataPref();
    controller.fetchCheckin();
    // initializeService();
    //didChangeAppLifecycleState(appLifecycleState);
    currentLocationChange();
    // timer = Timer.periodic(Duration(seconds: 5), (Timer t) => sendData());

    // FGBGEvents.stream.listen((event) {

    //     currentLocationChange();

    //    // FGBGType.foreground or FGBGType.background
    //   });

    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // create an instance of Location

    // location.onLocationChanged().l
    // set custom marker pinsF
    //  setSourceAndDestinationIcons();
    // set the initial location
    setInitialLocation();
  }

  void currentLocationChange() {
    locationSubscription?.cancel();
    location = new Location();
    polylinePoints = PolylinePoints();
    locationSubscription =
        location!.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      print('waktu ${cLoc}');

      GetAddressFromLatLong(double.parse(currentLocation!.latitude.toString()),
          double.parse(currentLocation!.longitude.toString()));
      //  sendData();

      updatePinOnMap();
    });
  }

  void setSourceAndDestinationIcons() async {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(1, 1)),
      'assets/pin-default.png',
    ).then((onValue) {
      sourceIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(1, 1)),
      'assets/pin-default.png',
    ).then((onValue) {
      destinationIcon = onValue;
    });
  }

  void setInitialLocation() async {
    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    currentLocation = await location!.getLocation();

    // hard-coded destination for this example
    destinationLocation = LocationData.fromMap({
      "latitude": DEST_LOCATION.latitude,
      "longitude": DEST_LOCATION.longitude
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition =
        CameraPosition(zoom: CAMERA_ZOOM, target: SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(double.parse(currentLocation!.latitude.toString()),
              double.parse(currentLocation!.longitude.toString())),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT);
      // bearing: CAMERA_BEARING);
    }

    return Scaffold(
      body: Container(
        width: Get.mediaQuery.size.width,
        height: Get.mediaQuery.size.height,
        child: Stack(
          children: <Widget>[
            GoogleMap(
                myLocationEnabled: true,
                compassEnabled: true,
                zoomControlsEnabled: false,
                tiltGesturesEnabled: false,
                // markers: _markers,
                markers: <Marker>{
                  Marker(
                    markerId: MarkerId("1"),
                    position: LatLng(
                        double.parse(
                            currentLocation?.latitude.toString() ?? "0"),
                        double.parse(
                            currentLocation?.longitude.toString() ?? "0")),
                  ),
                },
                polylines: _polylines,
                mapType: MapType.normal,
                initialCameraPosition: initialCameraPosition,
                onTap: (LatLng loc) {
                  pinPillPosition = -100;
                },
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  // my map has completed being created;
                  // i'm ready to show the pins on the map
                  showPinsOnMap();
                }),
            // MapPinPillComponent(
            //     pinPillPosition: pinPillPosition,
            //     currentlySelectedPin: currentlySelectedPin),

            //
            Container(
              margin: EdgeInsets.only(top: 40, right: 10),
              alignment: Alignment.topRight,
            ),
            Positioned(
                bottom: 1,
                child: Container(
                    width: Get.mediaQuery.size.width,
                    height: Get.mediaQuery.size.height / 2 + 100,
                    child: isDetail == false
                        ? _bottomSheet()
                        : _bottomSheetDetail()))
          ],
        ),
      ),
    );
  }

  void showPinsOnMap() {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition = LatLng(double.parse(currentLocation!.latitude.toString()),
        double.parse(currentLocation!.longitude.toString()));
    // get a LatLng out of the LocationData object
    var destPosition = LatLng(
        double.parse(destinationLocation!.latitude.toString()),
        double.parse(destinationLocation!.longitude.toString()));

    sourcePinInfo = UserLocation(
        locationName: "${currentAddress}",
        location: SOURCE_LOCATION,
        pinPath: "assets/pin-default.png",
        avatarPath: "assets/pin-default.png",
        labelColor: Colors.blueAccent);

    destinationPinInfo = UserLocation(
        locationName: "End Location",
        location: DEST_LOCATION,
        pinPath: "assets/pin-default.png",
        avatarPath: "assets/pin-default.png",
        labelColor: Colors.purple);

    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        onTap: () {
          setState(() {
            currentlySelectedPin = sourcePinInfo!;
            pinPillPosition = 0;
          });
        },
        icon: BitmapDescriptor.defaultMarker));
    // destination pin
    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        onTap: () {
          setState(() {
            currentlySelectedPin = destinationPinInfo!;
            pinPillPosition = 0;
          });
        },
        icon: BitmapDescriptor.defaultMarker));
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    //setPolylines();
  }

  void updatePinOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      // tilt: CAMERA_TILT,
      // bearing: CAMERA_BEARING,
      target: LatLng(double.parse(currentLocation!.latitude.toString()),
          double.parse(currentLocation!.longitude.toString())),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position
      var pinPosition = LatLng(
          double.parse(currentLocation!.latitude.toString()),
          double.parse(currentLocation!.longitude.toString()));

      sourcePinInfo!.location = pinPosition;

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          onTap: () {
            setState(() {
              currentlySelectedPin = sourcePinInfo!;
              pinPillPosition = 0;
            });
          },
          position: pinPosition, // updated position
          icon: BitmapDescriptor.defaultMarker));
    });
  }

  void getDataPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // print("employee_id${sharedPreferences.getInt("employee_id")}");
    setState(() {
      isTrack = sharedPreferences.getBool("isTrack") ?? false;
      employeeId = sharedPreferences.getString("employee_id") ?? "22";
    });

    await FirebaseFirestore.instance
        .collection('employee_locations')
        .where("employee_id", isEqualTo: employeeId ?? "22")
        .get()
        .then((value) {
      setState(() {
        name = value.docs[0]['name'];
        address = value.docs[0]['address'];
        photo = value.docs[0]['photo'];
      });
    });
  }

  void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      print("callbackDispatcher");
      //await sendData();
      return Future.value(true);
    });
  }

  Future<void> sendData() async {
    print("employee id ${employeeId}");
    // if (isTrack == true)  {
    await FirebaseFirestore.instance
        .collection('employee_locations')
        .doc(employeeId.toString())
        .update({
      "address": currentAddress,
      "latitude": currentLocation?.latitude.toString(),
      "longitude": currentLocation?.longitude.toString()
    }).then((result) {
      print("new USer true");
    }).catchError((onError) {
      print("onError ${onError}");
    });
    // } else {
    //   print("no tra");
    // }
  }

  Future<void> GetAddressFromLatLong(double latitude, double longitude) async {
    List<loc.Placemark> placemarks =
        await loc.placemarkFromCoordinates(latitude, longitude);
    print(placemarks);
    loc.Placemark place = placemarks[0];
    setState(() {
      currentAddress =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    });
  }

  void chooseImage() async {
    var checkinImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (checkinImage != null) {
      setState(() {
        image = File(checkinImage.path);
        imagePath = checkinImage.path;
        print(imagePath);
        controller.save(
            employeeId: employeeId,
            latitude: currentLocation?.latitude.toString(),
            longitude: currentLocation?.longitude.toString(),
            address: currentAddress,
            image: imagePath);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Stream<List<CheckinModel>> watchPurchases() async* {
  //   var date = DateFormat("yyyy-MM-dd").format(DateTime.now());
  //   var ohList = await CheckinRepository()
  //       .fetchChecinday(employeeId.toString(), date, date);
  //   yield ohList;
  // }

  // //bacground procees
  // Future<void> initializeService() async {
  //   print("servive start");
  //   final service = FlutterBackgroundService();
  //   await service.configure(
  //     androidConfiguration: AndroidConfiguration(
  //       // this will executed when app is in foreground or background in separated isolate
  //       onStart: onStart,

  //       // auto start service
  //       autoStart: true,
  //       isForegroundMode: true,
  //     ),
  //     iosConfiguration: IosConfiguration(
  //       // auto start service
  //       autoStart: true,

  //       // this will executed when app is in foreground in separated isolate
  //       onForeground: onStart,

  //       // you have to enable background fetch capability on xcode project
  //       onBackground: onIosBackground,
  //     ),
  //   );
  // }

// to ensure this executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
  void onIosBackground() {
    WidgetsFlutterBinding.ensureInitialized();
    print('FLUTTER BACKGROUND FETCH');
  }

//
  // void onStart() {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   final service = FlutterBackgroundService();
  //   service.onDataReceived.listen((event) {
  //     if (event!["action"] == "setAsForeground") {
  //       service.setForegroundMode(true);
  //       return;
  //     }

  //     if (event["action"] == "setAsBackground") {
  //       service.setForegroundMode(false);
  //     }

  //     if (event["action"] == "stopService") {
  //       service.stopBackgroundService();
  //     }
  //   });

  //   // bring to foreground
  //   service.setForegroundMode(true);

  //   Timer.periodic(Duration(seconds: 1), (timer) async {
  //     if (!(await service.isServiceRunning())) timer.cancel();
  //     service.setNotificationInfo(
  //       title: "My App Service",
  //       content: "Updated at ${DateTime.now()}",
  //     );
  //     sendData();

  //     service.sendData(
  //       {"current_date": DateTime.now().toIso8601String()},
  //     );
  //   });
  // }

  ///widget
  Widget _bottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 1,
      minChildSize: 0.5,
      snap: true,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          child: Column(
            children: [
              Container(
                width: Get.mediaQuery.size.width,
                height: 100,
                margin: EdgeInsets.only(right: 5),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        // if (isDetail == true) {
                        //   setState(() {
                        //     isDetail = false;
                        //   });
                        //   Navigator.pop(context);
                        //   _showModalButtonSheet();
                        // } else {
                        //   Navigator.pop(context);
                        // }
                      },
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, "back");
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 1,
                            child: Container(
                              margin: EdgeInsets.all(5),
                              child: Icon(Icons.arrow_back, color: blackColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: Get.mediaQuery.size.width,
                  height: Get.mediaQuery.size.height / 2,
                  child: Container(
                    decoration: new BoxDecoration(
                        color: Colors.white,
                        //new Color.fromRGBO(255, 0, 0, 0.0),
                        borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(20.0),
                            topRight: const Radius.circular(20.0))),
                    child: SingleChildScrollView(
                      child: Container(
                        width: Get.mediaQuery.size.width,
                        height: Get.mediaQuery.size.height / 2,
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Container(
                                  //
                                  //   decoration: BoxDecoration(
                                  //     color: whiteColor1,
                                  //     borderRadius: BorderRadius.circular(5),
                                  //   ),
                                  //   width: 60,
                                  //   height: 5,
                                  // ),
                                  //photo profile
                                  Container(
                                    margin:
                                        EdgeInsets.only(left: 20, right: 20),
                                    child: Row(
                                      children: <Widget>[
                                        photo == null
                                            ? Container(
                                                child: Image.asset(
                                                  "assets/profile-default.png",
                                                  width: 50,
                                                  height: 50,
                                                ),
                                              )
                                            : CircleAvatar(
                                                radius: 25,
                                                backgroundImage:
                                                    NetworkImage('')),
                                        Container(
                                          margin: EdgeInsets.only(left: 15),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "${name ?? ""}",
                                                style: TextStyle(
                                                    height: 1.4,
                                                    letterSpacing: 1,
                                                    fontSize: 15,
                                                    color: blackColor2,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: "roboto-bold"),
                                              ),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Container(
                                                width:
                                                    Get.mediaQuery.size.width /
                                                            2 -
                                                        20,
                                                child: RichText(
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  strutStyle: StrutStyle(
                                                      fontSize: 12.0),
                                                  text: TextSpan(
                                                      style: TextStyle(
                                                          height: 1.4,
                                                          letterSpacing: 1,
                                                          fontSize: 12,
                                                          color: blackColor4,
                                                          fontFamily:
                                                              "roboto-regular"),
                                                      text:
                                                          '${currentAddress}'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            width: double.maxFinite,
                                            child: ElevatedButton(
                                              onPressed: () => isLoading
                                                  ? null
                                                  : chooseImage(),
                                              child: isLoading
                                                  ? Center(
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  : Text(
                                                      "Checkin",
                                                    ),
                                              style: ElevatedButton.styleFrom(
                                                  primary: baseColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  )),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      color: blackColor5,
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.only(top: 40),
                                      child: Container(
                                          margin: EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Lokasi Saat ini",
                                                style: TextStyle(
                                                    color: blackColor2,
                                                    fontSize: 15,
                                                    letterSpacing: 0.5,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        "roboto-regular"),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text("${currentAddress}",
                                                  style: TextStyle(
                                                      color: blackColor1,
                                                      fontSize: 12,
                                                      letterSpacing: 0.5,
                                                      height: 1.4,
                                                      fontFamily:
                                                          "roboto-regular")),
                                            ],
                                          ))),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 30, left: 10, right: 10),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          child: Icon(
                                            Icons.history,
                                            color: blackColor2,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 5),
                                          child: Text("Checkin Hari Ini ",
                                              style: TextStyle(
                                                  letterSpacing: 1,
                                                  color: blackColor2,
                                                  fontFamily: "roboto-bold",
                                                  fontSize: 15)),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType
                                                          .rightToLeft,
                                                      child: CheckinHistoryPage(
                                                        employeeId: employeeId,
                                                      )));
                                            },
                                            child: Container(
                                              width: double.maxFinite,
                                              alignment: Alignment.centerRight,
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                "Tampilkan Semua ",
                                                style: TextStyle(
                                                    letterSpacing: 1,
                                                    color: baseColor2,
                                                    fontFamily: "roboto-medium",
                                                    fontSize: 13),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Obx(() {
                                    return controller.isLoading.value == true
                                        ? Container(
                                            child: CircularProgressIndicator(),
                                          )
                                        : Column(
                                            children: List.generate(
                                                controller.checkins.length,
                                                (index) {
                                              var data =
                                                  controller.checkins[index];
                                              var d = DateTime.parse(
                                                  data.dateTime.toString());

                                              var dateLocal = d.toLocal();
                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    Navigator.push(
                                                        context,
                                                        PageTransition(
                                                            type:
                                                                PageTransitionType
                                                                    .rightToLeft,
                                                            child: DetailPage(
                                                              image: data.image,
                                                              address:
                                                                  data.address,
                                                              latitude:
                                                                  data.latitude,
                                                              longitude: data
                                                                  .longitude,
                                                              datetime:
                                                                  data.dateTime,
                                                            )));
                                                    isDetail = true;
                                                  });
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      left: 15, right: 15),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: <Widget>[
                                                          Container(
                                                            width: 15,
                                                            height: 15,
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    baseColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 10),
                                                            child: Text(
                                                              "${Waktu(DateTime.parse(data.dateTime.toString())).yMMMMEEEEd()} ",
                                                              style: TextStyle(
                                                                  color:
                                                                      blackColor2,
                                                                  fontSize: 13,
                                                                  letterSpacing:
                                                                      0.5,
                                                                  height: 1.4,
                                                                  fontFamily:
                                                                      "roboto-regular"),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              width: double
                                                                  .maxFinite,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 10),
                                                              child: Text(
                                                                "${DateFormat("HH:mm:ss").format(dateLocal)}",
                                                                style: TextStyle(
                                                                    color:
                                                                        baseColor,
                                                                    fontSize:
                                                                        13,
                                                                    letterSpacing:
                                                                        0.5,
                                                                    height: 1.4,
                                                                    fontFamily:
                                                                        "roboto-regular"),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Container(
                                                        child: Row(
                                                          children: <Widget>[
                                                            Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 5),
                                                              height: 90,
                                                              color: baseColor3,
                                                              width: 5,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            10),
                                                                width: double
                                                                    .maxFinite,
                                                                child: Text(
                                                                  "${data.address}",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      letterSpacing:
                                                                          0.5,
                                                                      height:
                                                                          1.4,
                                                                      color:
                                                                          blackColor4),
                                                                ),
                                                              ),
                                                            ),
                                                            Hero(
                                                                tag: "avatar-1",
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Get.to(
                                                                        PhotoPage(
                                                                      image: data
                                                                          .image,
                                                                    ));
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 50,
                                                                    height: 50,
                                                                    color: Colors
                                                                        .blue,
                                                                    child: PhotoView(
                                                                        imageProvider:
                                                                            NetworkImage(data.image)),
                                                                  ),
                                                                ))
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                          );
                                  })
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomSheetDetail() {
    return DraggableScrollableSheet(
      builder: (BuildContext context, ScrollController scrollController) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: Get.mediaQuery.size.width,
                height: 100,
                margin: EdgeInsets.only(right: 5),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        isDetail = false;
                        // if (isDetail == true) {
                        //   setState(() {
                        //     isDetail = false;
                        //   });
                        //   Navigator.pop(context);
                        //   _showModalButtonSheet();
                        // } else {
                        //   Navigator.pop(context);
                        // }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.only(left: 20, right: 20),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 1,
                          child: Container(
                            color: Colors.white,
                            margin: EdgeInsets.all(5),
                            child: Icon(Icons.arrow_back, color: blackColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: Get.mediaQuery.size.width,
                height: Get.mediaQuery.size.height / 2,
                child: Container(
                  decoration: new BoxDecoration(
                      color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(20.0),
                          topRight: const Radius.circular(20.0))),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(left: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Detail Checkin",
                                          style: TextStyle(
                                              height: 1.4,
                                              letterSpacing: 1,
                                              fontSize: 15,
                                              color: blackColor2,
                                              fontFamily: "roboto-regular"),
                                        ),
                                        SizedBox(
                                          height: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                    margin: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Icon(
                                                Icons.location_on,
                                                color: baseColor,
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                "Lokasi",
                                                style: TextStyle(
                                                    color: blackColor2,
                                                    fontSize: 15,
                                                    letterSpacing: 1,
                                                    fontFamily:
                                                        "roboto-regular"),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                            "I No. 2, Margahayu Raya, Jl. Saturnus Ujung, Manjahlega, Rancasari, Bandung City, West Java 40286",
                                            style: TextStyle(
                                                color: blackColor1,
                                                fontSize: 13,
                                                letterSpacing: 1,
                                                fontFamily: "roboto-regular")),
                                      ],
                                    ))),
                            Container(
                              margin:
                                  EdgeInsets.only(top: 5, left: 20, right: 20),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    child: Icon(
                                      Icons.history,
                                      color: baseColor,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text("Waktu",
                                        style: TextStyle(
                                            letterSpacing: 1,
                                            color: blackColor2,
                                            fontFamily: "roboto-regular",
                                            fontSize: 15)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Text("",
                                  style: TextStyle(
                                      letterSpacing: 1,
                                      color: blackColor2,
                                      fontFamily: "roboto-regular",
                                      fontSize: 15)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // void showModalBottomSheet() {
  //   showMaterialModalBottomSheet(
  //       context: context,
  //       builder: (context) => SingleChildScrollView(
  //             controller: ModalScrollController.of(context),
  //             child: Container(
  //               height: Get.mediaQuery.size.height / 2,
  //               child: Text("22"),
  //             ),
  //           ));
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    ///WidgetsBinding.instance!.removeObserver(this);
    timer!.cancel();
    // if (isTrack==false){
    //
    // }

    super.dispose();
  }
}

// class BackGroundWork {
//   BackGroundWork._privateConstructor();
//
//   static final BackGroundWork _instance =
//   BackGroundWork._privateConstructor();
//
//   static BackGroundWork get instance => _instance;
//``
//   _loadCounterValue(int value) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('BackGroundCounterValue', value);
//   }
//
//   Future<int> _getBackGroundCounterValue() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     //Return bool
//     int counterValue = prefs.getInt('BackGroundCounterValue') ?? 0;
//     return counterValue;
//   }
// }