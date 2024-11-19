// models/reserva.dart

class Reserva {
  final int reservaId;
  final int pacienteId;
  final String nombrePaciente;
  final String apellidoPaciente;
  final String fechaReserva;
  final String estado;
  final int cupoId;
  final String horaInicio;
  final String horaFin;
  final int medicoId;
  final String nombreMedico;
  final String apellidoMedico;
  final int especialidadId;
  final String nombreEspecialidad;
  final int? historiaId;

  Reserva({
    required this.reservaId,
    required this.pacienteId,
    required this.nombrePaciente,
    required this.apellidoPaciente,
    required this.fechaReserva,
    required this.estado,
    required this.cupoId,
    required this.horaInicio,
    required this.horaFin,
    required this.medicoId,
    required this.nombreMedico,
    required this.apellidoMedico,
    required this.especialidadId,
    required this.nombreEspecialidad,
    this.historiaId,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      reservaId: json['reservaId'],
      pacienteId: json['pacienteId'],
      nombrePaciente: json['nombrePaciente'],
      apellidoPaciente: json['apellidoPaciente'],
      fechaReserva: json['fechaReserva'],
      estado: json['estado'],
      cupoId: json['cupoId'],
      horaInicio: json['horaInicio'],
      horaFin: json['horaFin'],
      medicoId: json['medicoId'],
      nombreMedico: json['nombreMedico'],
      apellidoMedico: json['apellidoMedico'],
      especialidadId: json['especialidadId'],
      nombreEspecialidad: json['nombreEspecialidad'],
      historiaId: json['historiaId'],
    );
  }
}
