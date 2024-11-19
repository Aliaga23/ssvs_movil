import 'dart:convert';
import 'package:http/http.dart' as http;

class EspecialidadService {
  final String apiUrl = 'https://ssvsbackend-production.up.railway.app/api/especialidades';

  // Método para obtener todas las especialidades
  Future<List<dynamic>> getEspecialidades() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error al obtener especialidades: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error de conexión: $e");
      return [];
    }
  }

  // Método para obtener una especialidad por su ID
  Future<Map<String, dynamic>?> getEspecialidadById(int id) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error al obtener especialidad: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return null;
    }
  }

  // Método para crear una nueva especialidad
  Future<void> createEspecialidad(Map<String, dynamic> especialidadData) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(especialidadData),
      );
      if (response.statusCode != 201) {
        print("Error al crear especialidad: ${response.body}");
      }
    } catch (e) {
      print("Error de conexión: $e");
    }
  }

  // Método para actualizar una especialidad
  Future<void> updateEspecialidad(int id, Map<String, dynamic> especialidadData) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(especialidadData),
      );
      if (response.statusCode != 200) {
        print("Error al actualizar especialidad: ${response.body}");
      }
    } catch (e) {
      print("Error de conexión: $e");
    }
  }

  // Método para eliminar una especialidad
  Future<void> deleteEspecialidad(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode != 200) {
        print("Error al eliminar especialidad: ${response.body}");
      }
    } catch (e) {
      print("Error de conexión: $e");
    }
  }
}
