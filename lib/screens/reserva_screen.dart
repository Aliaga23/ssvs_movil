import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'especialidad_service.dart';
import 'horario_medico_especialidad_service.dart';
import 'cupo_service.dart';
import 'reserva_service.dart';
import 'auth_service.dart';
import 'models/reserva.dart';

class ReservaScreen extends StatefulWidget {
  @override
  _ReservaScreenState createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  final EspecialidadService especialidadService = EspecialidadService();
  final HorarioMedicoEspecialidadService horarioService = HorarioMedicoEspecialidadService();
  final CupoService cupoService = CupoService();
  final ReservaService reservaService = ReservaService();
  final AuthService authService = AuthService();

  List<dynamic> especialidades = [];
  List<dynamic> uniqueMedicos = [];
  List<dynamic> filteredCupos = [];
  Map<String, dynamic>? currentReserva;
  int? pacienteId;
  int? selectedEspecialidadId;
  int? selectedMedicoId;
  int? selectedCupoId;
  String selectedFecha = DateTime.now().toIso8601String().split('T').first;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    pacienteId = await obtenerPacienteIdDelToken();
    if (pacienteId != null) {
      fetchEspecialidades();
      fetchCurrentReserva();
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

  Future<void> fetchEspecialidades() async {
    setState(() => _isLoading = true);
    try {
      especialidades = await especialidadService.getEspecialidades();
    } catch (error) {
      showErrorSnackBar('Error al obtener especialidades');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchCurrentReserva() async {
    if (pacienteId != null) {
      try {
        final reservaData = await reservaService.getReservaByPacienteId(pacienteId!);
        setState(() {
          currentReserva = reservaData.isNotEmpty ? reservaData[0] : null;
        });
      } catch (error) {
        showErrorSnackBar('Error al obtener la reserva actual');
      }
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> onEspecialidadChange(int especialidadId) async {
    setState(() {
      _isLoading = true;
      uniqueMedicos = [];
      selectedMedicoId = null;
      selectedCupoId = null;
    });

    try {
      final medicos = await horarioService.getMedicosByEspecialidad(especialidadId);
      final uniqueMedicoSet = <int>{};
      uniqueMedicos = medicos.where((medico) => uniqueMedicoSet.add(medico['medicoId'])).toList();
    } catch (error) {
      showErrorSnackBar('Error al obtener médicos');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> onMedicoChange(int medicoId) async {
    setState(() {
      _isLoading = true;
      filteredCupos = [];
      selectedCupoId = null;
    });
    try {
      final cupos = await cupoService.getCuposWithDetails(medicoId, selectedEspecialidadId!);
      int todayWeekday = DateTime.now().weekday;
      setState(() {
        filteredCupos = cupos
            .where((cupo) => _getDayOfWeek(cupo['diaSemana']) == todayWeekday && cupo['estado'] == 'Disponible')
            .toList();
      });
    } catch (error) {
      showErrorSnackBar('Error al obtener cupos');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int _getDayOfWeek(String dia) {
    const days = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
    return days.indexOf(dia) + 1;
  }

  void selectCupo(int cupoId) {
    setState(() {
      selectedCupoId = cupoId;
    });
  }

  Future<void> createReserva() async {
    if (pacienteId != null && selectedCupoId != null && selectedFecha.isNotEmpty) {
      try {
        await reservaService.createReserva({
          'pacienteId': pacienteId,
          'cupoId': selectedCupoId,
          'fechaReserva': selectedFecha,
          'estado': 'Reservada',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserva creada con éxito')),
        );
        fetchCurrentReserva(); // Fetch the latest reservation after creating it
      } catch (error) {
        showErrorSnackBar('Error al crear la reserva');
      }
    } else {
      showErrorSnackBar('Por favor, selecciona un médico, especialidad, fecha y cupo disponibles');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Reserva'),
        backgroundColor: Colors.teal[600],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Selecciona una Especialidad",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[800]),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: especialidades.map((especialidad) {
                return ChoiceChip(
                  label: Text(especialidad['nombre'], style: TextStyle(color: Colors.black87)),
                  selectedColor: Colors.teal[300],
                  backgroundColor: Colors.grey[200],
                  selected: selectedEspecialidadId == especialidad['id'],
                  onSelected: (selected) {
                    setState(() => selectedEspecialidadId = selected ? especialidad['id'] : null);
                    if (selectedEspecialidadId != null) onEspecialidadChange(selectedEspecialidadId!);
                  },
                );
              }).toList(),
            ),

            SizedBox(height: 24),

            if (uniqueMedicos.isNotEmpty) ...[
              Text(
                "Selecciona un Médico",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[800]),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: uniqueMedicos.map((medico) {
                  return ChoiceChip(
                    label: Text('Dr. ${medico['medicoNombre']} ${medico['medicoApellido']}',
                        style: TextStyle(color: Colors.black87)),
                    selectedColor: Colors.blue[300],
                    backgroundColor: Colors.grey[200],
                    selected: selectedMedicoId == medico['medicoId'],
                    onSelected: (selected) {
                      setState(() => selectedMedicoId = selected ? medico['medicoId'] : null);
                      if (selectedMedicoId != null) onMedicoChange(selectedMedicoId!);
                    },
                  );
                }).toList(),
              ),
            ],

            SizedBox(height: 24),

            if (filteredCupos.isNotEmpty) ...[
              Text(
                "Selecciona un Cupo",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[800]),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: filteredCupos.map((cupo) {
                  return GestureDetector(
                    onTap: () => selectCupo(cupo['cupoId']),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedCupoId == cupo['cupoId'] ? Colors.teal[600] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${cupo['horaInicio']} - ${cupo['horaFin']}',
                        style: TextStyle(
                          color: selectedCupoId == cupo['cupoId'] ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            SizedBox(height: 24),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[600],
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: createReserva,
                child: Text('Crear Reserva', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),

            SizedBox(height: 32),

            if (currentReserva != null) ...[
              Text(
                "Mi Reserva Actual",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[800]),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
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
                    Text('Nombre: ${currentReserva!['nombrePaciente']} ${currentReserva!['apellidoPaciente']}'),
                    Text('Fecha: ${currentReserva!['fechaReserva']}'),
                    Text('Hora: ${currentReserva!['horaInicio']} - ${currentReserva!['horaFin']}'),
                    Text('Médico: Dr. ${currentReserva!['nombreMedico']} ${currentReserva!['apellidoMedico']}'),
                    Text('Especialidad: ${currentReserva!['nombreEspecialidad']}'),
                    Text('Estado: ${currentReserva!['estado']}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
