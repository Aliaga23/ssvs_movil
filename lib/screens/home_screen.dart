import 'package:flutter/material.dart';
import 'reserva_screen.dart';
import 'historia_clinica_screen.dart';
import 'notificaciones_screen.dart';
import 'historial_pagos_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de pantallas para cada pestaña
  final List<Widget> _screens = [
    Center(child: Text('Home Screen')), // Pantalla de inicio (Placeholder)
    ReservaScreen(), // Pantalla de Reservas
    HistoriaClinicaScreen(), // Pantalla de Historia Clínica
    HistorialPagosScreen(), // Pantalla de Historial de Pagos
    NotificacionesScreen(), // Pantalla de Notificaciones
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Mostrar la pantalla seleccionada
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Reserva',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open),
            label: 'Historia Clínica',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Historial Pagos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
        ],
        currentIndex: _selectedIndex, // Índice de pestaña seleccionada
        selectedItemColor: Colors.blue, // Color de selección
        unselectedItemColor: Colors.grey, // Color de pestañas no seleccionadas
        onTap: _onItemTapped, // Manejo de cambios de pestaña
      ),
    );
  }
}
