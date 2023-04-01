import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magentahrd/pages/admin/home/navbar.dart';
import 'package:magentahrd/pages/admin/login/admin.dart';

import 'package:magentahrd/pages/employee/login/login.dart';
import 'package:magentahrd/pages/employee/nav.dart';
import 'package:magentahrd/utalities/color.dart';
import 'package:magentahrd/utalities/constants.dart';
import 'package:magentahrd/vaidasi/validator.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_storage/get_storage.dart';
import 'package:magentahrd/pages/employee/home/dashboard_amin.dart';

class Wellcome extends StatefulWidget {
  @override
  _WellcomeState createState() => _WellcomeState();
}

enum statusLogin { signInemployee, notSignIn, signInadmin }

class _WellcomeState extends State<Wellcome> {
  Validasi validator = Validasi();
  statusLogin _loginStatus = statusLogin.notSignIn;

  var Cusername = new TextEditingController();
  var Cpassword = new TextEditingController();
  bool _obscureText = false;

  Widget _buildImage() {
    return Center(
      child: wellcome,
    );
  }

  // Widget _buildText() {
  //   return Container(
  //     width: double.infinity,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //         SizedBox(
  //           height: 50,
  //         ),
  //         Text(
  //           "Selamat Datang",
  //           textAlign: TextAlign.left,
  //           style: TextStyle(
  //               color: Colors.black,
  //               fontWeight: FontWeight.bold,
  //               fontFamily: 'SFReguler',
  //               fontSize: 25),
  //         ),
  //         SizedBox(
  //           height: 5,
  //         ),
  //         Text("di Magenta HRD Apps",
  //           textAlign: TextAlign.left,
  //           style: TextStyle(
  //               color: baseColor,
  //               fontWeight: FontWeight.bold,
  //               fontFamily: 'SFReguler',
  //               fontSize: 15
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  // Widget _buoldbtnadmin() {
  //   return Container(
  //     padding: EdgeInsets.symmetric(vertical: .0),
  //     width: double.infinity,
  //     // child: RaisedButton(
  //     //   onPressed: () {},
  //     //   child: Text('Enabled Button', style: TextStyle(fontSize: 20)),
  //     // ),
  //     child: RaisedButton(
  //       onPressed: () {
  //         // Navigator.push(context, MaterialPageRoute(
  //         //     builder: (context) => LoginAdmin()
  //         // ));
  //         Get.to(LoginAdmin());
  //       },
  //       padding: EdgeInsets.all(12.0),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(2.0),
  //       ),
  //       color: btnColor1,
  //       child: Text(
  //         'Login sebagai Admin',
  //         textAlign: TextAlign.left,
  //         style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 14.0,
  //             fontWeight: FontWeight.bold,
  //             fontFamily: "SFReguler"),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buoldbtemployee() {
  //   return Container(
  //       padding: EdgeInsets.symmetric(vertical: 25.0),
  //       width: double.infinity,
  //       child: OutlineButton(
  //         padding: EdgeInsets.all(12.0),
  //         onPressed: () {
  //           // Navigator.push(context, MaterialPageRoute(
  //           //     builder: (context) => LoginEmployee()
  //           // ));
  //           Get.to(LoginEmployee());
  //         },
  //         child: Text(
  //           "Login sebagai Employee",
  //           style: TextStyle(
  //             color: btnColor1,
  //             fontFamily: 'SFReguler',
  //           ),
  //         ),
  //       ));
  // }

  Widget _buildUsername() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          // alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.3),
            //     spreadRadius: 1,
            //     blurRadius: 0,
            //     offset: Offset(0, 0),
            //   )
            // ],
          ),
          // height: 60.0,
          child: TextFormField(
            controller: Cusername,
            cursorColor: Colors.black38,
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 1, color: Colors.black54),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 3, color: Color.fromRGBO(95, 84, 206, 10)),
                borderRadius: BorderRadius.circular(5),
              ),
              hintText: "Username",
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.black38,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Text(
        //   'Password',
        //   style: TextStyle(color: Colors.black38, fontFamily: "SFReguler"),
        // ),
        SizedBox(height: 10.0),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.3),
            //     spreadRadius: 1,
            //     blurRadius: 0,
            //     offset: Offset(0, 0),
            //   )
            // ],
          ),
          height: 60.0,
          child: TextFormField(
            cursorColor: Colors.black38,
            obscureText: !_obscureText,
            controller: Cpassword,
            keyboardType: TextInputType.name,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 1, color: Colors.black54),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 3, color: Color.fromRGBO(95, 84, 206, 10)),
                borderRadius: BorderRadius.circular(5),
              ),
              hintText: "Password",
              suffixIcon: IconButton(
                color: Colors.black38,
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black38,
                ),
                onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.black38,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          validator.validation_login(context, Cusername.text, Cpassword.text);

          // Navigator.pop(context);
          //  Navigator.of(context).pushReplacement(new MaterialPageRoute(
          //      builder: (BuildContext context) => new NavBarEmployee()));
        },
        // padding: EdgeInsets.all(15.0),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(5.0),
        // ),
        // color: btnColor1,
        child: Text(
          'MASUK  ',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'SFReguler',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case statusLogin.notSignIn:
        return Scaffold(
          body: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildImage(),
                  _buildUsername(),
                  _buildPassword(),
                  _buildLoginBtn(),
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.pushNamed(context, "login_admin-page");
                  //   },
                  //   child: Text(
                  //     "Masuk sebagai admin",
                  //     style: TextStyle(color: btnColor1),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        );
      case statusLogin.signInemployee:
        return GetStorage().read("access_type").toString().toLowerCase() ==
                "admin".toString().toLowerCase()
            ? Dashboardpage()
            : NavBarEmployee();
      case statusLogin.signInadmin:
        return NavBarAdmin();
    }
  }

  getDataPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      int? nvalue = sharedPreferences.getInt("value");
      _loginStatus = nvalue == 1
          ? statusLogin.signInemployee
          : nvalue == 2
              ? statusLogin.signInadmin
              : statusLogin.notSignIn;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataPref();
  }
}
