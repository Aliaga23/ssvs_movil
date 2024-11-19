// services/historia_clinica_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/historia_clinica_resumen.dart';

class HistoriaClinicaService {
  final String apiUrl = 'https://ssvsbackend-production.up.railway.app/api/historias-clinicas/resumen';

  Future<List<HistoriaClinicaResumen>> getHistoriaClinicaResumen(int pacienteId) async {
    final response = await http.get(Uri.parse('$apiUrl/$pacienteId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => HistoriaClinicaResumen.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load historia clínica');
    }
  }
}
