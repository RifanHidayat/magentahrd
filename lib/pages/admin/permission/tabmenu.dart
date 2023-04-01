import 'package:flutter/material.dart';

import 'package:magentahrd/pages/admin/permission/list.dart';

class TabmenuPermissionPageAdmin extends StatelessWidget {
  List<Widget> containers = [
    ListPermissionPageAdmin(
      status: "pending",
    ),
    ListPermissionPageAdmin(
      status: "rejected",
    ),
    ListPermissionPageAdmin(
      status: "approved",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Future<bool> _willPopCallback() async {
      Navigator.of(context).pop('update');
      return true;
    }

    return WillPopScope(
      onWillPop: _willPopCallback,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop("update"),
            ),
            backgroundColor: Colors.white,
            title: Text(
              'Pengajuan Izin',
              style: TextStyle(color: Colors.black87),
            ),
            bottom: TabBar(
              labelColor: Colors.black87,
              tabs: <Widget>[
                Tab(
                  text: 'PENDING',
                ),
                Tab(
                  text: 'REJECTED',
                ),
                Tab(
                  text: 'APPROVED',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: containers,
          ),
        ),
      ),
    );
  }
}
