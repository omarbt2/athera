import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';

/// HTTP client wrapper.
/// After integrating Firebase, inject the auth token from FirebaseAuth externally.
class ApiClient {
  final String? _authToken;

  ApiClient({String? authToken}) : _authToken = authToken;

  Map<String, String> get _headers => {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        if (_authToken != null) HttpHeaders.authorizationHeader: 'Bearer $_authToken',
      };

  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 30));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
    final response = await http
        .post(uri, headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 30));
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    throw HttpException(
      decoded['message']?.toString() ?? 'Request failed',
      uri: Uri.parse(response.request?.url.toString() ?? ''),
    );
  }
}
