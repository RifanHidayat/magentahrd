import 'dart:convert';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:magentahrd/models/checkin.dart';
import 'package:magentahrd/services/request.dart';
import 'package:magentahrd/assets/alert.dart';
import 'package:http/http.dart' as http;
import 'package:magentahrd/services/api_clien.dart';
import 'package:http_parser/http_parser.dart';

class CheckinController extends GetxController {
  var isLoading = true.obs;
  var checkins = <CheckinModel>[].obs;

  var checkinsToday = <CheckinModel>[].obs;
  var isLoadingList = true.obs;
  // Future<void> save(
  //     {required employeeId, latitude, longitude, address, image}) async {
  //   AlertApp().loadingIndicator();

  //   var body = {
  //     "employee_id": employeeId,
  //     "datetime": DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(),
  //     "latitude": latitude,
  //     "longitude": longitude,
  //     "address": address,
  //     "image": image
  //   };
  //   print(body);

  //   var request =
  //       await Request(url: "/api/inspections", body: jsonEncode(body)).post();
  //   var respone = jsonDecode(request.body);
  //   if (request.statusCode == 200) {
  //     Get.back();
  //     Get.back();

  //     fetchCheckin();
  //   } else {
  //     Get.back();
  //     AlertApp().message(respone['message']);
  //     print(respone['message']);
  //   }
  // }
  Future<void> save(
      {required employeeId, latitude, longitude, address, image}) async {
    AlertApp().loadingIndicator();

    final body = {
      "employee_id": employeeId.toString(),
      "datetime":
          DateFormat("yyyy-MM-dd hh:mm:dd").format(DateTime.now()).toString(),
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "address": address.toString(),
    };
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    print(body);
    // var request = await Request(url: "/api/inspections", body: body)
    //     .postMultipart(image: image);
    // var respone = jsonDecode(request.body);
    // zZZ
    var request = http.MultipartRequest(
      "POST",
      Uri.parse(base_url + "/api/inspections"),
    );

    request.headers.addAll(requestHeaders);
    print(" employee id ${body['employee_id'].toString()}");
    // request.fields.addAll(body);
    request.fields['employee_id'] = body['employee_id'].toString();
    request.fields['datetime'] = body['datetime'].toString();
    request.fields['address'] = body['address'].toString();
    request.fields['latitude'] = body['latitude'].toString();
    request.fields['longitude'] = body['longitude'].toString();
    var picture = await http.MultipartFile.fromPath('image', image,
        contentType: MediaType('image', 'jpg'));
    request.files.add(picture);

    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    var resp = jsonDecode(respStr);

    if (response.statusCode == 200) {
      Get.back();
      AlertApp().message(resp['message']);

      fetchCheckin();
    } else {
      Get.back();
      AlertApp().message(resp['message']);
      print(resp['message']);
    }
  }

  Future<void> delete({required id}) async {
    AlertApp().loadingIndicator();

    var request = await Request(url: "/api/inspections/${id}").delete();
    var respone = jsonDecode(request.body);
    if (request.statusCode == 200) {
      Get.back();
      Get.back();

      fetchCheckin();
    } else {
      Get.back();
      AlertApp().message(respone['message']);
      print(respone['message']);
    }
  }

  Future<void> fetchCheckinToday() async {
    try {
      isLoadingList.value = true;
      final response = await http.get(Uri.parse('$base_url/api/inspections'));
      final resp = jsonDecode(response.body);
      if (response.statusCode == 200) {
        checkinsToday.value = CheckinModel.fromJsonToList(resp['data']);
        isLoadingList.value = false;
        checkinsToday.value = checkinsToday.where((element) {
          return DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(element.dateTime.toString())) ==
              DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(DateTime.now().toString()));
        }).toList();
      } else {
        isLoadingList.value = false;
        checkins.value = [];
      }
    } catch (e) {
      checkins.value = [];
      isLoadingList.value = false;
      print(e);
    }
  }

  Future<void> fetchCheckin() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse('$base_url/api/inspections'));
      final resp = jsonDecode(response.body);
      if (response.statusCode == 200) {
        isLoading.value = false;
        checkins.value = CheckinModel.fromJsonToList(resp['data']);
      } else {
        isLoading.value = false;
        checkins.value = [];
      }
    } catch (e) {
      checkins.value = [];
      isLoading.value = false;
      print(e);
    }
  }

  Future<void> fetchCheckinByEmployeId({id}) async {
    print(id);
    checkins.clear();
    try {
      isLoading.value = true;
      final response = await http
          .get(Uri.parse('$base_url/api/inspections?employee_id=${id}'));
      final resp = jsonDecode(response.body);
      if (response.statusCode == 200) {
        isLoading.value = false;
        checkins.value = CheckinModel.fromJsonToList(resp['data']);
      } else {
        isLoading.value = false;
        checkins.value = [];
      }
    } catch (e) {
      checkins.value = [];
      isLoading.value = false;
      print(e);
    }
  }
}
