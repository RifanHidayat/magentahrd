import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:magentahrd/pages/employee/permission/add.dart';
import 'package:magentahrd/pages/employee/permission/shimmer_effect.dart';
import 'package:magentahrd/pages/employee/permission/tabmenu.dart';
import 'package:magentahrd/services/api_clien.dart';
import 'package:magentahrd/utalities/color.dart';
import 'package:magentahrd/utalities/constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ListPermissionPageEmployee extends StatefulWidget {
  ListPermissionPageEmployee({this.status});
  var status;
  @override
  _ListPermissionPageEmployeeState createState() =>
      _ListPermissionPageEmployeeState();
}

class _ListPermissionPageEmployeeState
    extends State<ListPermissionPageEmployee> {
  //variable
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var user_id;
  var _permission;

  bool _loading = true;

  Widget _buildnodata() {
    return Container(
      height: MediaQuery.of(context).size.height - 150,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: no_data_leave,
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                child: Text(
              "Belum ada pengajuan izin",
              style: TextStyle(color: Colors.black38, fontSize: 18),
            )),
          ],
        ),
      ),
    );
  }

//main contex---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.PermissionStatus.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
        iconTheme: IconThemeData(
          color: Colors.black87, //modify arrow color from here..
        ),
        backgroundColor: Colors.white,
        title: new Text(
          "Pengajuan Izin",
          style: TextStyle(color: Colors.black87),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(AddPermissionPageEmployee());
        },
        child: Icon(Icons.add),
        backgroundColor: btnColor1,
      ),
      body: RefreshIndicator(
        child: Container(
          child: Container(
            color: Colors.white38,
            child: Container(
              child: _loading
                  ? Center(
                      child: ShimmerProject(),
                    )
                  : ListView.builder(
                      itemCount: _permission['data'].length <= 0
                          ? 1
                          : _permission['data'].length,
                      // itemCount:1,

                      itemBuilder: (context, index) {
                        return _permission['data'].length.toString() == '0'
                            ? _buildnodata()
                            : _leave(index);
                        return _leave(1);
                      }),
            ),
          ),
        ),
        onRefresh: getDatapref,
      ),
    );
  }

  Widget _leave(index) {
    var id = _permission['data'][index]['id'];
    var date_of_filing = _permission['data'][index]['date_of_filing'];
    var permission_dates = _permission['data'][index]['permission_dates'];
    var description = _permission['data'][index]['description'];
    var category = _permission['data'][index]['permission_category']['name'];
    var max_day = _permission['data'][index]['permission_category']['max_day'];

    // var date_of_filing=DateFormat().format(DateFormat().parse(_leaves['data'][index]['date_of_filing'].toString()));
    return Card(
      child: Container(
        margin: EdgeInsets.only(top: 10, bottom: 20),
        width: Get.mediaQuery.size.width,
        child: Container(
          margin: EdgeInsets.only(top: 10, left: 5, right: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: Get.mediaQuery.size.width,
                margin: EdgeInsets.only(left: 10),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(
                      _permission['data'][index]['date_of_filing'].toString())),
                  style:
                      TextStyle(color: Colors.black45, fontFamily: "SFReguler"),
                  textAlign: TextAlign.end,
                ),
              ),
              SizedBox(
                height: 10,
              ),

              Container(
                width: Get.mediaQuery.size.width,
                child: Text(
                  "${category} (Maksimal:${max_day}  Hari)",
                  style:
                      TextStyle(color: Colors.black87, fontFamily: "SFBlack"),
                  textAlign: TextAlign.start,
                ),
              ),

              SizedBox(
                height: 10,
              ),
              Container(
                child: Text(
                  "Tanggal Izin",
                  style: TextStyle(color: Colors.black38),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Flex(direction: Axis.horizontal, children: [
                Expanded(
                    child: Container(
                  child: Text(
                    "[${permission_dates}]",
                    style: TextStyle(
                        color: Colors.black87, fontFamily: "SFReguler"),
                  ),
                ))
              ]),
              SizedBox(
                height: 15,
              ),

              description != null
                  ? Container(
                      child: Text(
                        "Keterangan",
                        style: TextStyle(color: Colors.black38),
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              description != null
                  ? Flex(direction: Axis.horizontal, children: [
                      Expanded(
                          child: Container(
                        child: Text(
                          "${_permission['data'][index]['description'].toString()}",
                          style: TextStyle(
                              color: Colors.black87, fontFamily: "SFReguler"),
                        ),
                      ))
                    ])
                  : Container(),
              SizedBox(
                height: 15,
              ),

              // _leaves['data'][index]['status']=="aproved"?Container():btnAction(id,_leaves['data'][index]['date_of_filing'],_leaves['data'][index]['leave_dates'],_leaves['data'][index]['description'])
            ],
          ),
        ),
      ),
    );
  }

  Widget btnAction(id, date_of_filing, leave_dates, description) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            width: 40,
            height: 40,
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.black12,
              ),
              child: IconButton(
                iconSize: 20,
                icon: Icon(
                  Icons.edit_outlined,
                  color: Colors.black45,
                ),
                onPressed: () {
                  // Get.to(LeaveEdit(
                  //   id: id,
                  //   date_of_filing: date_of_filing,
                  //   leave_dates: leave_dates,
                  //   description: description,));
                  //editLeave(id, date_of_filing, leave_dates, description);
                },
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.black12,
              ),
              child: IconButton(
                iconSize: 20,
                icon: Icon(
                  Icons.restore_from_trash_outlined,
                  color: Colors.black45,
                ),
                onPressed: () {
                  //print('pressed');
                  Services services = new Services();
                  // services.deleteLeave(context, id);
                  Alert(
                    context: context,
                    type: AlertType.warning,
                    title: "Apakah anda yakin?",
                    desc: "Data akan dihapus",
                    buttons: [
                      DialogButton(
                        child: Text(
                          "batalkan",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.grey,
                      ),
                      DialogButton(
                        child: Text(
                          "Iya",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          Get.back();
                          services.deleteLeave(context, id).then((value) {
                            _dataPermission(user_id);
                          });
                        },
                        gradient: LinearGradient(
                            colors: [Colors.green, Colors.green]),
                      )
                    ],
                  ).show();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void editLeave(var id,date_of_filing,leave_dates,description) async{
  //   var result=await Get.to(LeaveE(
  //     id: id,
  //     date_of_filing: date_of_filing,
  //     leave_dates: leave_dates,
  //     description: description,));
  //   if (result=="update"){
  //     _dataPermission(user_id);
  //   }
  // }
  //ge data from api--------------------------------
  Future _dataPermission(var user_id) async {
    try {
      setState(() {
        _loading = true;
      });
      http.Response response = await http.get(Uri.parse(
          "$base_url/api/employees/$user_id/permission-submissions?status=${widget.status}"));
      _permission = jsonDecode(response.body);
      print(_permission);
      setState(() {
        _loading = false;
      });
    } catch (e) {}
  }

  Future getDatapref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = sharedPreferences.getString("user_id");
      _dataPermission(user_id);
    });
  }

  @override
  void initState() {
    super.initState();
    //show modal detail project
    getDatapref();
  }

  void choiceAction(String choice) {
    if (choice == Constants.Permission) {
      Get.testMode = true;
      Get.to(TabMenuPermissionPageEmployee());
    }
  }
}
