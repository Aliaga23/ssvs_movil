import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservaService {
  final String apiUrl = 'https://ssvsbackend-production.up.railway.app/api/reservas';

  // Crear una nueva reserva
  Future<void> createReserva(Map<String, dynamic> reservaData) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(reservaData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear la reserva');
    }
  }

  // Obtener la reserva actual del paciente
  Future<List<dynamic>> getReservaByPacienteId(int pacienteId) async {
    final url = '$apiUrl/paciente/$pacienteId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener la reserva del paciente');
    }
  }
  Future<List<dynamic>> getUpcomingReservations(int pacienteId) async {
    final url = '$apiUrl/paciente/$pacienteId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> reservas = jsonDecode(response.body);

      // Filter to show only reservations starting within the next 30 minutes
      final now = DateTime.now();
      final upcoming = reservas.where((reserva) {
        final DateTime startTime = DateTime.parse(
            "${reserva['fechaReserva']} ${reserva['horaInicio']}");
        return startTime.isAfter(now) &&
            startTime.isBefore(now.add(Duration(minutes: 30)));
      }).toList();

      return upcoming;
    } else {
      throw Exception('Error al obtener la reserva del paciente');
    }
  }
}
