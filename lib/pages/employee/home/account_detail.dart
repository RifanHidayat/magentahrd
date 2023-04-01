import 'package:magentahrd/assets/colors.dart';

import 'package:magentahrd/pages/splash/splash.dart';

// import 'package:maagentahrd/repositories/employee.dart';
// import 'package:magentahrd/session/session.dart';
import 'package:magentahrd/models/employee_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountDetailPage extends StatefulWidget {
  var employeeId;
  AccountDetailPage({this.employeeId});
  @override
  _AccountDetailPageState createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  static const List<String> moremenu = <String>["logout"];
  var isTrack = false, name, employeeId, photo, gpsStatus = false;
  var email;
  var isLoading = true;
  // Session session = new Session();
EmployeeModel? employeeModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("id ${employeeId.toString()}");
    getDataPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Akun",style: TextStyle(color: blackColor2),),
      //   backgroundColor: Colors.white,
      //   // actions: <Widget>[
      //   //   PopupMenuButton<String>(
      //   //     icon: Icon(Icons.more_vert,color: blackColor2,),
      //   //     onSelected: choiceAction,
      //   //
      //   //     itemBuilder: (BuildContext context) {
      //   //       return moremenu.map((String choice) {
      //   //         return PopupMenuItem<String>(
      //   //           value: choice,
      //   //           child: Text(choice),
      //   //         );
      //   //       }).toList();
      //   //     },
      //   //   )
      //   // ],
      // ),
      body: SingleChildScrollView(
          child: isLoading == true
              ? Container(
            width: Get.mediaQuery.size.width,
            height: Get.mediaQuery.size.width,
            child: Center(
              child: CircularProgressIndicator(
                color: baseColor,
              ),
            ),
          )
              : Container(
            width: Get.mediaQuery.size.width,
            height: Get.mediaQuery.size.height,
            child: Stack(
              children: [
                _header(),

                Positioned(
                  top: Get.mediaQuery.size.height * 0.30,
                  child: Container(
                    margin: EdgeInsets.only(top: 45, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "Nama",
                                  style: TextStyle(
                                      color: blackColor2,
                                      fontSize: 13,
                                      fontFamily: "Roboto-medium",
                                      letterSpacing: 0.5),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  "${employeeModel!.name}",
                                  style: TextStyle(
                                      color: blackColor4,
                                      fontSize: 10,
                                      fontFamily: "Roboto-medium",
                                      letterSpacing: 0.5),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                  width: Get.mediaQuery.size.width - 40,
                                  child: Divider(
                                    color: Colors.black.withOpacity(0.1),
                                    height: 1,
                                  )),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "No. Hp",
                                  style: TextStyle(
                                      color: blackColor2,
                                      fontSize: 13,
                                      fontFamily: "Roboto-medium",
                                      letterSpacing: 0.5),
                                ),
                              ),
                              const  SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  "${employeeModel!.handphone}",
                                  style: TextStyle(
                                      color: blackColor4,
                                      fontSize: 10,
                                      fontFamily: "Roboto-medium",
                                      letterSpacing: 0.5),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                  width: Get.mediaQuery.size.width - 40,
                                  child: Divider(
                                    color: Colors.black.withOpacity(0.1),
                                    height: 1,
                                  )),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "Tempat Lahir",
                                  style: TextStyle(
                                      color: blackColor2,
                                      fontSize: 13,
                                      fontFamily: "Roboto-medium",
                                      letterSpacing: 0.5),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  "${employeeModel!.placeOfBirth ?? "-"}",
                                  style: TextStyle(
                                      color: blackColor4,
                                      fontSize: 10,
                                      fontFamily: "Roboto-medium",
                                      letterSpacing: 0.5),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                  width: Get.mediaQuery.size.width - 40,
                                  child: Divider(
                                    color: Colors.black.withOpacity(0.1),
                                    height: 1,
                                  )),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "Tanggal lahir",
                                  style: TextStyle(
                                      color: blackColor2,
                                      fontSize: 13,
                                      fontFamily: "Roboto-medium",
                                      letterSpacing: 0.5),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  "${employeeModel!.birthDate}",
                                  style: TextStyle(
                                      color: blackColor4,
                                      fontSize: 10,
                                      fontFamily: "Roboto-medium",
                                      letterSpacing: 0.5),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                  width: Get.mediaQuery.size.width - 40,
                                  child: Divider(
                                    color: Colors.black.withOpacity(0.1),
                                    height: 1,
                                  )),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "Agama",
                                  style: TextStyle(
                                      color: blackColor2,
                                      fontSize: 13,
                                      fontFamily: "Roboto-medium",
                                      letterSpacing: 0.5),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  "${employeeModel!.religion}",
                                  style: TextStyle(
                                      color: blackColor4,
                                      fontSize: 10,
                                      fontFamily: "Roboto-medium",
                                      letterSpacing: 0.5),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                  width: Get.mediaQuery.size.width - 40,
                                  child: Divider(
                                    color: Colors.black.withOpacity(0.1),
                                    height: 1,
                                  )),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "Golongan Darah",
                                  style: TextStyle(
                                      color: blackColor2,
                                      fontSize: 13,
                                      fontFamily: "Roboto-medium",
                                      letterSpacing: 0.5),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  "${employeeModel!.bloodType ?? "-"}",
                                  style: TextStyle(
                                      color: blackColor4,
                                      fontSize: 10,
                                      fontFamily: "Roboto-medium",
                                      letterSpacing: 0.5),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                  width: Get.mediaQuery.size.width - 40,
                                  child: Divider(
                                    color: Colors.black.withOpacity(0.1),
                                    height: 1,
                                  )),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }

  ///function
  void choiceAction(String choice) {
    if (choice == "logout") {
      // session.logout();
      // Get.offAll(SplassPage());

      //print(choice);

    }
  }

  void getDataPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // print("employee_id${sharedPreferences.getInt("employee_id")}");
    setState(() {
      employeeId = sharedPreferences.getInt("employee_id");
      name = sharedPreferences.getString("name");
      email = sharedPreferences.getString('email');
    });
    getEmployee(widget.employeeId.toString());
    await FirebaseFirestore.instance
        .collection('employee_locations')
        .where("employee_id", isEqualTo: employeeId ?? 0)
        .get()
        .then((value) {
      setState(() {
        name = value.docs[0]['name'];
        photo = value.docs[0]['photo'];
        isTrack = value.docs[0]['is_tracked'] ?? false;
      });
    });
  }

  ///widget
  Widget _header() {
    return Container(
      width: Get.mediaQuery.size.width,
      height: Get.mediaQuery.size.height * 0.35,
      color: baseColor2,
      child: Container(
        width: Get.mediaQuery.size.width,
        height: Get.mediaQuery.size.height * 0.3,
        margin: EdgeInsets.only(left: 20, right: 20, top: 60),
        child: Column(
          children: <Widget>[
            photo == null
                ? Container(
              child: Image.asset(
                "assets/images/profile-default.png",
                width: 70,
                height: 70,
              ),
            )
                : CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage('${photo}')),
            // Container(
            //   child: Image.asset(
            //     "assets/images/profile-default.png",
            //     width: 70,
            //     height: 70,
            //   ),
            // ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Text(
                "${employeeModel!.name ?? ""}",
                style: TextStyle(
                    fontFamily: "roboto-regular",
                    color: Colors.white,
                    letterSpacing: 0.5,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: Text(
                "${employeeModel!.employeeId ?? ""}",
                style: TextStyle(
                    fontFamily: "roboto-regular",
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 0.5,
                    fontSize: 11,
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              child: Text(
                "${employeeModel!.email ?? ""}",
                style: TextStyle(
                    fontFamily: "roboto-regular",
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 0.5,
                    fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<EmployeeModel?> getEmployee(id) async {
    setState(() {
      isLoading = true;
    });
    // employeeModel = await EmployeeRespository().employee(int.parse(widget.employeeId.toString()));

    setState(() {
      isLoading = false;
    });
    return employeeModel;
  }

}