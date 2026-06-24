import 'dart:convert';
import 'package:http/http.dart' as http;

class RealtimeApiClient {
  RealtimeApiClient({required this.databaseUrl});

  final String databaseUrl;

  Uri _buildUri(String path, String? idToken) {
    final clean = path.startsWith('/') ? path.substring(1) : path;
    final params = <String, String>{if (idToken != null) 'auth': idToken};
    return Uri.parse('$databaseUrl/$clean.json')
        .replace(queryParameters: params.isEmpty ? null : params);
  }

  Future<dynamic> get(String path, {String? idToken}) async {
    final res = await http.get(_buildUri(path, idToken));
    _checkError(res);
    if (res.body == 'null') return null;
    return jsonDecode(res.body);
  }

  Future<dynamic> post(String path, Map<String, dynamic> data, {String? idToken}) async {
    final res = await http.post(_buildUri(path, idToken), body: jsonEncode(data));
    _checkError(res);
    return jsonDecode(res.body);
  }

  Future<void> put(String path, Map<String, dynamic> data, {String? idToken}) async {
    final res = await http.put(_buildUri(path, idToken), body: jsonEncode(data));
    _checkError(res);
  }

  Future<void> patch(String path, Map<String, dynamic> data, {String? idToken}) async {
    final res = await http.patch(_buildUri(path, idToken), body: jsonEncode(data));
    _checkError(res);
  }

  Future<void> delete(String path, {String? idToken}) async {
    final res = await http.delete(_buildUri(path, idToken));
    _checkError(res);
  }

  void _checkError(http.Response res) {
    if (res.statusCode >= 400) {
      throw Exception('Gagal menghubungi server (${res.statusCode})');
    }
  }
}