import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl = 'http://10.0.2.2:8000';

  Future<Map<String, dynamic>> login(
    String endpoint, {
    required Map<String, dynamic> data,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final response = await http.post(
        url,
        headers: {...defaultHeaders, ...?headers},
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        print("Error ${response.statusCode}: ${response.body}"); // Debug
        throw Exception("Error en la solicitud: ${response.statusCode}");
      }
    } catch (e) {
      print("Error de conexión: $e"); // Debug
      throw Exception("No se pudo conectar con el servidor");
    }
  }
}
