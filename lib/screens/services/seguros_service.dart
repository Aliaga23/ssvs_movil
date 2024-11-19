import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pago_seguro.dart';

class SegurosService {
  final String baseUrl =
      'https://ssvsbackend-production.up.railway.app/api/pagos-seguro';

  Future<List<PagoSeguro>> obtenerHistorialDePagos(int pacienteId) async {
    final response = await http.get(Uri.parse('$baseUrl/historial/$pacienteId'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => PagoSeguro.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener historial de pagos');
    }
  }
}
