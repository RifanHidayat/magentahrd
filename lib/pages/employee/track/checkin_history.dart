import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:magentahrd/controler/checkin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:magentahrd/assets/colors.dart';
import 'package:magentahrd/models/checkin.dart';
import 'package:magentahrd/pages/employee/track/detail.dart';
import 'package:magentahrd/pages/employee/track/photo.dart';
import 'package:magentahrd/repositories/checkin.dart';

class CheckinHistoryPage extends StatefulWidget {
  var employeeId;

  CheckinHistoryPage({this.employeeId});

  @override
  _CheckinHistoryPageState createState() => _CheckinHistoryPageState();
}

class _CheckinHistoryPageState extends State<CheckinHistoryPage> {
  var isTrack = false, name, employeeId;

  final controller = Get.put(CheckinController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: baseColor2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Riwayat Checkin",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "roboto-regular",
              fontSize: 18,
              letterSpacing: 0.5),
        ),
      ),
      body: Container(
        width: Get.mediaQuery.size.width,
        height: Get.mediaQuery.size.height,
        child:   SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 20),
            child: Container(
              child: Column(
                children:
                    List.generate(controller.checkins.length, (index) {
                  var data = controller.checkins[index];

                  var d = DateTime.parse(data.dateTime.toString());

                  var dateLocal = d.toLocal();

                  return InkWell(
                    onTap: () {
                      setState(() {
                        // isDetail = true;
                        Get.to(DetailPage(
                          image: data.image,
                          address: data.address,
                          latitude: data.latitude,
                          longitude: data.longitude,
                          datetime: data.dateTime,
                        ));
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 15, right: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                    color: baseColor,
                                    borderRadius:
                                        BorderRadius.circular(20)),
                              ),
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.centerRight,
                                      margin: EdgeInsets.only(left: 5),
                                      height: 130,
                                      color: baseColor3,
                                      width: 5,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),

                          //history checkin
                          Expanded(
                            child: Container(
                              width: double.maxFinite,
                              height: 120,
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Container(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.start,
                                    children: <Widget>[
                                      Hero(
                                          tag: "avatar-1",
                                          child: InkWell(
                                            onTap: () {
                                              Get.to(PhotoPage(
                                                image: data.image,
                                              ));
                                            },
                                            child: Container(
                                              width: 100,
                                              height: 120,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.only(
                                                        bottomLeft: Radius
                                                            .circular(5),
                                                        topLeft:
                                                            Radius.circular(
                                                                5)),
                                                child: Image.network(
                                                  "/${data.image}",
                                                  fit: BoxFit.fill,
                                                  width: 100,
                                                  height: 100,
                                                ),
                                              ),
                                            ),
                                          )),
                                      SizedBox(width: 10),
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    child: Text(
                                                      "${DateFormat("yyyy-mm-dd").format(DateTime.parse(data.dateTime.toString()))}",
                                                      style: TextStyle(
                                                          color:
                                                              blackColor2,
                                                          letterSpacing:
                                                              0.5,
                                                          fontSize: 12,
                                                          fontFamily:
                                                              "roboto-regular"),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: Get.mediaQuery
                                                            .size.width *
                                                        0.3,
                                                    alignment: Alignment
                                                        .centerRight,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .end,
                                                      children: <Widget>[
                                                        Container(
                                                          child: Icon(
                                                            Icons.history,
                                                            color:
                                                                baseColor,
                                                            size: 18,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Container(
                                                          child: Text(
                                                            "${DateFormat("HH:mm:ss").format(dateLocal)}",
                                                            style: TextStyle(
                                                                color:
                                                                    baseColor2,
                                                                letterSpacing:
                                                                    0.5,
                                                                fontSize:
                                                                    12,
                                                                fontFamily:
                                                                    "roboto-regular"),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: Get.mediaQuery.size
                                                        .height *
                                                    0.25,
                                                child: Text(
                                                  "${data.address} ",
                                                  style: TextStyle(
                                                      color: blackColor2,
                                                      letterSpacing: 0.5,
                                                      fontSize: 10,
                                                      fontFamily:
                                                          "roboto-regular"),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Stream<List<CheckinModel>> watchPurchases() async* {
    var ohList =
        await CheckinRepository().fetchChecin(widget.employeeId.toString());
    yield ohList;
  }

  void getDataPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // print("employee_id${sharedPreferences.getInt("employee_id")}");
    setState(() {
      isTrack = sharedPreferences.getBool("isTrack") ?? false;
      employeeId = sharedPreferences.getInt("employee_id");
      name = sharedPreferences.getString("name");
    });
  }
}
