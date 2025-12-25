import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:kwanga/core/env.dart';
import 'package:kwanga/utils/secure_storage.dart';

// Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  final String baseUrl = Env.apiUrl;

  // ------------------ HEADERS ------------------

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await SecureStorage.getToken();
      if (token != null) {
        headers['X-TOKEN'] = token;
      }
    }

    return headers;
  }

  // ------------------ POST ------------------

  Future<http.Response> post(
      String endpoint,
      Map<String, dynamic> data, {
        bool auth = false,
      }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final headers = await _headers(auth: auth);

    if (kDebugMode) {
      debugPrint('📤 POST $uri');
      debugPrint('📤 BODY: ${jsonEncode(data)}');
    }

    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(data),
    );

    if (kDebugMode) {
      debugPrint('📥 STATUS: ${res.statusCode}');
      debugPrint('📥 BODY: ${res.body}');
    }

    return res;
  }

  // ------------------ PUT ------------------

  Future<http.Response> put(
      String endpoint,
      Map<String, dynamic> data, {
        bool auth = false,
      }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final headers = await _headers(auth: auth);

    if (kDebugMode) {
      debugPrint('📤 PUT $uri');
      debugPrint('📤 BODY: ${jsonEncode(data)}');
    }

    final res = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(data),
    );

    if (kDebugMode) {
      debugPrint('📥 STATUS: ${res.statusCode}');
      debugPrint('📥 BODY: ${res.body}');
    }

    return res;
  }

  // ------------------ GET ------------------

  Future<http.Response> get(
      String endpoint, {
        bool auth = false,
      }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final headers = await _headers(auth: auth);

    final res = await http.get(uri, headers: headers);

    if (kDebugMode) {
      debugPrint('📥 GET $uri');
      debugPrint('📥 STATUS: ${res.statusCode}');
      debugPrint('📥 BODY: ${res.body}');
    }

    return res;
  }
}
