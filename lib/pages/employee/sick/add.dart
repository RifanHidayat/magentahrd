import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:magentahrd/utalities/color.dart';
import 'package:magentahrd/vaidasi/validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AddSickPageEmployee extends StatefulWidget {
  @override
  _AddSickPageEmployeeState createState() => _AddSickPageEmployeeState();
}

class _AddSickPageEmployeeState extends State<AddSickPageEmployee> {
  DateTime startdate = DateTime.now();
  DateTime enddate = DateTime.now();
  var Cstartdate = new TextEditingController();
  var Cenddate = new TextEditingController();
  var jumlahPengambilanController = new TextEditingController();
  var descriptionController = new TextEditingController();
  var now;
  var _isLoading;
  var _submisionSick;

  var sick_dates = [];
  var sick_date_submit = [];
  var _initialSelectedDates;
  var _visible = false;
  var disable = true;
  var user_id;

  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black87, //modify arrow color from here..
        ),
        backgroundColor: Colors.white,
        title: new Text(
          "Buat Pengajuan Sakit",
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.only(left: 10, right: 10, top: 10),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              _buildtglPengajuan(),
              SizedBox(
                height: 10,
              ),
              _builddateLeave(),
              SizedBox(
                height: 10,
              ),
              _buildJmlPengambilan(),
              SizedBox(
                height: 10,
              ),
              _buildketerangan(),
              _buildbtsubmit()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildtglPengajuan() {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
          color: Colors.black38,
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: TextFormField(
          enabled: false,
          maxLines: 3,
          initialValue: '${now}',
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: 'Tanggal Pengajuan',
          ),
        ),
      ),
    );
  }

  Widget _builddateLeave() {
    return InkWell(
      onTap: () {
        //_selectStartDate(context);
        multipleDate();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 1,
            color: Colors.black38,
          ),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12.0),
          child: TextFormField(
            // cursorColor: Theme.of(context).cursorColor,
            enabled: false,
            controller: Cstartdate,
            maxLines: null,
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'Tanggal Sakit',
              labelStyle: TextStyle(),
              helperText: 'Helper text',
              suffixIcon: Icon(
                Icons.date_range,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJmlPengambilan() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
          color: Colors.black38,
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              enabled: false,
              controller: jumlahPengambilanController,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Jumlah Pengambilan',
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Visibility(
              visible: _visible,
              child: Container(
                child: Row(
                  children: [
                    Container(
                        child: Icon(
                      Icons.warning_amber_outlined,
                      color: Colors.amber,
                      size: 20,
                    )),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(
                        "Berikan surat keterangan sakit ke hrd",
                        style: TextStyle(
                            color: iconColor, fontFamily: "SFReguler"),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildketerangan() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
          color: Colors.black38,
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.0),
        child: TextFormField(
          controller: descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: 'Keterangan',
          ),
        ),
      ),
    );
  }

  Widget _buildbtsubmit() {
    return Container(
      width: double.infinity,
      height: 45,
      margin: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: btnColor1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: new OutlinedButton(
        onPressed: disable == true
            ? () {
                Validasi validasi = new Validasi();
                var data = sick_date_submit.toString().replaceAll((']'), '');
                var data1 = data.toString().replaceAll(('['), '');
                var data2 = data1.toString().replaceAll((' '), '');
                print(data2);
                // validasi.validation_leaves_submision(context,"0",user_id, now.toString(), data2.toString(), descriptionController.text,'submit');
                validasi.validation_sick_submision(
                    context,
                    "0",
                    user_id,
                    now.toString(),
                    data2.toString(),
                    "",
                    descriptionController.text,
                    "submit");
              }
            : null,
        child: Text(
          'Submit',
          style: TextStyle(
            color: Colors.white,
            fontFamily: "SFReguler",
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,

      initialDate: startdate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != startdate)
      setState(() {
        startdate = picked;
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        var startdate1 = formatter.format(startdate);
        Cstartdate.text = "$startdate1";
      });
  }

  _selectEndtDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: enddate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != enddate)
      setState(() {
        enddate = picked;
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        var enddate1 = formatter.format(enddate);
        Cenddate.text = "$enddate1";
      });
  }

  _getDataPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = sharedPreferences.getString("user_id");
    });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    setState(() {
      if (args.value is PickerDateRange) {
        _range =
            DateFormat('dd/MM/yyyy').format(args.value.startDate).toString() +
                ' - ' +
                DateFormat('dd/MM/yyyy')
                    .format(args.value.endDate ?? args.value.startDate)
                    .toString();
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        ///initialselectdates date leaves
        _initialSelectedDates = args.value;
        sick_dates.clear();
        sick_date_submit.clear();
        jumlahPengambilanController.text = args.value.length.toString();

        ///format date-leaves
        args.value.forEach(
          (DateTime date) {
            sick_dates.add(DateFormat('dd/MM/yyyy').format(date));
            sick_date_submit.add(DateFormat('yyyy-MM-dd').format(date));
          },
        );

        ///set date-leaves
        if (sick_dates.length <= 0) {
          Cstartdate.text = "";
        } else {
          Cstartdate.text = sick_dates.toString();
        }

        ///check total total leave
        if (3 < int.parse(jumlahPengambilanController.text.toString())) {
          _visible = true;
          disable = true;
        } else {
          _visible = false;
          disable = true;
        }
      } else {
        _rangeCount = args.value.length.toString();
        jumlahPengambilanController.text = args.value.length.toString();

        print("berhasil");
      }
    });
  }

  Future multipleDate() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: Get.mediaQuery.size.width - 40,
              height: Get.mediaQuery.size.height / 1.8,
              child: Column(
                children: [
                  SfDateRangePicker(
                    onSelectionChanged: _onSelectionChanged,
                    selectionMode: DateRangePickerSelectionMode.multiple,
                    initialSelectedDates: _initialSelectedDates,
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    _isLoading = false;
    // TODO: implement initState

    super.initState();
    final DateTime n = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    now = formatter.format(n);
    _getDataPref();
  }
}
