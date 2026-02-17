import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  ApiException(this.status, this.message);

  @override
  String toString() => "ApiException($status): $message";
}

class ApiClient {
  final TokenStorage tokenStorage;
  ApiClient({required this.tokenStorage});

  Uri _uri(String path) => Uri.parse("${Env.apiBaseUrl}$path");

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final headers = await _headers(auth: auth);
    final res = await http.post(
      _uri(path),
      headers: headers,
      body: jsonEncode(body ?? {}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> getJson(String path, {bool auth = false}) async {
    final headers = await _headers(auth: auth);
    final res = await http.get(_uri(path), headers: headers);
    return _handle(res);
  }

  Future<Map<String, String>> _headers({required bool auth}) async {
    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (auth) {
      final token = await tokenStorage.readToken();
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  Map<String, dynamic> _handle(http.Response res) {
    Map<String, dynamic> data = {};
    if (res.body.isNotEmpty) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return data;

    final msg = (data["error"] ?? data["message"] ?? "Request failed")
        .toString();
    throw ApiException(res.statusCode, msg);
  }
}
