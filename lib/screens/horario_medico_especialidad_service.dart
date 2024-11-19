import 'package:http/http.dart' as http;
import 'dart:convert';

class HorarioMedicoEspecialidadService {
  final String apiUrl = 'https://ssvsbackend-production.up.railway.app/api/horario-medico-especialidad';



  // Obtener médicos por especialidad
  Future<List<dynamic>> getMedicosByEspecialidad(int especialidadId) async {
    final url = '$apiUrl/especialidad/$especialidadId/medicos';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener médicos para la especialidad seleccionada');
    }
  }
}
