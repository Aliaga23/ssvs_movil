import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'models/pago_seguro.dart';
import 'services/seguros_service.dart';
import 'auth_service.dart';

class HistorialPagosScreen extends StatefulWidget {
  @override
  _HistorialPagosScreenState createState() => _HistorialPagosScreenState();
}

class _HistorialPagosScreenState extends State<HistorialPagosScreen> {
  final SegurosService segurosService = SegurosService();
  final AuthService authService = AuthService();

  List<PagoSeguro> historialPagos = [];
  int? pacienteId;

  @override
  void initState() {
    super.initState();
    obtenerPacienteIdDelToken().then((id) {
      if (id != null) {
        setState(() {
          pacienteId = id;
        });
        cargarHistorialPagos();
      }
    });
  }

  Future<void> cargarHistorialPagos() async {
    try {
      if (pacienteId != null) {
        final pagos = await segurosService.obtenerHistorialDePagos(pacienteId!);
        setState(() {
          historialPagos = pagos;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el historial de pagos')),
      );
    }
  }

  Future<int?> obtenerPacienteIdDelToken() async {
    String? token = await authService.getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['pacienteId'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Pagos'),
        backgroundColor: Colors.teal[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: historialPagos.isNotEmpty
            ? ListView.builder(
          itemCount: historialPagos.length,
          itemBuilder: (context, index) {
            final pago = historialPagos[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  'Pago: \$${pago.monto.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Fecha: ${pago.fechaPago}\n'
                      'Método: ${pago.metodoPago ?? "No especificado"}\n'
                      'Estado: ${pago.estado}',
                ),
                trailing: Icon(
                  pago.estado == "Procesado"
                      ? Icons.check_circle
                      : Icons.error,
                  color: pago.estado == "Procesado"
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            );
          },
        )
            : Center(
          child: Text(
            'No hay pagos registrados.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}
