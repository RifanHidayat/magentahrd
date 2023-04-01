import 'package:flutter/material.dart';
import 'package:magentahrd/vaidasi/validator.dart';

class change_password extends StatefulWidget {
  change_password({this.email, this.username, this.id});
  var email, username, id;
  @override
  _change_passwordState createState() => _change_passwordState();
}

class _change_passwordState extends State<change_password> {
  var Cpassword = new TextEditingController();
  var Cconfirm_password = new TextEditingController();

  Widget _buildpassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text(
            'Password',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(),
          height: 60.0,
          child: TextFormField(
            controller: Cpassword,
            cursorColor: Colors.black38,
            obscureText: true,
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildconfirmpassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text(
            'Konfirmasi Password',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: "SFReguler",
            ),
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(),
          height: 60.0,
          child: TextFormField(
            controller: Cconfirm_password,
            cursorColor: Colors.black38,
            obscureText: true,
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.black,
              fontFamily: "SFReguler",
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildbtnsave() {
    return Container(
      width: double.infinity,
      height: 45,
      margin: EdgeInsets.symmetric(vertical: 30),
      child: ElevatedButton(
        onPressed: () {
          Validasi validasi = new Validasi();
          validasi.validation_change_password(context, Cpassword.text,
              widget.username, widget.email, widget.id, Cconfirm_password.text);
        },
        child: Text(
          'Simpan Perubahan',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: "SFReguler",
          ),
        ),
      ),
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
          "Ganti Password",
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          margin: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              _buildpassword(),
              SizedBox(
                height: 10,
              ),
              _buildconfirmpassword(),
              SizedBox(
                height: 20,
              ),
              _buildbtnsave(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.email.toString());
    print(widget.username.toString());
  }
}
