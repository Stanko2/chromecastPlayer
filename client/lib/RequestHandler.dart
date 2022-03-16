import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

String baseUrl = 'http://192.168.0.161:5000';

Future<dynamic> getRequest(String url) async {
  Response res = await get(Uri.parse(baseUrl + url));
  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  }
  return null;
}

Future<dynamic> postRequest(String url, Map<String, dynamic> data) async {
  try {
    Response res = await post(Uri.parse(baseUrl + url), body: jsonEncode(data));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  } catch (e) {
    print(e.toString());
    return null;
  }
}

Future<List<dynamic>> getTracks() async {
  Response res = await get(Uri.parse(baseUrl + "/tracks"));
  return jsonDecode(res.body);
}
