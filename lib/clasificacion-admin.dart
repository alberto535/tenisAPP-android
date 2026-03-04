/*
    Autor: Alberto Ortiz Arribas
    Fecha: 02-04-2025
    Resumen: Muestra la clasificacion de la liga y division seleccionada anteriormente.
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClasificacionAdminPage extends StatefulWidget {
  final String liga;
  ClasificacionAdminPage(this.liga);

  @override
  _ClasificacionAdminPageState createState() => _ClasificacionAdminPageState();
}

class _ClasificacionAdminPageState extends State<ClasificacionAdminPage> {
  List<Map<String, dynamic>> clasificacion = [];
  List<String> divisiones = [];
  String? divisionSeleccionada;

  @override
  void initState() {
    super.initState();
    obtenerClasificacion();
  }

  Future<void> obtenerClasificacion() async {
    final url = Uri.parse(
        'http://192.168.252.122/android/get_clasificacion.php?liga=${widget.liga}${divisionSeleccionada != null ? '&division=$divisionSeleccionada' : ''}');

    print("Intentando conectar a: $url");

    try {
      final response = await http.get(url);
      print("Código de respuesta: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Datos recibidos: $data");

        setState(() {
          clasificacion = List<Map<String, dynamic>>.from(data['clasificacion'].map((jugador) => {
            "nombre": jugador['nombre'].toString(),
            "apellidos": jugador['apellidos'].toString(),
            "puntuaje": jugador['puntuaje'].toString(), // Convertir a String
            "buch": jugador['buch'].toString(), // Convertir a String
            "m-buch": jugador['m-buch'].toString(), // Convertir a String
            "division": jugador['division'].toString(), // Convertir a String
          }));

          divisiones = List<String>.from(data['divisiones'].map((div) => div.toString())); // Convertir divisiones a String
        });
      } else {
        print("Error en la respuesta del servidor: ${response.body}");
        mostrarMensaje('Error al cargar la clasificación');
      }
    } catch (e) {
      print("Error de conexión: $e");
      mostrarMensaje('Error de conexión: $e');
    }
  }


  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clasificación - ${widget.liga}')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: divisionSeleccionada,
              hint: Text("Selecciona una división"),
              isExpanded: true,
              items: divisiones.map((String division) {
                return DropdownMenuItem<String>(
                  value: division,
                  child: Text(division),
                );
              }).toList(),
              onChanged: (nuevaDivision) {
                setState(() {
                  divisionSeleccionada = nuevaDivision;
                });
                obtenerClasificacion();
              },
            ),
            Expanded(
              child: clasificacion.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 15.0,
                  columns: [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Apellidos')),
                    DataColumn(label: Text('Puntos')),
                    DataColumn(label: Text('Buch')),
                    DataColumn(label: Text('M_Buch')),
                    DataColumn(label: Text('División')),
                  ],
                  rows: List<DataRow>.generate(
                      clasificacion.length,
                          (index) {
                        final jugador = clasificacion[index];
                        return DataRow(
                          cells: [
                            DataCell(Text((index + 1).toString())),
                            DataCell(Text(jugador['nombre'])),
                        DataCell(Text(jugador['apellidos'])),
                        DataCell(Text(jugador['puntuaje'].toString())),
                        DataCell(Text(jugador['buch'].toString())),
                        DataCell(Text(jugador['m-buch'].toString())),
                        DataCell(Text(jugador['division'].toString())),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
