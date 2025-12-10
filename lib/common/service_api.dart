import 'dart:async';
import 'dart:convert';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:hit_me_up/common/common.dart';

Future<dynamic> callApi(String httpType, dynamic params, String url) async {
  String response;

  HttpClient client = HttpClient();
  client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
  try {
    dynamic user = await getSharedPreference(kDataLoginUser);
    if (httpType == "GET") {
      HttpClientRequest request = await client.getUrl(Uri.parse(url));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Accept', 'application/json');
      if (user != null) {
        // request.headers.set('userId', user[kId].toString());
      }
      HttpClientResponse responses =
          await request.close().timeout(const Duration(seconds: 60));
      response = await responses.transform(utf8.decoder).join();
    } else {
      HttpClientRequest request = await client.postUrl(Uri.parse(url));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Accept', 'application/json');
      if (user != null) {
        // request.headers.set('userId', user[kId].toString());params = {_Map} size = 6
      }
      request.add(utf8.encode(json.encode(params)));
      HttpClientResponse responses =
          await request.close().timeout(const Duration(seconds: 60));
      response = await responses.transform(utf8.decoder).join();
    }
  } on HandshakeException catch (_) {
    var jsonError = {
      "message": "Server not responding. Please try again later",
      "code": 500
    };
    return jsonError;
  } on TimeoutException catch (_) {
    // A timeout occurred.
    var jsonError = {
      "message": "Server not responding. Please try again later",
      "code": 500
    };
    return jsonError;
  } on SocketException catch (_) {
    // Other exception
    var jsonError = {
      "error": "Something went wrong. Please try again later.",
      "code": 500
    };
    return jsonError;
  }
  var jsonResponse;
  try {
    if (response.toString().contains("status_code")) {
      jsonResponse = convert.jsonDecode(response);
    } else {
      var jsonError = {
        kDataMessage: "Something went wrong with server please try again.",
        kDataCode: 500
      };
      return jsonError;
    }
  } on Exception catch (_) {
    var jsonError = {
      kDataMessage: "Unable to connect the server please try again.",
      kDataCode: 500
    };
    return jsonError;
  }
  return jsonResponse;
}
