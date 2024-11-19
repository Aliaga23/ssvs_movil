import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'reserva_service.dart';
import 'auth_service.dart';

class NotificacionesScreen extends StatefulWidget {
  @override
  _NotificacionesScreenState createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final ReservaService reservaService = ReservaService();
  final AuthService authService = AuthService();
  List<dynamic> upcomingReservations = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      int? pacienteId = await obtenerPacienteIdDelToken();
      if (pacienteId != null) {
        List<dynamic> reservations = await reservaService.getReservaByPacienteId(pacienteId);
        setState(() {
          upcomingReservations = reservations;
        });
      }
    } catch (error) {
      showErrorSnackBar('Error al cargar notificaciones');
    }
  }

  Future<int?> obtenerPacienteIdDelToken() async {
    String? token = await authService.getToken();
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['pacienteId'];
    }
    return null;
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
        backgroundColor: Colors.teal[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: upcomingReservations.isNotEmpty
            ? ListView.builder(
          itemCount: upcomingReservations.length,
          itemBuilder: (context, index) {
            if (index >= upcomingReservations.length) {
              return SizedBox(); // Avoid out-of-bounds access
            }

            final reserva = upcomingReservations[index];

            // Use null-safe access with fallback values for each field
            String especialidad = reserva['nombreEspecialidad'] ?? 'Especialidad desconocida';
            String medicoNombre = reserva['nombreMedico'] ?? 'Nombre desconocido';
            String medicoApellido = reserva['apellidoMedico'] ?? '';
            String horaInicio = reserva['horaInicio'] ?? 'Hora no disponible';
            String horaFin = reserva['horaFin'] ?? 'Hora no disponible';
            String fechaReserva = reserva['fechaReserva'] ?? 'Fecha no disponible';

            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(
                  'Próxima cita en $especialidad',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Con Dr. $medicoNombre $medicoApellido\n'
                      'Hora: $horaInicio - $horaFin\n'
                      'Fecha: $fechaReserva',
                ),
                trailing: Icon(Icons.notifications_active, color: Colors.teal[700]),
              ),
            );
          },
        )
            : Center(
          child: Text(
            'No tienes próximas citas en los próximos 30 minutos.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}
