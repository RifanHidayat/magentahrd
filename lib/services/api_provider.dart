// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
//
// import 'package:http/http.dart' as client;
// import 'package:magentahrd/models/example.dart';
// import 'package:magentahrd/services/api_clien.dart';
//
// class TodoApiProvider {
//   final _url = 'http://${base_url}/api/employees';
//
//   Future<List<Example>> fetchTodoList() async {
//     print('panggil data');
//     final response = await client.get(_url);
//     if (response.statusCode == 200) {
//       // print(response.body.length);
//       return compute(exampleFromJson, response.body);
//
//       // return ItemModel.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to Load');
//     }
//   }
//
//   Future addTodo(title) async {
//     final response = await client.post("$_url/create", body: {'name': title});
//     if (response.statusCode == 200) {
//       return response;
//     } else {
//       throw Exception('Failed to add data');
//     }
//   }
//
//   Future updateTodo(ids) async {
//     // print('$_url$ids/update');
//     final response =
//         await client.put("$_url$ids/update", body: {'done': "true"});
//     if (response.statusCode == 200) {
//       print('berhasil di update');
//       return response;
//     } else {
//       throw Exception('Failed to update data');
//     }
//   }
// }
