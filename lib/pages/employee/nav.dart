import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:magentahrd/pages/employee/account/account.dart';

import 'package:magentahrd/pages/employee/home/home.dart';

class NavBarEmployee extends StatefulWidget {
  @override
  _NavBarEmployeeState createState() => _NavBarEmployeeState();
}

class _NavBarEmployeeState extends State<NavBarEmployee> {
  // Properties & Variables needed

  int currentTab = 0; // to keep track of active tab index
  final List<Widget> screens = [
    HomeEmployee(),
    AccountEmployee(),
  ]; // to store nested tabs
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = HomeEmployee(); // Our first view in viewport

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen =
                            HomeEmployee(); // if user taps on this dashboard tab will be active
                        currentTab = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[   
                        Icon(
                          Icons.home,
                          color: currentTab == 0
                              ? HexColor('#6750A4')
                              : HexColor('#B2B2B2'),
                        ),
                        Text(
                          'Home',
                          style: TextStyle(
                              color: currentTab == 0
                                  ? HexColor('#6750A4')
                                  : HexColor('#B2B2B2'),
                              fontFamily: "Walkway-UltraBold"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Right Tab bar icons

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen =
                            AccountEmployee(); // if user taps on this dashboard tab will be active
                        currentTab = 3;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                    
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          color: currentTab == 3
                              ? HexColor('#6750A4')
                              : HexColor('#B2B2B2'),
                        ),
                        Text(
                          'Akun',
                          style: TextStyle(
                              color: currentTab == 3
                                  ? HexColor('#6750A4')
                                  : HexColor('#B2B2B2'),
                              fontFamily: "Walkway-UltraBold"),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
