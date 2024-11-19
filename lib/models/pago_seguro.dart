class PagoSeguro {
  final int pagoId;
  final int pacienteId;
  final double monto;
  final String fechaPago;
  final String? fechaVencimiento;
  final int metodoId;
  final String estado;
  final String? metodoPago;

  PagoSeguro({
    required this.pagoId,
    required this.pacienteId,
    required this.monto,
    required this.fechaPago,
    this.fechaVencimiento,
    required this.metodoId,
    required this.estado,
    this.metodoPago,
  });

  factory PagoSeguro.fromJson(Map<String, dynamic> json) {
    return PagoSeguro(
      pagoId: json['pagoId'],
      pacienteId: json['pacienteId'],
      monto: json['monto'].toDouble(),
      fechaPago: json['fechaPago'],
      fechaVencimiento: json['fechaVencimiento'],
      metodoId: json['metodoId'],
      estado: json['estado'],
      metodoPago: json['metodoPago'],
    );
  }
}
