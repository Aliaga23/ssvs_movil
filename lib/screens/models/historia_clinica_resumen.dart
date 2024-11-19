// lib/models/historia_clinica_resumen.dart

class HistoriaClinicaResumen {
  final int pacienteId;
  final String nombrePaciente;
  final String apellidoPaciente;
  final int historiaId;
  final String fechaCreacionHistoria;
  final int consultaId;
  final String fechaConsulta;
  final String diagnostico;
  final String tratamiento;
  final String notasConsulta;
  final String medicamentosReceta;
  final String laboratorios;

  HistoriaClinicaResumen({
    required this.pacienteId,
    required this.nombrePaciente,
    required this.apellidoPaciente,
    required this.historiaId,
    required this.fechaCreacionHistoria,
    required this.consultaId,
    required this.fechaConsulta,
    required this.diagnostico,
    required this.tratamiento,
    required this.notasConsulta,
    required this.medicamentosReceta,
    required this.laboratorios,
  });

  factory HistoriaClinicaResumen.fromJson(Map<String, dynamic> json) {
    return HistoriaClinicaResumen(
      pacienteId: json['pacienteId'],
      nombrePaciente: json['nombrePaciente'],
      apellidoPaciente: json['apellidoPaciente'],
      historiaId: json['historiaId'],
      fechaCreacionHistoria: json['fechaCreacionHistoria'],
      consultaId: json['consultaId'],
      fechaConsulta: json['fechaConsulta'],
      diagnostico: json['diagnostico'],
      tratamiento: json['tratamiento'],
      notasConsulta: json['notasConsulta'],
      medicamentosReceta: json['medicamentosReceta'],
      laboratorios: json['laboratorios'],
    );
  }
}
