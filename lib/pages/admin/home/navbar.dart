// import 'package:bottom_navy_bar/bottom_navy_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:magentahrd/page/admin/l/account/Account.dart';
// import 'package:magentahrd/page/admin/l/home/home.dart';
// import 'package:magentahrd/page/notification/notif.dart';
// import 'package:magentahrd/utalities/color.dart';
//
//
//
//
//
// class NavBarAdmin extends StatefulWidget {
//   @override
//   _NavBarAdminState createState() => _NavBarAdminState();
// }
//
// class _NavBarAdminState extends State<NavBarAdmin> {
//
//   int _currentIndex = 0;
//   PageController _pageController;
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//
//       body: SizedBox.expand(
//         child: PageView(
//           controller: _pageController,
//           onPageChanged: (index) {
//             setState(() => _currentIndex = index);
//           },
//           children: <Widget>[
//             HomeAdmin(),
//             // HistoryEmployee(),
//             Notifpage(),
//             AccountAdmin()
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavyBar(
//         selectedIndex: _currentIndex,
//         onItemSelected: (index) {
//           setState(() => _currentIndex = index);
//           _pageController.jumpToPage(index);
//         },
//         items: <BottomNavyBarItem>[
//           BottomNavyBarItem(
//             activeColor: baseColor,
//               inactiveColor: Colors.black38,
//               title: Text('Home',
//                 style: TextStyle(
//                   fontSize: 13,
//                 ),
//               ),
//               icon: Icon(Icons.home)
//           ),
//           // BottomNavyBarItem(
//           //     activeColor: Colors.redAccent[100],
//           //   inactiveColor: Colors.black,
//           //     title: Text('History'),
//           //     icon: Icon(Icons.history)
//           // ),
//           BottomNavyBarItem(
//               activeColor: baseColor,
//               inactiveColor: Colors.black38,
//               title: Text('Notification',
//                 style: TextStyle(
//                   fontSize: 13,
//                 ),
//               ),
//               icon: Icon(Icons.notification_important_rounded)
//           ),
//           BottomNavyBarItem(
//               activeColor: baseColor,
//               inactiveColor: Colors.black38,
//               title: Text('Account',
//                 style: TextStyle(
//                   fontSize: 13,
//                 ),
//               ),
//               icon: Icon(Icons.person)
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

// import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';

import 'package:magentahrd/pages/admin/account/account.dart';
import 'package:magentahrd/pages/admin/home/home.dart';

class NavBarAdmin extends StatefulWidget {
  @override
  _NavBarAdminState createState() => _NavBarAdminState();
}

class _NavBarAdminState extends State<NavBarAdmin> {
  // Properties & Variables needed

  int currentTab = 0; // to keep track of active tab index
  final List<Widget> screens = [
    HomeAdmin(),
    AccountAdmin(),
  ]; // to store nested tabs
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = HomeAdmin(); // Our first view in viewport

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
                            HomeAdmin(); // if user taps on this dashboard tab will be active
                        currentTab = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.home,
                          color: currentTab == 0 ? Colors.blue : Colors.black,
                        ),
                        Text(
                          'Home',
                          style: TextStyle(
                              color:
                                  currentTab == 0 ? Colors.blue : Colors.black,
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
                            AccountAdmin(); // if user taps on this dashboard tab will be active
                        currentTab = 3;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          color: currentTab == 3 ? Colors.blue : Colors.black,
                        ),
                        Text(
                          'Akun',
                          style: TextStyle(
                              color:
                                  currentTab == 3 ? Colors.blue : Colors.black,
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
