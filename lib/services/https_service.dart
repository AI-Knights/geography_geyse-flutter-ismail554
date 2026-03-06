import 'dart:convert';
import 'dart:developer';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

enum Method { post, get, put, patch, delete }

typedef E<T> = Future<Either<String, T>>;

class HttpManager {
  static E apiRequest({
    required String url,
    required Method method,
    Map? headers,
    Map? body,
    Map<String, dynamic>? queryParameters,
    String? name,
    required int statusCode,
  }) async {
    final headersDefault = headers?.cast<String, String>() ?? {}
      ..addAll({
        'content-type': 'application/json',
        'accept': 'application/json',
      });

    try {
      Uri uri = Uri.parse(url).replace(queryParameters: queryParameters);
      log(
        uri.toString(),
        name:
            "********** ${method.name.toUpperCase()}${name != null ? ' *** $name API **********' : " ********** "}",
      );
      if (body != null) {
        log(jsonEncode(body), name: "********** BODY **********");
      }
      if (queryParameters != null) {
        log(jsonEncode(queryParameters), name: "********** PARAMS **********");
      }

      http.Response response = await _getResponse(
        method: method,
        uri: uri,
        body: body,
        headers: headersDefault,
      );
      log(
        response.statusCode.toString(),
        name: "********** STATUS CODE **********",
      );
      if (response.statusCode == statusCode) {
        log(
          utf8.decode(response.bodyBytes),
          name: "********** RESULT **********",
        );

        return right(utf8.decode(response.bodyBytes));
      } else {
        log(response.body, name: "${response.statusCode}");
        return left(jsonDecode(response.body)['error']);
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        return left(
          "Network offline. Please enable your internet connection to continue (Required for Quizzes).",
        );
      }
      return left(e.toString());
    }
  }
}

Future<http.Response> _getResponse({
  required Uri uri,
  required Method method,
  final headers,
  Map? body,
}) async {
  switch (method) {
    case Method.get:
      return await http.get(uri, headers: headers);
    case Method.post:
      return await http.post(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
    case Method.delete:
      return await http.delete(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
    case Method.patch:
      return await http.patch(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
    case Method.put:
      return await http.put(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
  }
}
