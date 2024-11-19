import 'package:http/http.dart' as http;
import 'dart:convert';

class CupoService {
  final String apiUrl = 'https://ssvsbackend-production.up.railway.app/api/cupos';

  // Obtener todos los cupos disponibles para un médico y especialidad
  Future<List<dynamic>> getCuposWithDetails(int medicoId, int especialidadId) async {
    final response = await http.get(
      Uri.parse('$apiUrl/medico/$medicoId/especialidad/$especialidadId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener los cupos');
    }
  }
}
