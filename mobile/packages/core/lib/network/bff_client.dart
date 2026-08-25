import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BffClient {
  final String baseUrl;
  final http.Client _client;
  static final Map<String, dynamic> _cache = {};

  BffClient({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? (kIsWeb ? 'http://localhost:3001' : 'http://10.0.2.2:3001'),
        _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<dynamic> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    debugPrint('[BFF GET] $uri');
    try {
      final response = await _client.get(uri, headers: _headers);
      final result = _handleResponse(response);
      _cache[path] = result;
      return result;
    } catch (e) {
      debugPrint('[BFF GET ERROR] $e');
      if (_cache.containsKey(path)) {
        debugPrint('[BFF OFFLINE CACHE HIT] Serving cached data for $path');
        return _cache[path];
      }
      rethrow;
    }
  }


  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    debugPrint('[BFF POST] $uri');
    try {
      final response = await _client.post(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[BFF POST ERROR] $e');
      rethrow;
    }
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    debugPrint('[BFF PATCH] $uri');
    try {
      final response = await _client.patch(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[BFF PATCH ERROR] $e');
      rethrow;
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    debugPrint('[BFF PUT] $uri');
    try {
      final response = await _client.put(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[BFF PUT ERROR] $e');
      rethrow;
    }
  }

  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    debugPrint('[BFF DELETE] $uri');
    try {
      final response = await _client.delete(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[BFF DELETE ERROR] $e');
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    final bodyString = utf8.decode(response.bodyBytes);

    dynamic decoded;
    try {
      decoded = jsonDecode(bodyString);
    } catch (_) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return bodyString;
      }
      throw Exception('Erro no servidor (${response.statusCode})');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      // Return the decoded body so callers can read error messages
      if (decoded is Map && decoded.containsKey('success')) {
        return decoded;
      }
      final message = decoded is Map && decoded['message'] != null
          ? decoded['message']
          : 'Erro no servidor (${response.statusCode})';
      throw Exception(message);
    }
  }
}
