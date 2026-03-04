/*
    Autor: Alberto Ortiz Arribas
    Fecha: 05-04-2025
    Resumen: Muestra una lista con las ligas activas y un menu desplegable con las
    opciones que se pueden realizar sobre una liga.
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tfgandroid/clasificacion-admin.dart';
import 'package:tfgandroid/resultados_admin.dart';
import 'package:tfgandroid/jornada_actual.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ligas Activas',
      home: LigasActivasPage(),
    );
  }
}

class LigasActivasPage extends StatefulWidget {
  @override
  _LigasActivasPageState createState() => _LigasActivasPageState();
}

class _LigasActivasPageState extends State<LigasActivasPage> {
  List<Map<String, dynamic>> ligas = [];

  @override
  void initState() {
    super.initState();
    obtenerLigasActivas();
  }

  Future<void> obtenerLigasActivas() async {
    final url = Uri.parse('http://192.168.252.122/android/get_ligas_activas.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ligas = List<Map<String, dynamic>>.from(data['ligas']);
        });
      } else {
        mostrarMensaje('Error al cargar las ligas');
      }
    } catch (e) {
      mostrarMensaje('Error de conexión');
    }
  }

  Future<void> ejecutarPHP(String archivo, String liga) async {
    final url = Uri.parse('http://192.168.252.122/android/$archivo?liga=$liga');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          if (data['success']) {
            mostrarMensaje(data['message'] ?? 'Acción ejecutada correctamente.');
            obtenerLigasActivas();
          } else {
            mostrarMensaje(data['message'] ?? 'La acción no se pudo completar.');
          }
        } catch (e) {
          // Si la respuesta no es JSON, simplemente mostramos el texto crudo
          mostrarMensaje(response.body);
        }
      } else {
        mostrarMensaje("Error al ejecutar la acción. Código: ${response.statusCode}");
      }
    } catch (e) {
      mostrarMensaje("Error de conexión.");
    }
  }


  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void confirmarTerminarLiga(String liga) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("¿Estás seguro?"),
          content: Text("¿Estás seguro que quieres acabar con esta liga?"),
          actions: [
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: Text("Sí"),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                ejecutarPHP("terminar-liga.php", liga);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ligas Activas')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ligas.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: ligas.length,
          itemBuilder: (context, index) {
            final liga = ligas[index];

            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  liga['nombre'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Fecha de Creación: ${liga['fecha_creacion']}"),
                trailing: PopupMenuButton<String>(
                  onSelected: (opcion) {
                    if (opcion == 'ver_clasificacion') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClasificacionAdminPage(liga['nombre']),
                        ),
                      );
                    } else if (opcion == 'ver_resultados') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultadosAdminPage(liga['nombre']),
                        ),
                      );
                    } else if (opcion == 'jornada_actual') {
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JornadaActualPage(liga: liga['nombre']),
                      ),
                    );
                    } else if (opcion == 'generar_jornada') {
                      ejecutarPHP("nueva_jornada.php", liga['nombre']);
                    } else if (opcion == 'terminar_liga') {
                      confirmarTerminarLiga(liga['nombre']);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(value: 'ver_clasificacion', child: Text('Ver Clasificación')),
                    PopupMenuItem(value: 'ver_resultados', child: Text('Ver Resultados')),
                    PopupMenuItem(value: 'jornada_actual', child: Text('Revisar Jornada Actual')),
                    PopupMenuItem(value: 'generar_jornada', child: Text('Generar Nueva Jornada')),
                    PopupMenuItem(value: 'terminar_liga', child: Text('Terminar Liga')),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ClasificacionPage extends StatelessWidget {
  final String liga;
  ClasificacionPage(this.liga);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clasificación - $liga')),
      body: Center(child: Text('Aquí va la clasificación de la liga $liga')),
    );
  }
}

class ResultadosPage extends StatelessWidget {
  final String liga;
  ResultadosPage(this.liga);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resultados - $liga')),
      body: Center(child: Text('Aquí van los resultados de la liga $liga')),
    );
  }
}
