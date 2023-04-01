// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations, avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:http_parser/http_parser.dart';
import 'package:magentahrd/services/api_clien.dart';

class Request {
  final String? url;
  final dynamic body;

  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  Request({this.url, this.body});

  Future<http.Response> get() async {
    print(requestHeaders);
    return await http
        .get(Uri.parse(base_url + url!), headers: requestHeaders)
        .timeout(Duration(minutes: 2));
  }

  Future<http.Response> post() async {
    return await http.post(Uri.parse(base_url + url!), body: body);
  }

  Future<http.Response> patch() async {
    return await http
        .patch(Uri.parse(base_url + url!), body: body, headers: requestHeaders)
        .timeout(Duration(minutes: 2));
  }

  Future<http.Response> delete() async {
    return await http
        .delete(Uri.parse(base_url + url!), body: body, headers: requestHeaders)
        .timeout(Duration(minutes: 2));
  }

  Future postMultipart({image}) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse(base_url + url!),
      );

      request.headers.addAll(requestHeaders);
      print(" employee id ${body['employee_id'].toString()}");
      // request.fields.addAll(body);
      request.fields['employee_id'] = body['employee_id'].toString();
      request.fields['datetime'] = body['datetime'];
      request.fields['address'] = body['address'];
      request.fields['latitude'] = body['latitude'];
      request.fields['longitude'] = body['longitude'];
      var picture = await http.MultipartFile.fromPath('image', image,
          contentType: MediaType('image', 'jpg'));
      request.files.add(picture);

      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      return jsonDecode(respStr.toString());
    } on Exception catch (e) {
      throw e;
    }
  }
}
