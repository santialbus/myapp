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

      print("Código de estado: ${response.statusCode}");
      print("Cuerpo de respuesta: ${response.body}");

      // Verifica si la respuesta es exitosa (200-299)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw Exception("La respuesta no es JSON válido: ${response.body}");
        }
      } else {
        throw Exception("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Error de conexión: $e");
      throw Exception("No se pudo conectar con el servidor");
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    final url = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParameters?.map((key, value) => MapEntry(key, value.toString())),
    );

    final defaultHeaders = {
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(
        url,
        headers: defaultHeaders,
      );

      print("Código de estado: ${response.statusCode}");
      print("Cuerpo de respuesta: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          try {
            return jsonDecode(response.body);
          } catch (e) {
            throw Exception("La respuesta no es JSON válido: ${response.body}");
          }
        } else {
          return null; // o throw Exception("Respuesta vacía"); si esperas siempre contenido
        }
      } else {
        throw Exception("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Error de conexión: $e");
      throw Exception("No se pudo conectar con el servidor");
    }
  }
}
