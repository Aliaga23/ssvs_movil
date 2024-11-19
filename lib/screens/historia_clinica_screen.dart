import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

import 'historia_clinica_service.dart';
import 'auth_service.dart';
import 'models/historia_clinica_resumen.dart';

class HistoriaClinicaScreen extends StatefulWidget {
  @override
  _HistoriaClinicaScreenState createState() => _HistoriaClinicaScreenState();
}

class _HistoriaClinicaScreenState extends State<HistoriaClinicaScreen> {
  final HistoriaClinicaService historiaClinicaService = HistoriaClinicaService();
  final AuthService authService = AuthService();

  List<HistoriaClinicaResumen> historiaClinica = [];
  int? pacienteId;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    pacienteId = await obtenerPacienteIdDelToken();
    if (pacienteId != null) {
      await loadHistoriaClinica();
    } else {
      showErrorSnackBar('Error al obtener paciente del token');
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

  Future<void> loadHistoriaClinica() async {
    try {
      final data = await historiaClinicaService.getHistoriaClinicaResumen(pacienteId!);
      setState(() {
        historiaClinica = data;
      });
    } catch (error) {
      showErrorSnackBar('Error al cargar la historia clínica');
    }
  }

  Future<void> exportarHistoriaClinica() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado
              pw.Text(
                'Resumen de Historia Clínica',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),

              // Información del Paciente
              pw.Text(
                'Información del Paciente',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                  'Nombre: ${historiaClinica[0].nombrePaciente} ${historiaClinica[0].apellidoPaciente}'),
              pw.Text('ID Paciente: ${historiaClinica[0].pacienteId}'),
              pw.Text('Fecha de Creación: ${historiaClinica[0].fechaCreacionHistoria}'),
              pw.SizedBox(height: 20),

              // Consultas Médicas
              pw.Text(
                'Consultas Médicas',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),

              ...historiaClinica.map((consulta) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Consulta Médica (ID: ${consulta.consultaId})',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Fecha: ${consulta.fechaConsulta}'),
                      pw.Text('Diagnóstico: ${consulta.diagnostico}'),
                      pw.Text('Tratamiento: ${consulta.tratamiento}'),
                      pw.Text(
                        'Notas: ${consulta.notasConsulta ?? "No hay notas disponibles"}',
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Medicamentos Recetados:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        consulta.medicamentosReceta ??
                            'No hay medicamentos recetados.',
                        style: pw.TextStyle(color: PdfColors.grey),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Laboratorios Realizados:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        consulta.laboratorios ??
                            'No se han realizado laboratorios.',
                        style: pw.TextStyle(color: PdfColors.grey),
                      ),
                      pw.Divider(),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    try {
      // Solicitar permisos de almacenamiento
      var status = await Permission.storage.request();
      if (status.isGranted) {
        // Obtener el directorio de Descargas
        final directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        final file = File('${directory.path}/historia_clinica.pdf');
        await file.writeAsBytes(await pdf.save());
        showSuccessSnackBar('PDF guardado en ${file.path}');
      } else {
        showErrorSnackBar('Permisos de almacenamiento denegados.');
      }
    } catch (e) {
      showErrorSnackBar('Error al guardar el PDF: $e');
    }
  }


  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: TextStyle(color: Colors.green))));
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: TextStyle(color: Colors.red))));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen de Historia Clínica'),
        backgroundColor: Colors.teal[600],
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              await exportarHistoriaClinica();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: historiaClinica.isNotEmpty
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del Paciente
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del Paciente',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                      'Nombre: ${historiaClinica[0].nombrePaciente} ${historiaClinica[0].apellidoPaciente}'),
                  Text('ID Paciente: ${historiaClinica[0].pacienteId}'),
                  Text('ID Historia Clínica: ${historiaClinica[0].historiaId}'),
                  Text(
                      'Fecha de Creación: ${historiaClinica[0].fechaCreacionHistoria}'),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Consultas Médicas
            Expanded(
              child: ListView.builder(
                itemCount: historiaClinica.length,
                itemBuilder: (context, index) {
                  final consulta = historiaClinica[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consulta Médica (ID: ${consulta.consultaId})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Fecha: ${consulta.fechaConsulta}'),
                        Text('Diagnóstico: ${consulta.diagnostico}'),
                        Text('Tratamiento: ${consulta.tratamiento}'),
                        Text(
                          'Notas: ${consulta.notasConsulta ?? "No hay notas disponibles"}',
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Medicamentos Recetados',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          consulta.medicamentosReceta ?? 'No hay medicamentos recetados.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Laboratorios',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          consulta.laboratorios ?? 'No se han realizado laboratorios.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        )
            : Center(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'No hay datos disponibles para este paciente.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }
}
