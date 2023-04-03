import 'dart:convert';

// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:magentahrd/models/companies.dart';
import 'package:magentahrd/pages/admin/home/navbar.dart';
import 'package:magentahrd/pages/employee/home/dashboard_amin.dart';
import 'package:magentahrd/pages/employee/nav.dart';
import 'package:magentahrd/shared_preferenced/sessionmanage.dart';
import 'package:magentahrd/utalities/alert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:get_storage/get_storage.dart';
//baru
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocode/geocode.dart';
import 'package:magentahrd/controler/locaation.dart';
import 'package:magentahrd/firebase_option.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';

import 'package:flutter_background_service/flutter_background_service.dart';

// String base_url = "https://hrd.magentamediatama.net";
String base_url = "https://hrd2.magentamediatama.net";
// String base_url = "https://4bb5-114-142-173-24.ngrok.io";
// String base_url = "https://magentahrd.arenzha.tech";
// String base_url = "http://192.168.0.111:8000";
// String base_url = "https://magentahrd.arenzha.tech";

String image_ur = "https://arenzha.s3.ap-southeast-1.amazonaws.com";
String baset_url_event = "https://react.magentamediatama.net";
var controller = Get.put(LocaationController());

//init serevice

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: IOSInitializationSettings(),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  //service.invoke("stopService");

  service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (Platform.isIOS) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.ios);
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.android,
      );
    }
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        flutterLocalNotificationsPlugin.show(
          888,
          'Magenta HRD',
          '${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        // if you don't using custom notification, uncomment this
        // service.setForegroundNotificationInfo(
        //   title: "My App Service",
        //   content: "Updated at ${DateTime.now()}",
        // );
      }
    }

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
    sendData();
  });
}

Future<void> sendData() async {
  controller.getCurrentLocation();
  print("employee id ${controller.empoyeeId.value.toString()}");
  print("Latitude ${controller.latitude.value}");
  print("Longitde ${controller.longitude.value}");
  print("address ${controller.addres.value}");

  // if (isTrack == true)  {
  await FirebaseFirestore.instance
      .collection('employee_locations')
      .doc(controller.empoyeeId.value.toString())
      .update({
    "address": controller.addres.value.toString(),
    "latitude": controller.latitude.value.toString(),
    "longitude": controller.longitude.value.toString()
  }).then((result) {
    print("new USer true");
  }).catchError((onError) {
    print("onError ${onError}");
  });
}

class Services {
  SharedPreference sharedPreference = new SharedPreference();

  // budgetproject budget = new budgetproject();
  //function employeeee
  ///login employee
  Future<void> loginEmployee(
      BuildContext context, var username, var password) async {
    loading(context);
    final box = GetStorage();
    try {
      // String fcm_registration_token = await FirebaseMessaging().getAPNSToken();
      final response = await http
          .post(Uri.parse("$base_url/api/auth/mobile/employee"), body: {
        "username": username.toString().trim(),
        "password": password,
        // "fcm_registration_token": fcm_registration_token
      });

      //
      final data = jsonDecode(response.body);
      if (data['code'] == 200) {
        print(" USeer id ${data['data']}");
        // await box.write(
        //     'status', data['data']['employee']['is_tracked'].toString());
        await box.write('status', "1".toString());
        // await box.write(
        //     'access_type', data['data']['mobile_access_type'].toString());
        await box.write('access_type', "supervisor".toString());

        print(
            "Suprvisor accss ${data['data']['supervisor_access_type'].toString()}");
        sharedPreference.saveDataEmployee(
            1,
            data['data']['id'].toString(),
            data['data']['employee_id'].toString(),
            data['data']['username'],
            data['data']['employee']['name'],
            "",
            data['data']['employee']['email'],
            data['data']['employee']['photo'],
            data['data']['employee']['phone'],
            "office",
            "office",
            // data['data']['work_placement'],
            // data['data']['work_placement'],
            "",
            "",
            data['data']['employee']['gender'],
            data['data']['employee']['is_tracked ']);
        Navigator.pop(context);
        if (data['data']['mobile_access_type'] == "admin") {
          // service.startService();

          Get.offAll(Dashboardpage());
        } else {
          Get.offAll(NavBarEmployee());
        }
      } else {
        Navigator.pop(context);
        alert_error(context, "${data['message']}", "Close");
      }
    } on Exception catch (_) {
      alert_error(context, "Terjadi kesalahan", "Close");
    }
  }

  ///expense budget employee
  Future<void> expenseBudget(
      BuildContext context,
      var amount,
      date,
      note,
      event_id,
      budget_category_id,
      requested_by,
      image,
      project_number,
      status) async {
    loading(context);
    // try{
    final response = await http.post(
        Uri.parse("$baset_url_event/api/mobile/project/transactions"),
        body: {
          "description": note,
          "amount": amount,
          "account_id": budget_category_id,
          "project_id": event_id,
          "date": date,
          "image": '${image}',
          "status": status,
          "project_number": project_number
        });

    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      toast_success("${responseJson['message']}");
      Navigator.pop(context);
      Navigator.of(context).pop('update');
    } else {
      toast_error("${responseJson['message']}");
      Navigator.pop(context);
    }

    // }catch(e){
    //
    //   toast_error("${e}");
    //   print("${e}");
    //
    // }
  }

  ///expense budget employee
  Future<void> editTransaction(
      BuildContext context,
      var amount,
      date,
      note,
      event_id,
      budget_category_id,
      requested_by,
      image,
      var project_number,
      transaction_id,
      status_transaction,
      path) async {
    loading(context);
    try {
      final response = await http.patch(
          Uri.parse(
              "$baset_url_event/api/mobile/project/transactions/${transaction_id}"),
          body: {
            "description": note,
            "amount": amount,
            "account_id": budget_category_id,
            "project_id": event_id,
            "date": date,
            "image": image,
            "status": status_transaction,
            "project_number": project_number,
            "path": path.toString()
          });

      final responseJson = jsonDecode(response.body);
      if (responseJson['code'] == 200) {
        toast_success("${responseJson['message']}");
        Navigator.pop(context);
        Navigator.of(context).pop('update');
      } else {
        toast_error("${responseJson['message']}");
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      toast_error("${e}");
      print("${e}");
    }
  }

  Future<void> deleteTransactionBudget(
      BuildContext context, var id, projectNumber) async {
    loading(context);
    try {
      final response = await http.delete(
        Uri.parse(
            "$baset_url_event/api/mobile/project/transactions/${id}/${projectNumber}"),
      );

      final responseJson = jsonDecode(response.body);
      if (responseJson['code'] == 200) {
        toast_success("${responseJson['message']}");
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        toast_error("${responseJson['message']}");
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      toast_error("${e}");
      print("${e}");
    }
  }

  ///function checkin employee
  // Future<void> checkin(
  //     BuildContext context,
  //     var photos,
  //     var remark,
  //     var employee_id,
  //     lat,
  //     long,
  //     date,
  //     time,
  //     status,
  //     office_latitude,
  //     office_longitude,
  //     category) async {
  //   loading(context);

  //   final response = await http
  //       .post(Uri.parse("$base_url/api/attendances/action/check-in"), body: {
  //     "employee_id": employee_id.toString(),
  //     "date": date.toString(),
  //     "clock_in": "${date.toString()} ${time.toString()}",
  //     "image": photos.toString().trim(),
  //     "note": remark,
  //     "clock_in_latitude": lat,
  //     "clock_in_longitude": long,
  //     "status": "$status",
  //     "category": "$category",
  //     "office_latitude": office_latitude,
  //     "office_longitude": office_longitude,
  //     "screen": "DetailAttendanceAdmin"
  //   });

  //   final responseJson = jsonDecode(response.body);
  //   if (responseJson['code'] == 200) {
  //     SharedPreferences sharedPreferences =
  //         await SharedPreferences.getInstance();
  //     Navigator.pop(context);
  //     // alert_success(context, "${responseJson['message']}", "Back");
  //     toast_success("${responseJson['message']}");
  //     Navigator.pop(context);
  //   } else {
  //     Navigator.pop(context);
  //     alert_info(context, "${responseJson['message']}", "Back");
  //     print(responseJson);
  //   }
  // }

  Future<void> checkin(
      BuildContext context,
      var photos,
      var remark,
      var employee_id,
      lat,
      long,
      date,
      time,
      status,
      office_latitude,
      office_longitude,
      working_pattern_id,
      category) async {
    loading(context);
    // if (GetStorage().read("status") == "1") {
    //     await initializeService();
    //     final service = FlutterBackgroundService();

    //     var isRunning = await service.isRunning();
    //     if (isRunning) {
    //       //   service.invoke("stopService");
    //     } else {
    //       service.startService();
    //     }
    //   }

    final response = await http
        .post(Uri.parse("$base_url/api/attendances/action/clockin"), body: {
      // note
      "employee_id": employee_id.toString(),
      "date": date.toString(),
      "working_pattern_id": working_pattern_id.toString(),
      "clock_in_time": time.toString(),
      "clock_in_at": "${date.toString()} ${time.toString()}",
      "clock_in_ip_address": "",
      "clock_in_device_detail": "",
      "attachment": photos.toString().trim(),
      "clock_in_latitude": lat,
      "clock_in_longitude": long,
      // "status": "$status",
      // "category": "$category",
      "clock_in_office_latitude": office_latitude,
      "clock_in_office_longitude": office_longitude,
      "note": remark,
      "screen": "DetailAttendanceAdmin"
    });

    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      if (GetStorage().read("status") == "1") {
        await initializeService();
        final service = FlutterBackgroundService();

        var isRunning = await service.isRunning();
        if (isRunning) {
          //   service.invoke("stopService");
        } else {
          service.startService();
        }
      }

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      Navigator.pop(context);
      // alert_success(context, "${responseJson['message']}", "Back");
      toast_success("${responseJson['message']}");
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      alert_info(context, "${responseJson['message']}", "Back");
      print(responseJson);
    }
  }

  ///function checkout employee
  Future<void> checkout(
      BuildContext context,
      var photos,
      var remark,
      var employee_id,
      lat,
      long,
      date,
      time,
      status,
      office_latitude,
      office_longitude,
      // is_long_shift,
      // long_shift_working_pattern_id,
      category) async {
    loading(context);
    final service = FlutterBackgroundService();
    // var isRunning = await service.isRunning();
    // if (isRunning) {
    //   service.invoke("stopService");
    // } else {
    //   // service.startService();
    // }
    final response = await http
        .post(Uri.parse("$base_url/api/attendances/action/check-out"), body: {
      "employee_id": employee_id.toString(),
      "date": date.toString(),
      "clock_out": "${date.toString()} ${time.toString()}",
      "image": photos.toString().trim(),
      "note": remark,
      "clock_out_latitude": lat,
      "clock_out_longitude": long,
      "status": "$status",
      "category": "$category",
      "office_latitude": office_latitude,
      "office_longitude": office_longitude,
      // "long_shift_working_pattern_id": long_shift_working_pattern_id.toString(),
      // "is_long_shift": is_long_shift.toString(),
      "screen": "DetailAttendanceAdmin"
    });

    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      final service = FlutterBackgroundService();
      var isRunning = await service.isRunning();
      if (isRunning) {
        service.invoke("stopService");
      } else {
        // service.startService();
      }
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      Navigator.pop(context);
      sharedPreferences.setString("clock_out", time.toString());
      sharedPreferences.setBool("check_in", false);
      sharedPreferences.setBool("check_out", true);
      // alert_success(context, "${responseJson['message']}", "Back");
      toast_success("${responseJson['message']}");
      Navigator.pop(context);
    } else {
      Navigator.pop(context);

      alert_info(context, "${responseJson['message']}", "Back");
    }
  }

  Future<void> checkout2(
      BuildContext context,
      var photos,
      var remark,
      var employee_id,
      lat,
      long,
      date,
      time,
      status,
      office_latitude,
      office_longitude,
      is_long_shift,
      long_shift_working_pattern_id,
      category) async {
    loading(context);
    final response = await http
        .post(Uri.parse("$base_url/api/attendances/action/clockout"), body: {
      "employee_id": employee_id.toString(),
      "date": date.toString(),
      "clock_out_time": time.toString(),
      "clock_out_at": "${date.toString()} ${time.toString()}",
      "clock_out_ip_address": "",
      "clock_out_device_detail": "",
      "attachment": photos.toString().trim(),
      "note": remark,
      "clock_out_latitude": lat,
      "clock_out_longitude": long,
      "clock_out_office_latitude": office_latitude,
      "clock_out_office_longitude": office_longitude,
      "long_shift_working_pattern_id": long_shift_working_pattern_id.toString(),
      "is_long_shift": is_long_shift.toString(),
      "screen": "DetailAttendanceAdmin"
    });
    // "status": "$status",
    // "category": "$category",
    loading(context);
    // final service = FlutterBackgroundService();
    // var isRunning = await service.isRunning();
    // if (isRunning) {
    //   service.invoke("stopService");
    // } else {
    //   // service.startService();
    // }

    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      final service = FlutterBackgroundService();
      var isRunning = await service.isRunning();
      if (isRunning) {
        service.invoke("stopService");
      } else {
        // service.startService();
      }
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      Navigator.pop(context);
      sharedPreferences.setString("clock_out", time.toString());
      sharedPreferences.setBool("check_in", false);
      sharedPreferences.setBool("check_out", true);
      // alert_success(context, "${responseJson['message']}", "Back");
      toast_success("${responseJson['message']}");
      Navigator.pop(context);
    } else {
      Navigator.pop(context);

      alert_info(context, "${responseJson['message']}", "Back");
    }
  }

  ///function change password employee
  Future<void> change_password(
      BuildContext context, var password, username, email, id) async {
    loading(context);
    final response = await http
        .patch(Uri.parse("$base_url/api/employees/$id/edit-account"), body: {
      "username": username.toString(),
      "email": email.toString(),
      "password": password.toString(),
    });

    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      Navigator.pop(context);
      toast_success("${responseJson['message']}");
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      toast_error("${responseJson['message']}");
    }
  }

  ///finihed task
  Future<String> finished_task(BuildContext context, var id) async {
    final response =
        await http.patch(Uri.parse("$baset_url_event/api/projects/task/${id}"));
    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      return "200";
    } else {
      return "400";
    }
  }

  ///function companies
  // Future<List<Companies>> companies(BuildContext context, var id) async {
  //   loading(context);
  //   final response = await http.get("$base_url/api/employees/1/companies");
  //   final data = jsonDecode(response.body);
  //   Toast.show("$data", context);
  //   if (data['code'] == 200) {
  //     final List<Companies> company =
  //         companiesFromJson(response.body) as List<Companies>;
  //
  //     return company;
  //   } else {
  //     Navigator.pop(context);
  //   }
  // }

  Future<void> clearTokenemployee(var id) async {
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke("stopService");
    } else {
      // service.startService();
    }
    final response = await http
        .post(Uri.parse("$base_url/api/logout/mobile/employee"), body: {
      "employee_id": id,
    });
    final data = jsonDecode(response.body);

    if (data['200']) {
      print("berhasil");
    } else {
      print("gagal");
    }
  }

  //leave
  Future<void> leaveSubmission(BuildContext context, var employee_id,
      date_of_filing, leaves_dates, description, category) async {
    loading(context);
    final response =
        await http.post(Uri.parse("$base_url/api/leave-applications"), body: {
      "employee_id": employee_id,
      "date": date_of_filing.toString(),
      "application_dates": leaves_dates.toString(),
      "leave_category_id": category.toString(),
      "approval_status": "pending",
      "note": description,
    });

    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      toast_success("${responseJson['message']}");
      Get.back();
      Get.back();
    } else {
      print(leaves_dates.toString());
      toast_error("${responseJson['message']}");
      Get.back();
      print(responseJson.toString());
      print(date_of_filing.toString());
    }
  }

  Future<void> leaveEdit(BuildContext context, var id, employee_id,
      date_of_filing, leaves_dates, description, category) async {
    loading(context);
    final response = await http
        .post(Uri.parse("$base_url/api/leave-applications/$id"), body: {
      "employee_id": employee_id,
      "date": date_of_filing.toString(),
      "application_dates": leaves_dates.toString(),
      "leave_category_id": category.toString(),
      "approval_status": "pending",
      "note": description,
    });

    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      toast_success("${responseJson['message']}");
      Navigator.pop(context, "update");
      Navigator.pop(context, "update");
    } else {
      print(leaves_dates.toString());
      Toast.show("${responseJson['message']}", context);
      print(responseJson.toString());
      print(date_of_filing.toString());
    }
  }

  Future<void> deleteLeave(BuildContext context, var id) async {
    loading(context);
    final response =
        await http.delete(Uri.parse("${base_url}/api/leave-submissions/$id"));
    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      Get.back();
      toast_success("${responseJson['message']}");
      return responseJson;
    } else {
      Get.back();
      alert_error(context, "${responseJson['message']}", "Close");
      return responseJson;
    }
  }

  Future<void> leaveAproval(BuildContext context, var id, approval) async {
    loading(context);
    final response = await http.post(
        Uri.parse("$base_url/api/leave-submissions/action/$approval/$id"));

    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      Get.back();
      toast_success("${responseJson['message']}");
    } else {
      Get.back();
      toast_error("${responseJson['message']}");
    }
  }

  //sick
  Future<void> sickSubmission(BuildContext context, var employee_id,
      date_of_filing, sick_dates, description) async {
    loading(context);
    final response =
        await http.post(Uri.parse("$base_url/api/sick-applications"), body: {
      "employee_id": employee_id,
      "date": date_of_filing.toString(),
      "application_dates": sick_dates.toString(),
      "note": description,
      "approval_status": "pending",
      "attachment": "",
    });

    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      toast_success("${responseJson['message']}");
      Get.back();
      Get.back();
      print(responseJson.toString());
    } else {
      toast_error("${responseJson['message']}");
      Get.back();
      print(responseJson.toString());
    }
  }

  Future<void> sickEdit(BuildContext context, var id, employee_id,
      date_of_filing, sick_dates, old_sick_dates, description) async {
    loading(context);

    try {
      final response = await http
          .patch(Uri.parse("$base_url/api/sick-submissions/$id"), body: {
        "employee_id": employee_id,
        "date_of_filing": date_of_filing.toString(),
        "sick_dates": sick_dates.toString(),
        "description": description,
        "old_sick_dates": old_sick_dates,
      });

      final responseJson = jsonDecode(response.body);
      if (responseJson['code'] == 200) {
        toast_success("${responseJson['message']}");
        Get.back();
        Navigator.pop(context, "update");
      } else {
        toast_error("${responseJson['message']}");
        Get.back();
        print(responseJson.toString());
      }
    } catch (e) {
      print(e);
      Toast.show("${e}", context);
      Get.back();
    }
  }

  Future<void> deleteSick(BuildContext context, var id) async {
    loading(context);
    final response =
        await http.delete(Uri.parse("${base_url}/api/sick-submissions/$id"));
    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      Get.back();
      toast_success("${responseJson['message']}");
      return responseJson;
    } else {
      Get.back();
      alert_error(context, "${responseJson['message']}", "Close");
      return responseJson;
    }
  }

  Future<void> sickAproval(BuildContext context, var id, approval) async {
    loading(context);
    final response = await http
        .post(Uri.parse("$base_url/api/sick-submissions/action/$approval/$id"));

    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      Navigator.pop(context, "update");
      toast_success("${responseJson['message']}");
    } else {
      Get.back();
      toast_error("${responseJson['message']}");
    }
  }

  //permission

  Future<void> permissionSubmission(
      BuildContext context,
      var employee_id,
      date_of_filing,
      permission_dates,
      number_of_days,
      permission_category_id,
      description) async {
    loading(context);
    final response = await http
        .post(Uri.parse("$base_url/api/permission-submissions"), body: {
      "employee_id": employee_id,
      "date_of_filing": date_of_filing.toString(),
      "permission_dates": permission_dates.toString(),
      "number_of_days": number_of_days,
      "description": description,
      "permission_category_id": permission_category_id
    });

    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      toast_success("${responseJson['message']}");
      Get.back();
      Get.back();
    } else {
      toast_error("${responseJson['message']}");
      Get.back();
      print(responseJson.toString());
    }
  }

  Future<void> deletePermission(BuildContext context, var id) async {
    loading(context);
    final response = await http
        .delete(Uri.parse("${base_url}/api/permission-submissions/$id"));
    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      Get.back();
      toast_success("${responseJson['message']}");
      return responseJson;
    } else {
      Get.back();
      alert_error(context, "${responseJson['message']}", "Close");
      return responseJson;
    }
  }

  Future<void> permissionAproval(BuildContext context, var id, approval) async {
    loading(context);
    final response = await http.post(
        Uri.parse("$base_url/api/permission-submissions/action/$approval/$id"));

    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      Get.back();
      toast_success("${responseJson['message']}");
    } else {
      Get.back();
      toast_error("${responseJson['message']}");
    }
  }

  Future<void> editpermissionSubmission(
      BuildContext context,
      var id,
      employee_id,
      date_of_filing,
      permission_dates,
      number_of_days,
      permission_category_id,
      old_permission_dates,
      description) async {
    loading(context);
    final response = await http
        .patch(Uri.parse("$base_url/api/permission-submissions/$id"), body: {
      "employee_id": employee_id,
      "date_of_filing": date_of_filing.toString(),
      "permission_dates": permission_dates.toString(),
      "number_of_days": number_of_days,
      "description": description,
      "permission_category_id": permission_category_id,
      "old_permission_dates": old_permission_dates
    });

    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      toast_success("${responseJson['message']}");
      Get.back();
      Navigator.pop(context, "update");
    } else {
      toast_error("${responseJson['message']}");
      Get.back();
      print(responseJson.toString());
    }
  }

  //payslip
  Future<void> payslipPermission(BuildContext context, var id) async {
    loading(context);
    final response = await http.get(Uri.parse("$base_url/api/employees/$id"));

    final responseJson = jsonDecode(response.body);
    if (responseJson['code'] == 200) {
      print(responseJson.toString());
      if (responseJson['data']['payslip_permission'].toString() == "1") {
        Get.back();
        // Get.to(TabsMenuPayslip());
      } else {
        Get.back();
        alert_error(context, "Anda tidak mempunyai akses", "Close");
      }
    } else {
      Get.back();
      // print(leaves_dates.toString());
      // Toast.show("${responseJson['message']}", context);
      // Get.back();
      // print(responseJson.toString());
      // print(date_of_filing.toString());
    }
  }

  //-----------end fucnction employeee-------

  //fuction admin

  Future<void> loginAdmin(
      BuildContext context, var username, var password) async {
    // String fcm_registration_token = await FirebaseMessaging().getToken();
    loading(context);
    final response =
        await http.post(Uri.parse("$base_url/api/login/mobile/admin"), body: {
      "username": username.toString().trim(),
      "password": password,
      // "fcm_registration_token": fcm_registration_token
    });
    //
    final data = jsonDecode(response.body);
    if (data['code'] == 200) {
      //final loginmodel = loginEmployeeFromJson(response.body);
      sharedPreference.saveDataEmployee(
          2,
          data['data']['id'].toString(),
          data['data']['employee_id'],
          data['data']['username'],
          data['data']['first_name'],
          data['data']['last_name'],
          data['data']['email'],
          "",
          data['data']['contact_number'],
          data['data']['work_placement'],
          data['data']['work_placement'],
          "",
          "",
          data['data']['gender'],
          "s");
      Navigator.pop(context);
      Get.offAll(NavBarAdmin());
      // Navigator.pushNamedAndRemoveUntil(
      //     context, "navbar_admin-page", (route) => false);
    } else {
      Navigator.pop(context);
      alert_error(context, "${data['message']}", "Close");
    }
  }

  Future<void> approveAbsence(BuildContext context, var id_attendance, user_id,
      status, request_status, note, request_note) async {
    loading(context);
    final response = await http.post(
        Uri.parse("$base_url/api/attendances/$id_attendance/$status"),
        body: {
          "$request_status": "${user_id}",
          "${request_note}": "${note}",
          "screen": "DetailAttendanceEmployee",
        });
    //
    final data = jsonDecode(response.body);
    if (data['code'] == 200) {
      Navigator.pop(context);
      Navigator.pop(context);
      alert_success1(context, "${data['message']}", "Back");
    } else {
      Navigator.pop(context);
      alert_error(context, "${data['message']}", "Close");
    }
  }

  Future<void> clearTokenadmin(var id) async {
    final response =
        await http.post(Uri.parse("$base_url/api/logout/mobile/admin"), body: {
      "employee_id": id,
    });
    final data = jsonDecode(response.body);

    if (data['200']) {
      print("berhasil");
    } else {
      print("gagal");
    }
  }
}
