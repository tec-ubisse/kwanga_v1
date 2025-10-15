import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kwanga/core/env.dart';
import 'package:kwanga/utils/secure_storage.dart';

class ApiService {
  final String baseUrl = Env.apiUrl;

  Future<http.Response> post(String endpoint, Map<String, dynamic> data, {bool auth = false}) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final headers = {'Content-Type': 'application/json', 'Accept' : 'application/json'};

    if (auth) {
      final token = await SecureStorage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    return await http.post(uri, headers: headers, body: jsonEncode(data));
  }

  Future<http.Response> get(String endpoint, {bool auth = false}) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final headers = {'Content-Type': 'application/json'};

    if (auth) {
      final token = await SecureStorage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    return await http.get(uri, headers: headers);
  }
}
