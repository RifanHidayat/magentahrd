import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:magentahrd/pages/employee/account/profile.dart';
import 'package:magentahrd/services/api_clien.dart';

class ListEmployee extends StatefulWidget {
  @override
  _ListEmployeeState createState() => _ListEmployeeState();
}

class _ListEmployeeState extends State<ListEmployee> {
  ///widget
  Map? _employee;
  bool? _isLoading;
  List _employees = [];

  Widget _buildemployees(index) {
    return InkWell(
      onTap: () {
        Get.to(DetailProfile(
          id: _employees[index]['id'],
        ));
      },
      child: Container(
        margin: EdgeInsets.only(left: 5, top: 15),
        child: Row(
          children: <Widget>[
            Container(
              child: CircleAvatar(
                radius: 30,
                backgroundImage:
                    NetworkImage("${image_ur}/${_employees[index]['photo']}"),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${_employees[index]["first_name"]} ",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _employees[index]["employee_id"],
                    style: TextStyle(color: Colors.black38),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 100,
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Divider(
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _listemployee() {
    return Container(
      child: Expanded(
        child: Container(
          child: _isLoading == true
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: _employees.length,
                  itemBuilder: (context, index) {
                    return _employees[index]['mobile_access_type'] != "admin"
                        ? _buildemployees(index)
                        : Text("");
                  }),
        ),
      ),
    );
  }

  ///faunction
  _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
          decoration: InputDecoration(hintText: 'Search...'),
          onChanged: (text) {
            _employees = _employee!['data'];
            setState(() {
              _employees = _employees.where((data) {
                var noteTitle = data['first_name'].toLowerCase();
                return noteTitle.contains(text);
              }).toList();
            });
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black87, //modify arrow color from here..
        ),
        backgroundColor: Colors.white,
        title: Text(
          "Semua Karyawan",
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            // Container(
            //   width: double.infinity,
            //   height: 150,
            //   color: Colors.redAccent[100],
            // ),
            _searchBar(),
            _listemployee()
          ],
        ),
      ),
    );
  }

  //ge data from api--------------------------------
  Future dataEmployee() async {
    try {
      setState(() {
        _isLoading = true;
      });
      http.Response response =
          await http.get(Uri.parse("$base_url/api/employees"));
      _employee = jsonDecode(response.body);
      _employees = _employee!['data'];
      // var data= _employee['data'].wher((data) => data["first_name"].toString().contains("Panut")
      // ).toList();
      // print(data);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataEmployee();
  }
}
